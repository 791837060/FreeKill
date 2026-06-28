local donglai = fk.CreateSkill {
  name = "peixiu__donglai",
}

Fk:loadTranslationTable {
  ["peixiu_donglai"] = "东莱",
  [":peixiu_donglai"] = "你获得此技能后，可令一名角色使用的下一张牌无次数和距离限制。",

  ["#peixiu_donglai-choose"] = "东莱：选择一名角色，其使用的下一张牌无次数和距离限制",
  ["@@peixiu_donglai-turn"] = "东莱",
}

donglai:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == donglai.name
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
        skill_name = donglai.name,
        prompt = "#peixiu_donglai-choose",
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
    room:setPlayerMark(to, "@@peixiu_donglai-turn", 1)
  end
})

donglai:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@peixiu_donglai-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@peixiu_donglai-turn", 0)
    if not data.extraUse then
      player:addCardUseHistory(data.card.trueName, -1)
      data.extraUse = true
    end
  end,
})

donglai:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:getMark("@@peixiu_donglai-turn") > 0
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and player:getMark("@@peixiu_donglai-turn") > 0
  end,
})

donglai:addLoseEffect(function(self, player)
  player.room:setPlayerMark(player, "@@peixiu_donglai-turn", 0)
end)

return donglai
