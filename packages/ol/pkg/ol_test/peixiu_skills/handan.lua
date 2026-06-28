local handan = fk.CreateSkill {
  name = "peixiu__handan",
}

Fk:loadTranslationTable {
  ["peixiu_handan"] = "邯郸",
  [":peixiu_handan"] = "你使用一张非伤害普通锦囊牌后，你令一名角色获得此牌（每回合限一次）。",

  ["#peixiu_handan-choose"] = "邯郸：选择一名角色，令其获得此牌",
}

handan:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(self.name) then return false end
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    local card = data.card
    if card.type ~= Card.TypeTrick then return false end
    if card.isDamageTrick then return false end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room.alive_players
    local to
    if #targets == 1 then
      to = targets[1]
    else
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = self.name,
        prompt = "#peixiu_handan-choose",
      })
      if #tos == 0 then return end
      to = tos[1]
    end
    room:moveCardTo(data.card, Card.PlayerHand, to, fk.ReasonGive, self.name, nil, false, player)
  end,
})

return handan
