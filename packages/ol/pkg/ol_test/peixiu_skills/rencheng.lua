local rencheng = fk.CreateSkill {
  name = "peixiu__rencheng",
}

Fk:loadTranslationTable {
  ["peixiu_rencheng"] = "任城",
  [":peixiu_rencheng"] = "你每有一张【杀】，手牌上限便+1。",
}

rencheng:addEffect("maxcards", {
  correct_func = function(self, player)
    if not player:hasSkill(rencheng.name) then return 0 end
    local slash_count = 0
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if card.trueName == "slash" then
        slash_count = slash_count + 1
      end
    end
    return slash_count
  end,
})

return rencheng
