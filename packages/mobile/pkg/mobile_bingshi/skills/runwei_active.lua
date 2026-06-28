local runwei_active = fk.CreateSkill{
  name = "mobile__runwei_active",
}

Fk:loadTranslationTable{
  ["mobile__runwei_active"] = "润微",
}

runwei_active:addEffect("active", {
  card_num = 0,
  target_num = 1,
  interaction = function(self)
    return UI.ComboBox { choices = self.mobile__runwei_choices, all_choices = {"red", "black"} }
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and not table.contains(self.mobile__runwei_disabled, to_select.id)
  end,
  target_tip = function(self, player, to_select, selected, selected_cards, card, selectable, extra_data)
    if table.contains(self.mobile__runwei_disabled, to_select.id) then
      return { {content = "mobile__runwei_disabled", type = "warning"} }
    end
  end
})

return runwei_active
