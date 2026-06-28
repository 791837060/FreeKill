local sizhou = fk.CreateSkill {
  name = "peixiu__sizhou",
}

Fk:loadTranslationTable {
  ["peixiu_sizhou"] = "司州",
  [":peixiu_sizhou"] = "你获得此技能后，可以获得一名角色一张手牌。",

  ["#peixiu_sizhou-choose"] = "司州：选择一名角色，获得其一张手牌",
}

sizhou:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == sizhou.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return not p:isKongcheng()
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
        skill_name = sizhou.name,
        prompt = "#peixiu_sizhou-choose",
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

    local cards = room:askToChooseCard(to, {
      flag = "h",
      skill_name = sizhou.name,
    })
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, sizhou.name, nil, false, to)
    end
  end
})

return sizhou
