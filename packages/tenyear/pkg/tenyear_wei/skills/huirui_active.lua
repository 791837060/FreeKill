local huirui = fk.CreateSkill{
  name = "huirui_active",
}

Fk:loadTranslationTable{
  ["huirui_active"] = "挥锐",
}

huirui:addEffect("active", {
  interaction = function(self, player)
    local all_choices = { "huirui_gain", "huirui_move", "huirui_slash" }
    local choices = table.simpleClone(all_choices)
    if table.every(Fk:currentRoom().alive_players, function(p)
      return p:getMark("@heqim") == 0
    end) then
      table.remove(choices, 2)
    end
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if self.interaction.data == "huirui_move" then
      if #selected == 0 then
        return to_select:getMark("@heqim") > 0
      else
        return #selected == 1 and to_select ~= player
      end
    elseif self.interaction.data == "huirui_slash" then
      --使用【杀】有距离限制且仅可指定1个目标
      local slash = Fk:cloneCard("slash")
      slash.skillName = "huirui"
      return player:canUseTo(slash, to_select, { bypass_times = true })
    end
  end,
  feasible = function(self, player, selected, selected_cards, card)
    if self.interaction.data == "huirui_move" then
      return #selected == 2
    elseif self.interaction.data == "huirui_slash" then
      return #selected == 1
    end
    return true
  end
})

return huirui
