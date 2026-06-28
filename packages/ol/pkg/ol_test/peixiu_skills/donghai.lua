local donghai = fk.CreateSkill {
  name = "peixiu__donghai",
}

Fk:loadTranslationTable {
  ["peixiu_donghai"] = "东海",
  [":peixiu_donghai"] = "你获得此技能后，令一名角色下个摸牌阶段多摸一张牌。",

  ["#peixiu_donghai-choose"] = "东海：选择一名角色，其下个摸牌阶段多摸一张牌",
  ["@@peixiu_donghai-turn"] = "东海",
}

donghai:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == donghai.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = room.alive_players
    local to
    if #targets == 1 then
      to = targets[1]
    else
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = donghai.name,
        prompt = "#peixiu_donghai-choose",
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
    room:setPlayerMark(to, "@@peixiu_donghai-turn", 1)
  end
})

donghai:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Draw
      and player:getMark("@@peixiu_donghai-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@peixiu_donghai-turn", 0)
    player:drawCards(1, self.name)
  end,
})

donghai:addLoseEffect(function(self, player)
  player.room:setPlayerMark(player, "@@peixiu_donghai-turn", 0)
end)

return donghai
