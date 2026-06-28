local pingyuan = fk.CreateSkill {
  name = "peixiu__pingyuan",
}

Fk:loadTranslationTable {
  ["peixiu_pingyuan"] = "平原",
  [":peixiu_pingyuan"] = "你失去最后的手牌后，你摸一张牌（每回合限一次）。",
}

pingyuan:addEffect(fk.CardLost, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(self.name) then return false end
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    if player:isKongcheng() then
      return true
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})

return pingyuan
