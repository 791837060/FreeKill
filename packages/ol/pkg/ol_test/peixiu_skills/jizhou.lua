local jizhou = fk.CreateSkill {
  name = "peixiu__jizhou",
}

Fk:loadTranslationTable {
  ["peixiu_jizhou"] = "冀州",
  [":peixiu_jizhou"] = "你获得此技能后，从牌堆获得一张【万箭齐发】。",
}

jizhou:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == jizhou.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    local card = room:printCard("savage_assault", Card.Spade, 7)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, jizhou.name, nil, true, player)
  end
})

return jizhou
