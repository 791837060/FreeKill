local jingzhou = fk.CreateSkill {
  name = "peixiu__jingzhou",
}

Fk:loadTranslationTable {
  ["peixiu_jingzhou"] = "荆州",
  [":peixiu_jingzhou"] = "你获得此技能后，可以交给一名角色任意张手牌。",

  ["#peixiu_jingzhou-choose"] = "荆州：选择一名角色，交给其任意张手牌",
}

jingzhou:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == jingzhou.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if player:isKongcheng() then return false end

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
        skill_name = jingzhou.name,
        prompt = "#peixiu_jingzhou-choose",
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

    local cards = room:askToChooseCard(player, {
      flag = "h",
      skill_name = jingzhou.name,
    })
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, jingzhou.name, nil, false, player)
    end
  end
})

return jingzhou
