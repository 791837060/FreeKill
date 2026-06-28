local chengchong_active = fk.CreateSkill {
  name = "chengchong_active",
}

Fk:loadTranslationTable{
  ["chengchong_active"] = "承宠",
}

chengchong_active:addEffect("active", {
  card_num = 1,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 and table.contains(player:getCardIds("h"), to_select) then
      local card = Fk:getCardById(to_select)
      return card.color == Card.Black and #card:getDefaultTarget(player, {
        bypass_distances = true,
        bypass_times = true,
        exclusive_targets = table.map(Fk:currentRoom().alive_players, function(p)
          if p ~= player then
            return p.id
          end
          return nil
        end)
      }) > 0
    end
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    if #selected_cards == 1 then
      local card = Fk:getCardById(selected_cards[1])
      if card.skill:getMinTargetNum(player) < 2 then
        return #selected == 0 and to_select ~= player and
          table.contains(card:getAvailableTargets(player, { bypass_distances = true, bypass_times = true }), to_select)
      else
        if #selected == 0 and to_select == player then return false end
        return card.skill:targetFilter(player, to_select, selected, {}, card,
          { bypass_distances = true, bypass_times = true })
      end
    end
  end,
  feasible = function(self, player, selected, selected_cards)
    if #selected_cards ~= 1 then return false end
    local card = Fk:getCardById(selected_cards[1])
    if card.skill:getMinTargetNum(player) < 2 then
      return #selected == 1
    else
      return card.skill:feasible(player, selected, {}, card)
    end
  end,
})

return chengchong_active
