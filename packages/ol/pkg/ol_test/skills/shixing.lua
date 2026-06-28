local shixing = fk.CreateSkill{
  name = "shixing",
}

Fk:loadTranslationTable{
  ["shixing"] = "师行",
  [":shixing"] = "出牌阶段开始时，你可以排列每种牌类别的顺序，本阶段你使用前三张牌时，若类别顺序与你排列的相同，则你摸一张牌。"..
  "若顺序皆相同，本回合的结束阶段，你可以选择一名其他角色，其下个出牌阶段开始时发动此技能。",

  ["#shixing-choice"] = "师行：排列类别，本阶段你使用前三张牌若对应顺序相同则摸一张牌",
  ["@shixing-phase"] = "师行",
  ["#shixing-choose"] = "师行：选择一名角色，其下个出牌阶段开始时发动“师行”",
  ["@@shixing"] = "师行",

  ["$shixing1"] = "日自省其身，方能教化于人。",
  ["$shixing2"] = "行胜于言，身教重于言传。",
}

shixing:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if player.phase == Player.Play then
        return (player:hasSkill(shixing.name) or player:getMark("@@shixing") > 0)
      elseif player.phase == Player.Finish then
        return player:getMark("shixing_right-turn") > 2 and #player.room:getOtherPlayers(player, false) > 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if player.phase == Player.Play then
      event:setCostData(self, nil)
      if player:getMark("@@shixing") > 0 then
        return true
      else
        return room:askToSkillInvoke(player, {
          skill_name = shixing.name,
        })
      end
    elseif player.phase == Player.Finish then
      local to = room:askToChoosePlayers(player, {
        targets = room:getOtherPlayers(player, false),
        min_num = 1,
        max_num = 1,
        prompt = "#shixing-choose",
        skill_name = shixing.name,
        cancelable = true,
      })
      if #to > 0 then
        event:setCostData(self, { tos = to })
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.phase == Player.Play then
      room:setPlayerMark(player, "@@shixing", 0)
      local types = { "basic_char", "trick_char", "equip_char" }
      for _ = 1, 3 do
        local choice = room:askToChoice(player, {
          choices = types,
          skill_name = shixing.name,
          prompt = "#shixing-choice",
        })
        room:addTableMark(player, "@shixing-phase", choice)
        table.removeOne(types, choice)
      end
    elseif player.phase == Player.Finish then
      local to = event:getCostData(self).tos[1]
      room:setPlayerMark(to, "@@shixing", 1)
    end
  end,
})

shixing:addEffect(fk.CardUsing, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@shixing-phase") ~= 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local index = #player:getTableMark("shixing-turn") + 1
    room:addTableMark(player, "shixing-turn", data.card:getTypeString().."_char")
    if player:getTableMark("@shixing-phase")[index] == data.card:getTypeString().."_char" then
      room:addPlayerMark(player, "shixing_right-turn", 1)
      player:drawCards(1, shixing.name)
    end
  end,
})

return shixing
