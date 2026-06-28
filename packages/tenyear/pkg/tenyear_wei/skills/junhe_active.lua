local junhe_active = fk.CreateSkill {
  name = "#junhe_active",
}

Fk:loadTranslationTable{
  ["#junhe_active"] = "军合",
}

junhe_active:addEffect("active", {
  min_card_num = 1,
  target_num = 0,
  card_filter = function (self, player, to_select, selected)
    if #selected > 0 then
      local colors, types = {}, {}
      for _, id in ipairs(selected) do
        table.insertIfNeed(colors, Fk:getCardById(id).color)
        table.insertIfNeed(types, Fk:getCardById(id).type)
      end
      if #colors > 1 then
        return Fk:getCardById(to_select).type == types[1]
      end
      if #types > 1 then
        return Fk:getCardById(to_select).color == colors[1]
      end
      return table.contains(colors, Fk:getCardById(to_select).color) or
        table.contains(types, Fk:getCardById(to_select).type)
    else
      return Fk:getCardById(to_select).color ~= Card.NoColor
    end
  end,
})

return junhe_active
