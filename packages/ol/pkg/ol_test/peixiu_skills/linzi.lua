local linzi = fk.CreateSkill {
  name = "peixiu__linzi",
}

Fk:loadTranslationTable {
  ["peixiu_linzi"] = "临淄",
  [":peixiu_linzi"] = "你获得此技能后，获得弃牌堆中三张随机的梅花牌。",
}

linzi:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == linzi.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end

    local club_cards = {}
    for _, id in ipairs(room.discard_pile) do
      local card = Fk:getCardById(id)
      if card.suit == Card.Club then
        table.insert(club_cards, id)
      end
    end

    if #club_cards == 0 then return end
    local cards = room:tableRandomPick(club_cards, math.min(3, #club_cards))
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, linzi.name, nil, true, player)
  end
})

return linzi
