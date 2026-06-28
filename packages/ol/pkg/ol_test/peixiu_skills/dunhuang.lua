local dunhuang = fk.CreateSkill {
  name = "peixiu__dunhuang",
}

Fk:loadTranslationTable {
  ["peixiu_dunhuang"] = "敦煌",
  [":peixiu_dunhuang"] = "你的【杀】被抵消后，你摸一张牌。",
}

dunhuang:addEffect(fk.CardResponded, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if data.from ~= player then return false end
    if data.card.trueName ~= "slash" then return false end
    return true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})

return dunhuang
