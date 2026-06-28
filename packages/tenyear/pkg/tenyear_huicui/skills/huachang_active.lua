local huachang_active = fk.CreateSkill {
  name = "#huachang_active",
}

Fk:loadTranslationTable {
  ["#huachang_active"] = "华裳",
}

huachang_active:addEffect("active", {
  card_num = 1,
  target_num = 0,
  interaction = function(self, player)
    return UI.ComboBox { choices = player:getAvailableEquipSlots() }
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select) and
      Fk:getCardById(to_select).type ~= Card.TypeEquip and
      Fk:getCardById(to_select).suit == self.suit
  end,
})

return huachang_active
