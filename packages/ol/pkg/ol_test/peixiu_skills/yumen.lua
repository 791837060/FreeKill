local yumen = fk.CreateSkill {
  name = "peixiu__yumen",
}

Fk:loadTranslationTable {
  ["peixiu_yumen"] = "玉门",
  [":peixiu_yumen"] = "已连环的角色不能响应你的牌。",
}

yumen:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    if to and to:isChained() then
      return true
    end
    return false
  end,
})

return yumen
