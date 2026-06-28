local peixian = fk.CreateSkill {
  name = "peixiu__peixian",
}

Fk:loadTranslationTable {
  ["peixiu_peixian"] = "沛县",
  [":peixiu_peixian"] = "你的普通锦囊牌不能被响应。",
}

peixian:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    if card and card.type == Card.TypeTrick and not card.isDamageTrick then
      return true
    end
    return false
  end,
})

return peixian
