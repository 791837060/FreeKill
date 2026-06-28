local wuwei = fk.CreateSkill {
  name = "peixiu__wuwei",
}

Fk:loadTranslationTable {
  ["peixiu_wuwei"] = "武威",
  [":peixiu_wuwei"] = "你使用伤害牌可以额外指定一个目标（每回合限一次）。",
}

wuwei:addEffect("targetmod", {
  extra_target_func = function(self, player, skill, scope, card, to)
    if not player:hasSkill(self.name) then return 0 end
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return 0 end
    if card and card.isDamageTrick or card.trueName == "slash" then
      return 1
    end
    return 0
  end,
})

return wuwei
