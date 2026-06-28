local lianyou = fk.CreateSkill {
  name = "#lianyou_active",
}

Fk:loadTranslationTable {
  ["#lianyou_active"] = "怜幼",
}

lianyou:addEffect("active", {
  card_num = 0,
  min_target_num = 0,
  max_target_num = 1,
  interaction = function(self, player)
    local choices, all_choices = {}, {}
    for _, choice in ipairs({ "lianyou_recover", "lianyou_equip", "lianyou_draw" }) do
      table.insert(all_choices, choice)
      if Fk.skills["lianyou"]:getSkeleton():withinBranchTimesLimit(player, choice, Player.HistoryRound) then
        table.insert(choices, choice)
      end
    end
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected == 0 then
      if self.interaction.data == "lianyou_recover" then
        return to_select:isWounded() and
            table.every(Fk:currentRoom().alive_players, function(p)
              return p.hp >= to_select.hp
            end)
      elseif self.interaction.data == "lianyou_equip" then
        return table.every(Fk:currentRoom().alive_players, function(p)
          return #p:getCardIds("e") >= #to_select:getCardIds("e")
        end)
      elseif self.interaction.data == "lianyou_draw" then
        return false
      end
    end
  end,
  feasible = function(self, player, selected, selected_cards, card)
    if self.interaction.data == "lianyou_recover" then
      return #selected == 1
    elseif self.interaction.data == "lianyou_equip" then
      return #selected == 1
    elseif self.interaction.data == "lianyou_draw" then
      return #selected == 0
    end
  end,
})

return lianyou
