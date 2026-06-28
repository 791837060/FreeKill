
local youyiw_active = fk.CreateSkill {
  name = "#youyiw_active",
}

Fk:loadTranslationTable{
  ["#youyiw_active"] = "诱夷",
}

youyiw_active:addEffect("active", {
  interaction = function(self, player)
    return UI.Spin {
      from = 1,
      to = math.min(3, player.hp),
    }
  end,
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected == 0
  end,
})

return youyiw_active
