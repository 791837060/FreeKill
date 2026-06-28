local qinzhou = fk.CreateSkill {
  name = "peixiu__qinzhou",
}

Fk:loadTranslationTable {
  ["peixiu_qinzhou"] = "秦州",
  [":peixiu_qinzhou"] = "你获得此技能后，可选择一名其他角色，其使用的下一张牌对你无效。",

  ["#peixiu_qinzhou-choose"] = "秦州：选择一名其他角色，其使用的下一张牌对你无效",
  ["@@peixiu_qinzhou-turn"] = "秦州",
}

qinzhou:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == qinzhou.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player
    end)
    if #targets == 0 then return false end

    local to
    if #targets == 1 then
      to = targets[1]
    else
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = qinzhou.name,
        prompt = "#peixiu_qinzhou-choose",
      })
      if #tos == 0 then return false end
      to = tos[1]
    end
    event:setCostData(self, { tos = { to } })
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:setPlayerMark(to, "@@peixiu_qinzhou-turn", 1)
  end
})

qinzhou:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@peixiu_qinzhou-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@peixiu_qinzhou-turn", 0)
  end,
})

qinzhou:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("@@peixiu_qinzhou-turn") > 0
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and player:getMark("@@peixiu_qinzhou-turn") > 0
  end,
})

qinzhou:addLoseEffect(function(self, player)
  player.room:setPlayerMark(player, "@@peixiu_qinzhou-turn", 0)
end)

return qinzhou
