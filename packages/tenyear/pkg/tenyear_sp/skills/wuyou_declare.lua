local wuyou_declare = fk.CreateSkill {
  name = "wuyou_declare",
}

Fk:loadTranslationTable {
  ["wuyou_declare"] = "武佑",
}

wuyou_declare:addEffect("active", {
  card_num = 1,
  target_num = 0,
  interaction = function(self, player)
    return UI.CardNameBox { choices = self.interaction_choices }
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
})

return wuyou_declare
