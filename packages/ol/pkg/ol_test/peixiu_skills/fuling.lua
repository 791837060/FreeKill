local fuling = fk.CreateSkill {
  name = "peixiu__fuling",
}

Fk:loadTranslationTable {
  ["peixiu_fuling"] = "涪陵",
  [":peixiu_fuling"] = "你的装备牌不能被其他角色弃置。",
}

fuling:addEffect("targetmod", {
  card_filter = function(self, player, card)
    if card and card:isType(Card.TypeEquip) and player:hasSkill(self.name) then
      return false
    end
    return true
  end,
})

return fuling
