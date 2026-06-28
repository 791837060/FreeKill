
local keming = fk.CreateSkill {
  name = "keming",
}

Fk:loadTranslationTable{
  ["keming"] = "刻名",
  [":keming"] = "当你受到其他角色造成的伤害后，若其武将牌上有此时机触发的技能，则你可以触发此技能；"..
  "若没有，则你可以从“曹”姓武将中随机触发一个此时机的技能。"..
  "当你对其他角色造成伤害后，该角色下次发动准备阶段、结束阶段或出牌阶段内发动的技能后，若该角色因此技能摸牌或使用了牌，你可以摸等量同名牌（至多五张）。",

  ["#keming-invoke"] = "刻名：是否摸等量张 %dest 发动技能摸牌/使用的牌？",

  ["$keming1"] = "",
  ["$keming2"] = "",
}

keming:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(keming.name) and
      data.from and data.from ~= player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local all_skills = Fk.generals[data.from.general]:getSkillNameList(player.role == "lord")
    if data.from.deputyGeneral ~= "" then
      table.insertTableIfNeed(all_skills, Fk.generals[data.from.deputyGeneral]:getSkillNameList(player.role == "lord"))
    end
    local skills = {}
    for _, skill_name in ipairs(all_skills) do
      if not player:hasSkill(skill_name, true) then
        player:addSkill(skill_name)
        local skel = Fk.skills[skill_name]:getSkeleton()
        for _, skill in ipairs(skel.effects) do
          if skill:isInstanceOf(TriggerSkill) and skill.event == fk.Damaged and skill:triggerable(event, target, player, data) then
            table.insert(skills, skill_name)
            break
          end
        end
        player:loseSkill(skill_name)
      end
    end
    if #skills == 0 then
      all_skills = room:getBanner(keming.name)
      for _, skill_name in ipairs(all_skills) do
        if not player:hasSkill(skill_name, true) then
          player:addSkill(skill_name)
          local skel = Fk.skills[skill_name]:getSkeleton()
          for _, skill in ipairs(skel.effects) do
            if skill:isInstanceOf(TriggerSkill) and skill.event == fk.Damaged and skill:triggerable(event, target, player, data) then
              table.insert(skills, skill_name)
              break
            end
          end
          player:loseSkill(skill_name)
        end
      end
      if #skills > 0 then
        skills = room:tableRandomPick(skills, 1)
      end
    end
    if #skills == 0 then return end
    room:handleAddLoseSkills(player, skills)
    for _, skill_name in ipairs(skills) do
      local skel = Fk.skill_skels[skill_name]
      for _, skill in ipairs(skel.effects) do
        if skill:isInstanceOf(TriggerSkill) and skill.event == fk.Damaged and skill:triggerable(event, target, player, data) then
          skill:trigger(event, target, player, data)
        end
      end
    end
    room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"))
  end,
})

keming:addEffect(fk.Damage, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(keming.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, keming.name, data.to)
  end,
})

keming:addEffect(fk.AfterSkillEffect, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(keming.name) and table.contains(player:getTableMark(keming.name), target) and
      table.contains({ Player.Start, Player.Finish, Player.Play }, target.phase) and
      data.skill:isPlayerSkill(target) and target:hasSkill(data.skill:getSkeleton().name, true, true) then
      if table.contains({ Player.Start, Player.Finish }, target.phase) then
        if not data.skill:isInstanceOf(TriggerSkill) or data.skill.event ~= fk.EventPhaseStart then
          return false
        end
      else
        if not data.skill:isInstanceOf(ActiveSkill) and not data.skill:isInstanceOf(ViewAsSkill) then
          return false
        end
      end
      local names = {}
      player.room.logic:getCurrentEvent():searchEvents(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.to == target and move.moveReason == fk.ReasonDraw and move.skillName == data.skill:getSkeleton().name then
            for _, info in ipairs(move.moveInfo) do
              table.insert(names, info.beforeCard.trueName)
            end
          end
        end
      end)
      player.room.logic:getCurrentEvent():searchEvents(GameEvent.UseCard, 1, function (e)
        local use = e.data
        if use.from == target then
          if table.contains(use.card.skillNames, data.skill:getSkeleton().name) then
            table.insert(names, use.card.trueName)
          elseif e.parent == player.room.logic:getCurrentEvent() then
            table.insert(names, use.card.trueName)
          end
        end
      end)
      if #names > 0 then
        event:setCostData(self, { extra_data = names })
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = keming.name,
      prompt = "#keming-invoke::"..target.id,
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards, names = {}, event:getCostData(self).extra_data
    for _, id in ipairs(room.draw_pile) do
      local name = Fk:getCardById(id).trueName
      if table.removeOne(names, name) then
        table.insert(cards, id)
        if #names == 0 or #cards == 5 then break end
      end
    end
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonDraw, keming.name, nil, false, player)
    end
  end,

  late_refresh = true,
  can_refresh = function (self, event, target, player, data)
    return table.contains(player:getTableMark(keming.name), target) and
      table.contains({ Player.Start, Player.Finish, Player.Play }, target.phase) and
      data.skill:isPlayerSkill(target) and target:hasSkill(data.skill:getSkeleton().name, true, true)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if table.contains({ Player.Start, Player.Finish }, target.phase) then
      if not data.skill:isInstanceOf(TriggerSkill) or data.skill.event ~= fk.EventPhaseStart then
        return false
      end
    else
      if not data.skill:isInstanceOf(ActiveSkill) and not data.skill:isInstanceOf(ViewAsSkill) then
        return false
      end
    end
    room:removeTableMark(player, keming.name, target)
  end,
})

keming:addAcquireEffect(function (self, player, is_start, src)
  local room = player.room
  if not room:getBanner(keming.name) then
    local skills = {}
    for name, general in pairs(Fk.generals) do
      if Fk:canUseGeneral(name) then
        local general_name = Fk:translate(name, "zh_CN")
        if (general_name[1] == "曹" or (general_name:len() > 1 and general_name[2] == "曹")) and name ~= "ty__godcaopi" then
          for _, skill_name in ipairs(general:getSkillNameList(true)) do
            local skel = Fk.skills[skill_name]:getSkeleton()
            for _, skill in ipairs(skel.effects) do
              if skill:isInstanceOf(TriggerSkill) and skill.event == fk.Damaged then
                table.insert(skills, skill_name)
                break
              end
            end
          end
        end
      end
    end
    room:setBanner(keming.name, skills)
  end
end)

return keming
