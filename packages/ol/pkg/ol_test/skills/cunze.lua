local cunze = fk.CreateSkill{
  name = "cunze",
}

Fk:loadTranslationTable{
  ["cunze"] = "存择",
  [":cunze"] = "结束阶段，你可以秘密选择一名角色。直到你下次发动此技能，其下次进入濒死状态时，回复体力至1点。你于此期间不能对其他角色使用【桃】。",

  ["#cunze-choose"] = "存择：秘密选择一名角色，其下次进入濒死状态时回复体力至1点",

  ["$cunze1"] = "",
  ["$cunze2"] = "",
}

cunze:addEffect(fk.EventPhaseStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(cunze.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = cunze.name,
      prompt = "#cunze-choose",
      cancelable = true,
      no_indicate = true
    })
    if #to > 0 then
      event:setCostData(self, { extra_data = to })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, cunze.name, event:getCostData(self).extra_data[1])
  end,
})

cunze:addEffect(fk.EnterDying, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return player:getMark(cunze.name) == target.id and not target.dead
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, { tos = { target } })
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, cunze.name, 0)
    room:recover{
      who = target,
      num = 1 - target.hp,
      recoverBy = player,
      skillName = cunze.name,
    }
  end,
})

cunze:addEffect("prohibit", {
  is_prohibited = function (self, from, to, card)
    return from:getMark(cunze.name) ~= 0 and to and card and card.name == "peach"
  end,
})

return cunze
