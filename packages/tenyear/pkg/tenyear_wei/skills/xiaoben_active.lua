local xiaoben = fk.CreateSkill{
  name = "xiaoben_active",
}

Fk:loadTranslationTable{
  ["xiaoben_active"] = "骁贲",
}

xiaoben:addEffect("active", {
  card_num = 0,
  target_num = 2,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      return to_select:getMark("@heqim") > 0
    else
      return #selected == 1
    end
  end
})

return xiaoben
