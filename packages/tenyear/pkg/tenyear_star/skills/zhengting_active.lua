
local zhengting_active = fk.CreateSkill {
  name = "#zhengting_active",
}

Fk:loadTranslationTable{
  ["#zhengting_active"] = "正听",
}

local getCount = function (player)
  local ret = {}
  for _, id in ipairs(player:getCardIds("h")) do
    local suit = Fk:getCardById(id):getSuitString()
    ret[suit] = ret[suit] or {}
    table.insert(ret[suit], id)
  end
  return ret
end

zhengting_active:addEffect("active", {
  card_filter = function(self, player, to_select, selected)
    return table.contains(player:getCardIds("h"), to_select) and not player:prohibitDiscard(to_select) and
      #getCount(player)[Fk:getCardById(to_select):getSuitString()] > 1 and
      table.find(getCount(player)[Fk:getCardById(to_select):getSuitString()], function (id)
        return id ~= to_select and not table.contains(selected, id)
      end)
  end,
  feasible = function (self, player, selected, selected_cards)
    local ret = getCount(player)
    for suit, _ in pairs(ret) do
      for _, id in ipairs(selected_cards) do
        table.removeOne(ret[suit], id)
      end
    end
    for _, ids in pairs(ret) do
      if #ids > 1 and table.find(ids, function (id)
        return not player:prohibitDiscard(id)
      end) then
        return false
      end
    end
    return true
  end,
})

return zhengting_active
