local wenxi = fk.CreateSkill {
  name = "peixiu__wenxi",
}

Fk:loadTranslationTable {
  ["peixiu_wenxi"] = "闻喜",
  [":peixiu_wenxi"] = "你每回合首次使用一个花色的牌后，你摸一张牌。",
}

wenxi:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(self.name) then return false end
    local suit = data.card.suit
    if suit == Card.NoSuit then return false end
    local mark_name = "@@peixiu_wenxi_" .. tostring(suit)
    if player:getMark(mark_name) > 0 then return false end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local suit = data.card.suit
    local mark_name = "@@peixiu_wenxi_" .. tostring(suit)
    player.room:setPlayerMark(player, mark_name, 1)
    player:drawCards(1, self.name)
  end,
})

wenxi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if player.phase ~= Player.RoundStart then return false end
    if not player:hasSkill(self.name) then return false end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for suit = 0, 3 do
      room:setPlayerMark(player, "@@peixiu_wenxi_" .. tostring(suit), 0)
    end
  end,
})

return wenxi
