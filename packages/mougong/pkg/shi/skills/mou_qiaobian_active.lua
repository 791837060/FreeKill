local qiaobian_active = fk.CreateSkill {
  name = "#mou__qiaobian_active",
}

Fk:loadTranslationTable{
  ["#mou__qiaobian_active"] = "巧变",
}

qiaobian_active:addEffect("active", {
  min_card_num = 1,
  max_card_num = 3,
  target_num = 0,
  expand_pile = function (self, player)
    return player:getCardIds("j")
  end,
  card_filter = function (self, player, to_select, selected)
    return not player:prohibitDiscard(to_select) and
      not table.find(selected, function (id)
        return Fk:currentRoom():getCardArea(id) == Fk:currentRoom():getCardArea(to_select)
      end)
  end,
})

return qiaobian_active
