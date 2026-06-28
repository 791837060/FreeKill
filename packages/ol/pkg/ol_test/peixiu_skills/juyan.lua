local juyan = fk.CreateSkill {
  name = "peixiu__juyan",
}

Fk:loadTranslationTable {
  ["peixiu_juyan"] = "居延",
  [":peixiu_juyan"] = "你获得此技能后，从牌堆中获得三张攻击范围各不相同的武器牌。",
}

juyan:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == juyan.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end

    local weapons = {}
    for _, id in ipairs(room.draw_pile) do
      local card = Fk:getCardById(id)
      if card.sub_type == Card.SubtypeWeapon then
        local range = card:getNumberValue()
        local exists = false
        for _, w in ipairs(weapons) do
          if Fk:getCardById(w):getNumberValue() == range then
            exists = true
            break
          end
        end
        if not exists then
          table.insert(weapons, id)
        end
      end
    end

    local cards = room:tableRandomPick(weapons, 3)
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, juyan.name, nil, true, player)
    end
  end
})

return juyan
