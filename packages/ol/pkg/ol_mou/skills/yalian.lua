local yalian = fk.CreateSkill {
  name = "yalian",
}

Fk:loadTranslationTable{
  ["yalian"] = "牙镰",
  [":yalian"] = "每阶段结束时，若你此阶段不因使用失去过【杀】，你可以视为对任意名手牌数小于等于X的角色使用一张火【杀】"..
  "（X为本回合弃牌堆中【杀】的数量且至少为1）。",

  ["#yalian-choose"] = "牙镰：你可以视为对任意名角色使用一张火【杀】",
}

yalian:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yalian.name) and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.from == player then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand and info.beforeCard.trueName == "slash" then
                return true
              end
            end
          end
        end
      end, Player.HistoryPhase) > 0 then
      local cards = {}
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              if table.contains(player.room.discard_pile, info.cardId) and Fk:getCardById(info.cardId).trueName == "slash" then
                table.insertIfNeed(cards, info.cardId)
              end
            end
          end
        end
      end, Player.HistoryPhase)
      local n = math.max(#cards, 1)
      local card = Fk:cloneCard("fire__slash")
      card.skillName = yalian.name
      if table.find(player.room:getOtherPlayers(player, false), function (p)
        return p:getHandcardNum() <= n and player:canUseTo(card, p, { bypass_distances = true, bypass_times = true })
      end) then
        event:setCostData(self, { extra_data = n })
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = event:getCostData(self).extra_data
    local card = Fk:cloneCard("fire__slash")
    card.skillName = yalian.name
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:getHandcardNum() <= n and player:canUseTo(card, p, { bypass_distances = true, bypass_times = true })
    end)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = #targets,
      prompt = "#yalian-choose",
      skill_name = yalian.name,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useVirtualCard("fire__slash", {}, player, event:getCostData(self).tos, yalian.name, true)
  end,
})

return yalian
