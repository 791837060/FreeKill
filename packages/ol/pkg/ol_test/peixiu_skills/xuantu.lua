local xuantu = fk.CreateSkill {
  name = "peixiu__xuantu",
}

Fk:loadTranslationTable {
  ["peixiu_xuantu"] = "玄菟",
  [":peixiu_xuantu"] = "有角色进入濒死状态时，你获得使其进入此濒死状态的牌（每回合限一次）。",
}

xuantu:addEffect(fk.AskForPeaches, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    if not data.damage or not data.damage.card then return false end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.damage.card
    if type(card) == "number" then
      card = Fk:getCardById(card)
    end
    if card and not card:isVirtual() then
      room:moveCardTo(card.id, Card.PlayerHand, player, fk.ReasonPrey, self.name, "", false, target)
    end
  end,
})

return xuantu
