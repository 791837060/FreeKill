local zeguang = fk.CreateSkill{
  name = "zeguang",
}

Fk:loadTranslationTable{
  ["zeguang"] = "泽光",
  [":zeguang"] = "每回合限一次，当你成为伤害牌的目标后，你可以重铸三张牌（不足则全部重铸）。然后若此牌造成伤害，你可以令一名角色获得重铸牌。",

  ["#zeguang-card"] = "泽光：可重铸三张牌，若此牌造成伤害，可以令一名角色获得重铸牌",
  ["#zeguang-invoke"] = "泽光：可重铸所有牌，若此牌造成伤害，可以令一名角色获得重铸牌",
  ["#zeguang-choose"] = "泽光：你可以令一名角色获得你重铸的牌",

  ["$zeguang1"] = "且行且过，深宫之内亦有暖阳。",
  ["$zeguang2"] = "执灯映寒雪，长夜虽漫，可待春晖。",
}

zeguang:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  max_turn_use_time = 1,
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(zeguang.name) and
      data.card.is_damage_card and player.room:getCurrent() and
      self:withinTimesLimit(player) and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local n = #player:getCardIds("he")
    local cards = {}
    if n > 3 then
      cards = player.room:askToCards(player, {
        skill_name = zeguang.name,
        min_num = 3,
        max_num = 3,
        include_equip = true,
        prompt = "#zeguang-card",
        cancelable = true,
      })
    elseif player.room:askToSkillInvoke(player, {
      skill_name = zeguang.name,
      prompt = "#zeguang-invoke",
    }) then
      cards = player:getCardIds("he")
    end
    if #cards > 0 then
      event:setCostData(self, { cards = cards })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards ---@type integer[]
    data.extra_data = data.extra_data or {}
    data.extra_data.zeguang = data.extra_data.zeguang or {}
    local cardList = data.extra_data.zeguang[player] or {}
    table.insertTableIfNeed(cardList, cards)
    data.extra_data.zeguang[player] = cardList
    room:recastCard(cards, player, zeguang.name)
  end,
})

zeguang:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return
      data.damageDealt and
      player:hasSkill(zeguang.name) and
      data.extra_data and data.extra_data.zeguang and
      table.hasIntersection(data.extra_data.zeguang[player] or {}, player.room.discard_pile)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = zeguang.name,
      prompt = "#zeguang-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, { tos = to })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local discardPile = room.discard_pile
    local cardList = table.filter(data.extra_data.zeguang[player], function(id)
      return table.contains(discardPile, id)
    end)
    if #cardList > 0 then
      room:obtainCard(event:getCostData(self).tos[1], cardList, true, fk.ReasonJustMove, player, zeguang.name)
    end
  end,
})

return zeguang
