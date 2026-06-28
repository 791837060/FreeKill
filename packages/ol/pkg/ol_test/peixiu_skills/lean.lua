local lean = fk.CreateSkill {
  name = "peixiu__lean",
}

Fk:loadTranslationTable {
  ["peixiu_lean"] = "乐安",
  [":peixiu_lean"] = "你获得此技能后，从牌堆获得一张属性【杀】和一张【铁索连环】。",
}

lean:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == lean.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end

    local cards = {}
    local fire_slash = room:printCard("fire_slash", Card.Heart, 11)
    table.insert(cards, fire_slash)
    local iron_chain = room:printCard("iron_chain", Card.Club, 12)
    table.insert(cards, iron_chain)

    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, lean.name, nil, true, player)
  end
})

return lean
