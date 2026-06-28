local taishan = fk.CreateSkill {
  name = "peixiu__taishan",
}

Fk:loadTranslationTable {
  ["peixiu_taishan"] = "泰山",
  [":peixiu_taishan"] = "获得此技能后，将一张【螭纹玉佩】置入手牌。",
}

taishan:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == taishan.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    local card = room:printCard("chiwen_peiyao", Card.Diamond, 1)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, taishan.name, nil, true, player)
  end
})

return taishan
