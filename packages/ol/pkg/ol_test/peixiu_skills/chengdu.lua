local chengdu = fk.CreateSkill {
  name = "peixiu__chengdu",
}

Fk:loadTranslationTable {
  ["peixiu_chengdu"] = "成都",
  [":peixiu_chengdu"] = "你对自己使用牌后，你摸一张牌（每回合限一次）。",
}

chengdu:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    if not player:hasSkill(self.name) then return false end
    return table.contains(data.tos, player.id)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})

return chengdu
