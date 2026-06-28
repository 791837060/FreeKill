local yizhou = fk.CreateSkill {
  name = "peixiu__yizhou",
}

Fk:loadTranslationTable {
  ["peixiu_yizhou"] = "益州",
  [":peixiu_yizhou"] = "你不能成为延时锦囊牌的目标。",
}

yizhou:addEffect(fk.TargetConfirming, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(self.name) then return false end
    local card = data.card
    if card and card.type == Card.TypeTrick and card.isDelayTrick then
      return true
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    return true
  end,
})

return yizhou
