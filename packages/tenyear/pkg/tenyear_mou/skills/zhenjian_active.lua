local zhenjian_active = fk.CreateSkill {
  name = "#zhenjian_active",
}

Fk:loadTranslationTable{
  ["#zhenjian_active"] = "缜鉴",
}

zhenjian_active:addEffect("active", {
  interaction = function(self, player)
    return UI.ComboBox { choices = Fk:getAllCardNames("t") }
  end,
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
})

return zhenjian_active
