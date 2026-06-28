local wudu = fk.CreateSkill {
  name = "peixiu__wudu",
}

Fk:loadTranslationTable {
  ["peixiu_wudu"] = "武都",
  [":peixiu_wudu"] = "你使用牌无次数限制。",
}

wudu:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return true
  end,
})

return wudu
