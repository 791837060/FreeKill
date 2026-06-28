local longxi = fk.CreateSkill {
  name = "peixiu__longxi",
}

Fk:loadTranslationTable {
  ["peixiu_longxi"] = "陇西",
  [":peixiu_longxi"] = "你获得此技能后，从牌堆中获得一张防御坐骑牌。",
}

longxi:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == longxi.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end

    local def_horses = {}
    for _, id in ipairs(room.draw_pile) do
      local card = Fk:getCardById(id)
      if card.sub_type == Card.SubtypeDefensiveRide then
        table.insert(def_horses, id)
      end
    end

    if #def_horses == 0 then return end
    local cards = room:tableRandomPick(def_horses, 1)
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, longxi.name, nil, true, player)
  end
})

return longxi
