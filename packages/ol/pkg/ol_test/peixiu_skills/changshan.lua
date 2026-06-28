local changshan = fk.CreateSkill {
  name = "peixiu__changshan",
}

Fk:loadTranslationTable {
  ["peixiu_changshan"] = "常山",
  [":peixiu_changshan"] = "你从牌堆中获得两张【闪】。",
}

changshan:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == changshan.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    local cards = room:getNCards(2)
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, changshan.name, nil, true, player)
    room:cleanProcessingArea(cards)
  end
})

return changshan
