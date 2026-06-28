local julu = fk.CreateSkill {
  name = "peixiu__julu",
}

Fk:loadTranslationTable {
  ["peixiu_julu"] = "巨鹿",
  [":peixiu_julu"] = "你失去黑桃2~9的牌后，你摸一张牌（每回合限一次）。",
}

julu:addEffect(fk.CardLost, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(self.name) then return false end
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    for _, id in ipairs(data) do
      local card = Fk:getCardById(id)
      if card.suit == Card.Spade and card.number >= 2 and card.number <= 9 then
        return true
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
})

return julu
