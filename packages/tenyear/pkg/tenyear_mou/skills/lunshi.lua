local lunshi = fk.CreateSkill {
  name = "tymou__lunshi",
}

Fk:loadTranslationTable{
  ["tymou__lunshi"] = "论势",
  [":tymou__lunshi"] = "当你需要使用【无懈可击】抵消其他角色对除其外的角色使用的普通锦囊牌时，若你手牌中的红色和黑色牌数相等，"..
  "你可以将一张手牌当不可被响应的【无懈可击】使用。",

  ["#tymou__lunshi"] = "论势：你可将一张手牌当【无懈可击】使用",

  ["$tymou__lunshi1"] = "曹公济天下大难，必定霸王之业。",
  ["$tymou__lunshi2"] = "智者审于良主，袁公未知用人之机。",
}

lunshi:addEffect("viewas", {
  anim_type = "control",
  pattern = "nullification",
  prompt = "#tymou__lunshi",
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = ".|.|.|^equip",
  },
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = lunshi.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function (self, player, use)
    use.disresponsiveList = table.simpleClone(player.room.players)
  end,
  enabled_at_response = function (self, player, response)
    if response or player:isKongcheng() or
      (response == nil and player:getMark("lunshi_activated") == 0) then return end
    local red, black = 0, 0
    for _, id in ipairs(player:getCardIds("h")) do
      local color = Fk:getCardById(id).color
      if color == Card.Black then
        black = black + 1
      elseif color == Card.Red then
        red = red + 1
      end
    end
    return red == black
  end,
  enabled_at_nullification = function (self, player, data)
    return data and data.from ~= player and
      data.to and data.to ~= data.from and
      data.card:isCommonTrick() and not player:isKongcheng()
  end,
})

lunshi:addEffect(fk.HandleAskForPlayCard, {
  can_refresh = function(self, event, target, player, data)
    if data.afterRequest and (data.extra_data or {}).lunshi_effected then
      return player:getMark("lunshi_activated") ~= 0
    end

    return
      player:hasSkill(lunshi.name) and
      data.eventData and
      data.eventData.to and
      data.eventData.from ~= data.eventData.to and
      data.eventData.card:isCommonTrick() and
      Exppattern:Parse(data.pattern):match(Fk:cloneCard("nullification"))
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if data.afterRequest then
      room:setPlayerMark(player, "lunshi_activated", 0)
    else
      room:setPlayerMark(player, "lunshi_activated", 1)
      data.extra_data = data.extra_data or {}
      data.extra_data.lunshi_effected = true
    end
  end,
})

return lunshi
