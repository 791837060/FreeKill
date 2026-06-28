
local yinzhi = fk.CreateSkill{
  name = "yinzhi",
}

Fk:loadTranslationTable{
  ["yinzhi"] = "阴鸷",
  [":yinzhi"] = "出牌阶段限一次，你可以选择一名其他角色并摸X张牌，该角色所有非锁定技失效直至其回合开始，且在此期间，"..
  "其每次使用或打出手牌后你摸X张牌（X为本局游戏你对其发动〖阴鸷〗的次数且至多为3）。然后其回合内只能使用或打出本回合获得的牌，"..
  "若其对你造成伤害，则此效果消失且X对其重置。",

  ["#yinzhi"] = "阴鸷：选择一名角色，摸牌并令其非锁定技失效，直至其回合开始",
  ["@@yinzhi"] = "阴鸷",

  ["$yinzhi1"] = "",
  ["$yinzhi2"] = "",
}

yinzhi:addEffect("active", {
  anim_type = "control",
  prompt = "#yinzhi",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(yinzhi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  target_tip = function (self, player, to_select, selected, selected_cards, card, selectable, extra_data)
    if selectable then
      local n = (player:getTableMark(yinzhi.name)[to_select] or 0) + 1
      return "draw"..n
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local mark = player:getTableMark(yinzhi.name)
    local n = mark[target] or 0
    if n < 3 then
      n = n + 1
    end
    mark[target] = n
    room:setPlayerMark(player, yinzhi.name, mark)
    room:addTableMarkIfNeed(target, "@@yinzhi", player)
    player:drawCards(n, yinzhi.name)
  end,
})

local spec = {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(yinzhi.name) and
      table.contains(target:getTableMark("@@yinzhi"), player) and
      (player:getTableMark(yinzhi.name)[target] or 0) > 0 and
      data:isUsingHandcard(target)
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(player:getTableMark(yinzhi.name)[target], yinzhi.name)
  end,
}
yinzhi:addEffect(fk.CardUseFinished, spec)
yinzhi:addEffect(fk.CardRespondFinished, spec)

yinzhi:addEffect(fk.Damage, {
  can_refresh = function (self, event, target, player, data)
    return target == player and
      (table.contains(player:getTableMark("yinzhi-turn"), data.to))
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:removeTableMark(player, "yinzhi-turn", data.to)
    local mark = data.to:getTableMark(yinzhi.name)
    mark[player] = 0
    room:setPlayerMark(data.to, yinzhi.name, mark)
  end,
})

yinzhi:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@@yinzhi") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "yinzhi-turn", player:getMark("@@yinzhi"))
    room:setPlayerMark(player, "@@yinzhi", 0)
  end,
})

yinzhi:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if player:getMark("yinzhi-turn") ~= 0 and player.room:getCurrent() == player then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand then
          return true
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player:getCardIds("h"), info.cardId) then
            room:setCardMark(Fk:getCardById(info.cardId), "yinzhi-turn-inhand", 1)
          end
        end
      end
    end
  end,
})

yinzhi:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if player:getMark("yinzhi-turn") ~= 0 then
      local cardIds = Card:getIdList(card)
      return table.find(cardIds, function(id)
        return Fk:getCardById(id):getMark("yinzhi-turn-inhand") == 0 and table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("yinzhi-turn") ~= 0 then
      local cardIds = Card:getIdList(card)
      return table.find(cardIds, function(id)
        return Fk:getCardById(id):getMark("yinzhi-turn-inhand") == 0 and table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
})

yinzhi:addEffect("invalidity", {
  invalidity_func = function (self, from, skill)
    return from:getMark("@@yinzhi") ~= 0 and
      not skill:hasTag(Skill.Compulsory) and skill:isPlayerSkill(from)
  end,
})

return yinzhi
