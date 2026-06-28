local xuzhou = fk.CreateSkill {
  name = "peixiu__xuzhou",
}

Fk:loadTranslationTable {
  ["peixiu_xuzhou"] = "徐州",
  [":peixiu_xuzhou"] = "你获得此技能后，可以指定一名其他角色，其于其的回合外使用牌后摸一张牌。",

  ["#peixiu_xuzhou-choose"] = "徐州：选择一名其他角色，其回合外使用牌后摸一张牌",
  ["@@peixiu_xuzhou-turn"] = "徐州",
}

xuzhou:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == xuzhou.name
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
        skill_name = xuzhou.name,
        prompt = "#peixiu_xuzhou-choose",
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
    room:setPlayerMark(to, "@@peixiu_xuzhou-turn", 1)
  end
})

xuzhou:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@peixiu_xuzhou-turn") > 0
      and player.room.current ~= player
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})

xuzhou:addLoseEffect(function(self, player)
  player.room:setPlayerMark(player, "@@peixiu_xuzhou-turn", 0)
end)

return xuzhou
