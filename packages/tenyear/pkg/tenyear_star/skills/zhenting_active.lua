local zhenting_active = fk.CreateSkill{
  name = "#ty__zhenting_active",
}

Fk:loadTranslationTable{
  ["#ty__zhenting_active"] = "镇庭",
  ["ty__zhenting_recover"] = "回复体力并摸牌",
  ["ty__zhenting_card"] = "获得弃牌堆两张牌",
}

zhenting_active:addEffect("active", {
  card_num = 0,
  target_num = 1,
  interaction = UI.ComboBox { choices = { "ty__zhenting_recover", "ty__zhenting_card" } },
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      if self.interaction.data == "ty__zhenting_recover" then
        return table.contains(self.tos or {}, to_select.id)
      else
        return table.contains(self.froms or {}, to_select.id)
      end
    end
  end,
})

return zhenting_active
