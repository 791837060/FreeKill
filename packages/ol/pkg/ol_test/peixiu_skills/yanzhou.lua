local yanzhou = fk.CreateSkill {
  name = "peixiu__yanzhou",
}

Fk:loadTranslationTable {
  ["peixiu_yanzhou"] = "兖州",
  [":peixiu_yanzhou"] = "你回复体力后，你摸一张牌（每回合限一次）。",
}

yanzhou:addEffect(fk.HpRecovered, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(self.name) then return false end
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    return true
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})

return yanzhou
