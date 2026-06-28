local weiti_active = fk.CreateSkill {
  name = "weiti_active",
}

Fk:loadTranslationTable{
  ["weiti_active"] = "伪涕",
}

weiti_active:addEffect("active", {
  card_num = 2,
  target_num = 0,
  card_filter = function (self, player, to_select, selected)
    return not player:prohibitDiscard(to_select) and
      not table.find(selected, function (id)
        return Fk:getCardById(id).number == Fk:getCardById(to_select).number
      end)
  end,
})

return weiti_active
