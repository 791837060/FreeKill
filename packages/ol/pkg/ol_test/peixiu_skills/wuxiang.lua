local wuxiang = fk.CreateSkill {
  name = "peixiu__wuxiang",
}

Fk:loadTranslationTable {
  ["peixiu_wuxiang"] = "武乡",
  [":peixiu_wuxiang"] = "你获得此技能后，从牌堆中获得一张【火攻】。",
}

wuxiang:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == wuxiang.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    local card = room:printCard("fire_attack", Card.Heart, 2)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, wuxiang.name, nil, true, player)
  end
})

return wuxiang
