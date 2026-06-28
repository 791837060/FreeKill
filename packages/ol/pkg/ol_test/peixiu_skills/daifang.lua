local daifang = fk.CreateSkill {
  name = "peixiu__daifang",
}

Fk:loadTranslationTable {
  ["peixiu_daifang"] = "带方",
  [":peixiu_daifang"] = "你的属性【杀】不能被响应。",
}

daifang:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    if card and card.trueName == "fire_slash" or card.trueName == "thunder_slash" then
      return true
    end
    return false
  end,
})

return daifang
