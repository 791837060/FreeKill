local mengshiSelect = fk.CreateSkill {
  name = "#mengshi_select",
}

Fk:loadTranslationTable{
  ["#mengshi_select"] = "盟势",
}

mengshiSelect:addEffect("active", {
  card_num = 0,
  target_num = 2,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected > 0 and to_select.hp == selected[1].hp then
      return false
    end

    return #selected < 2 and to_select ~= player
  end,
})

return mengshiSelect
