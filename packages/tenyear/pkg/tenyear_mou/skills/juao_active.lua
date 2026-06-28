
local juao_active = fk.CreateSkill {
  name = "#juao_active",
}

Fk:loadTranslationTable{
  ["#juao_active"] = "倨傲",
}

juao_active:addEffect("active", {
  expand_pile = function(self, player)
    return Fk:currentRoom():getBanner("juao")
  end,
  card_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(Fk:currentRoom():getBanner("juao"), to_select)
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    if #selected_cards == 1 then
      local card = Fk:cloneCard(Fk:getCardById(selected_cards[1]).name)
      card.skillName = "juao"
      return player:inMyAttackRange(to_select) and
        card.skill:modTargetFilter(player, to_select, selected, card, { bypass_distances = true, bypass_times = true })
    end
  end,
  feasible = function(self, player, selected, selected_cards)
    return #selected_cards == 1 and #selected > 0
  end,
})

return juao_active
