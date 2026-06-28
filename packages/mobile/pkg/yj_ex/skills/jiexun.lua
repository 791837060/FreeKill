local jiexun = fk.CreateSkill {
  name = "mobile__jiexun",
}

Fk:loadTranslationTable{
  ["mobile__jiexun"] = "诫训",
  [":mobile__jiexun"] = "结束阶段，你可以选择一种花色，令一名其他角色摸等同于场上此花色牌数的牌（至多5张），"..
  "然后其弃置X张牌（X为本技能发动次数），若其因此弃置了所有手牌，你升级〖复难〗。",

  ["#mobile__jiexun-choose"] = "诫训：选择一种花色，令一名摸场上此花色数的牌，然后弃%arg张牌",

  ["$mobile__jiexun1"] = "主公，今渊贼必为曹魏所灭，何必劳师伐之。",
  ["$mobile__jiexun2"] = "今如此行事，恐得不偿失啊！",
}

jiexun:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiexun.name) and player.phase == Player.Finish and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "#mobile__jiexun_active",
      prompt = "#mobile__jiexun-choose:::"..(player:usedSkillTimes(jiexun.name, Player.HistoryGame) + 1),
    })
    if success and dat then
      event:setCostData(self, { tos = dat.targets, choices = tonumber(string.split(dat.interaction, ":")[5]) })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local n = event:getCostData(self).choices
    local m = player:usedSkillTimes(jiexun.name, Player.HistoryGame)
    if n > 0 then
      to:drawCards(n, jiexun.name)
    end
    if to:isNude() or to.dead then return end
    local throw = room:askToDiscard(to, {
      min_num = m,
      max_num = m,
      include_equip = true,
      skill_name = jiexun.name,
      cancelable = false,
      skip = true,
    })
    local change = table.every(to:getCardIds("h"), function (id)
      return table.contains(throw, id)
    end)
    room:throwCard(throw, jiexun.name, to, to)
    if change and not player.dead then
      if player:hasSkill("mobile__funan", true) then
        room:setPlayerMark(player, "mobile__funan_update", 1)
      end
    end
  end,
})

return jiexun
