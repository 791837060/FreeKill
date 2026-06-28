local huangnu = fk.CreateSkill{
  name = "huangnu_active",
}

Fk:loadTranslationTable{
  ["huangnu_active"] = "煌怒",
}

huangnu:addEffect("active", {
  interaction = function(self, player)
    return UI.ComboBox { choices = { "basic", "trick", "equip" } }
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 1,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and not to_select:isNude()
  end,
})

return huangnu
