local renche = fk.CreateSkill {
  name = "renche",
}

Fk:loadTranslationTable{
  ["renche"] = "刃掣",
  [":renche"] = "出牌阶段限X次，你可以弃置X张牌并令至多X名其他角色各弃置一张牌（X为本回合弃牌堆中【杀】的数量且至少为1）。"..
  "每有角色因此弃置牌不为【杀】，你便摸一张牌。",

  ["#renche"] = "刃掣：弃置%arg张牌，令至多%arg名其他角色各弃置一张牌",
  ["#renche-discard"] = "刃掣：弃置一张牌，若不为【杀】，%src 摸一张牌",

  ["#renche1"] = "",
  ["#renche2"] = "",
}

renche:addEffect("active", {
  anim_type = "control",
  prompt = function (self, player)
    return "#renche:::"..math.max(#player:getTableMark("renche-phase"), 1)
  end,
  times = function(self, player)
    return player.phase == Player.Play and
      math.max(#player:getTableMark("renche-phase"), 1) - player:usedSkillTimes(renche.name, Player.HistoryPhase) or -1
  end,
  card_num = function (self, player)
    return math.max(#player:getTableMark("renche-phase"), 1)
  end,
  min_target_num = 1,
  max_target_num = function (self, player)
    return math.max(#player:getTableMark("renche-phase"), 1)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(renche.name, Player.HistoryPhase) < math.max(#player:getTableMark("renche-phase"), 1)
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected < math.max(#player:getTableMark("renche-phase"), 1) and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected < math.max(#player:getTableMark("renche-phase"), 1) and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:sortByAction(effect.tos)
    room:throwCard(effect.cards, renche.name, player, player)
    for _, p in ipairs(effect.tos) do
      if not p.dead then
        local card = room:askToDiscard(p, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = renche.name,
          prompt = "#renche-discard:"..player.id,
          cancelable = false,
          skip = true,
        })
        if #card > 0 then
          card = Fk:getCardById(card[1])
          room:throwCard(card, renche.name, p, p)
          if card.trueName ~= "slash" and not player.dead then
            player:drawCards(1, renche.name)
          end
        end
      end
    end
  end,
})

renche:addEffect(fk.AfterCardsMove, {
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(renche.name, true) and player.phase == Player.Play
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local cards = player:getTableMark("renche-phase")
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).trueName =="slash" then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    cards = table.filter(cards, function (id)
      return table.contains(room.discard_pile, id)
    end)
    room:setPlayerMark(player, "renche-phase", cards)
  end
})

renche:addAcquireEffect(function(self, player)
  if player.phase == Player.Play then
    local room = player.room
    local cards = {}
    room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).trueName == "slash" and table.contains(room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end, nil, Player.HistoryPhase)
    room:setPlayerMark(player, "renche-phase", cards)
  end
end)

return renche
