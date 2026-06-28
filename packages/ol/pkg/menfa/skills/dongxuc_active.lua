local dongxuc_active = fk.CreateSkill {
  name = "#dongxuc_active",
}

Fk:loadTranslationTable{
  ["#dongxuc_active"] = "动虚",
}

dongxuc_active:addEffect("active", {
  card_num = 1,
  target_num = 1,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and #selected_cards == 1 and
      to_select:canMoveCardIntoEquip(selected_cards[1], true)
  end,
})

return dongxuc_active
