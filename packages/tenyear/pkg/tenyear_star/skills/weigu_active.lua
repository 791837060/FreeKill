
local weigu_active = fk.CreateSkill {
  name = "#weigu_active",
}

Fk:loadTranslationTable{
  ["#weigu_active"] = "维谷",
}

weigu_active:addEffect("active", {
  interaction = function (self, player)
    local choices = { "weigu_add" }
    if player:getMark("@@juefa") > 0 then
      table.insert(choices, 1, "weigu_damage")
    else
      table.insert(choices, 1, "weigu_move")
    end
    return UI.ComboBox { choices = choices }
  end,
  card_num = 0,
  min_target_num = 0,
  max_target_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected, selected_cards, card, extra_data)
    if self.interaction.data == "weigu_damage" then
      return #selected == 0
    elseif self.interaction.data == "weigu_move" then
      if #selected == 0 then
        return #to_select:getCardIds("ej") > 0
      elseif #selected == 1 then
        return table.find(selected[1]:getCardIds("ej"), function (id)
          return selected[1]:canMoveCardInBoardTo(to_select, id)
        end)
      end
    elseif self.interaction.data == "weigu_add" then
      return false
    end
  end,
  feasible = function (self, player, selected, selected_cards, card)
    if self.interaction.data == "weigu_damage" then
      return #selected == 1
    elseif self.interaction.data == "weigu_move" then
      return #selected == 2
    elseif self.interaction.data == "weigu_add" then
      return #selected == 0
    end
  end,
})

return weigu_active
