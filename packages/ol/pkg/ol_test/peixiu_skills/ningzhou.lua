local ningzhou = fk.CreateSkill {
  name = "peixiu__ningzhou",
}

Fk:loadTranslationTable {
  ["peixiu_ningzhou"] = "宁州",
  [":peixiu_ningzhou"] = "你使用的【杀】不能被抵消，且造成的伤害均视为体力流失。",
}

ningzhou:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    if card and card.trueName == "slash" then
      return true
    end
    return false
  end,
})

ningzhou:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(self.name) then return false end
    if data.card and data.card.trueName == "slash" then
      return true
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(data.to, data.damage, self.name)
    return true
  end,
})

return ningzhou
