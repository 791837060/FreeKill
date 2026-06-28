local fufeng = fk.CreateSkill {
  name = "peixiu__fufeng",
}

Fk:loadTranslationTable {
  ["peixiu_fufeng"] = "扶风",
  [":peixiu_fufeng"] = "你获得此技能后，从牌堆获得一张你手牌中未拥有类型的牌。",
}

fufeng:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == fufeng.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end

    local types = {}
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      types[card.type] = true
    end

    local all_types = {Card.TypeBasic, Card.TypeTrick, Card.TypeEquip}
    local missing_types = table.filter(all_types, function(t)
      return not types[t]
    end)
    if #missing_types == 0 then return end

    local cards = room:getNCards(1)
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, fufeng.name, nil, true, player)
    room:cleanProcessingArea(cards)
  end
})

return fufeng
