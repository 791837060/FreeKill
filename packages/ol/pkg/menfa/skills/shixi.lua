local function shixiCardDesc(suit, name)
  return Fk:translate("log_" .. suit) .. " " .. Fk:translate(name)
end

local shixi = fk.CreateSkill {
  name = "shixi",
  dynamic_desc = function (self, player, lang)
    if player:getMark(self.name) ~= 0 then
      local ret = ""
      for suit, name in pairs(player:getTableMark(self.name)) do
        ret = ret..shixiCardDesc(suit, name).."<br>"
      end
      Fk:loadTranslationTable{
        ["shixi_names"] = "记录的单目标普通锦囊牌：<br>"..ret,
      }
      return "shixi_inner"
    end
  end,
}

Fk:loadTranslationTable{
  ["shixi"] = "拾昔",
  [":shixi"] = "你首次使用一个花色的单目标普通锦囊牌时，记录牌名和花色。当你需要使用记录牌时，你可以将对应其一个花色的所有牌置入弃牌堆，视为使用之。",

  [":shixi_inner"] = "你首次使用一个花色的<a href='shixi_names'>单目标普通锦囊牌</a>时，记录牌名和花色。"..
  "当你需要使用记录牌时，你可以将所有对应花色的牌置入弃牌堆，视为使用之。",

  ["#shixi"] = "拾昔：将一个花色的所有牌置入弃牌堆，视为使用对应的普通锦囊牌",
  ["#shixi-use"] = "拾昔：将所有%arg牌置入弃牌堆，视为使用【%arg2】",

  ["$shixi1"] = "满枝橘子香，小女窗前贴花黄。",
  ["$shixi2"] = "提裙扑流萤，囊灯一盏照夜读。",
}

shixi:addEffect("viewas", {
  pattern = ".|.|.|.|.|normal_trick",
  prompt = function (self, player, selected_cards, selected)
    if self.interaction.data then
      for suit, name in pairs(player:getTableMark(shixi.name)) do
        if shixiCardDesc(suit, name) == self.interaction.data then
          return "#shixi-use:::".."log_"..suit..":"..name
        end
      end
    end
    return "#shixi"
  end,
  interaction = function(self, player)
    local name_suit_map, all_suits, names, choices, all_choices = {}, {}, {}, {}, {}
    for _, id in ipairs(player:getCardIds("he")) do
      local s = Fk:getCardById(id):getSuitString()
      if s ~= "nosuit" then table.insertIfNeed(all_suits, s) end
      if #all_suits == 4 then break end
    end
    for suit, name in pairs(player:getTableMark(shixi.name)) do
      if table.contains(all_suits, suit) then
        name_suit_map[name] = name_suit_map[name] or {}
        table.insert(name_suit_map[name], suit)
        table.insert(names, name)
      end
    end
    names = player:getViewAsCardNames(shixi.name, names)
    if #names == 0 then return end
    for name, suits in pairs(name_suit_map) do
      table.forEach(suits, function(suit)
        local choice = shixiCardDesc(suit, name)
        if table.contains(names, name) then table.insert(choices, choice) end
        table.insert(all_choices, choice)
      end)
    end
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  filter_pattern = {
    min_num = 0,
    max_num = 0,
    pattern = ".",
  },
  view_as = function(self, player, cards)
    if not self.interaction.data then return end
    local fake_cards = {}
    local card_name
    for suit, name in pairs(player:getTableMark(shixi.name)) do
      if shixiCardDesc(suit, name) == self.interaction.data then
        card_name = name
        fake_cards = table.filter(player:getCardIds("he"), function (id)
          return Fk:getCardById(id):getSuitString() == suit
        end)
        break
      end
    end
    local card = Fk:cloneCard(card_name, nil, nil, shixi.name)
    card:addFakeSubcards(fake_cards)
    return card
  end,
  before_use = function (self, player, use)
    player.room:moveCardTo(use.card.fake_subcards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, shixi.name, nil, true, player)
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
  enabled_at_nullification = Util.FalseFunc,
})

shixi:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(shixi.name, true) and
      data.card:isCommonTrick() and not data.card.multiple_targets and not data.card.is_passive and
      data.card.suit ~= Card.NoSuit and player:getTableMark(shixi.name)[data.card:getSuitString()] == nil
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark(shixi.name)
    mark[data.card:getSuitString()] = data.card.name
    room:setPlayerMark(player, shixi.name, mark)
  end,
})

shixi:addAcquireEffect(function (self, player, is_start)
  if not is_start then
    local room = player.room
    local mark = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data
      if use.from == player and use.card:isCommonTrick() and not use.card.multiple_targets and not use.card.is_passive and
        use.card.suit ~= Card.NoSuit and mark[use.card:getSuitString()] == nil then
          mark[use.card:getSuitString()] = use.card.name
          if #mark == 4 then return true end
      end
    end, Player.HistoryGame)
    room:setPlayerMark(player, shixi.name, mark)
  end
end)

return shixi
