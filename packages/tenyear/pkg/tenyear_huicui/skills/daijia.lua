local daijia = fk.CreateSkill {
  name = "daijia",
  derived_piles = "daijia_pile",
}

Fk:loadTranslationTable{
  ["daijia"] = "黛颊",
  [":daijia"] = "每轮开始时，你可以回复1点体力，然后随机从牌堆或弃牌堆将五张红色牌置于武将牌上，称为“黛”。"..
    "你成为牌的目标结算完毕后，你须获得一种花色的“黛”。",

  ["daijia_pile"] = "黛",
  ["#daijia-prey"] = "黛颊：获得一种花色的“黛”",

  ["$daijia1"] = "",
  ["$daijia2"] = "",
}

local U = require "packages.utility.utility"

daijia:addEffect(fk.RoundStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(daijia.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    local cards = room:getCardsFromPileByRule(".|.|red", 5)
    if #cards < 5 then
      table.insertTable(cards, room:getCardsFromPileByRule(".|.|red", 5 - #cards, "discardPile"))
    end
    if #cards > 0 then
      player:addToPile("daijia_pile", cards, true, daijia.name, player)
      if player.dead then return end
    end
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = daijia.name,
    }
  end,
})

daijia:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(daijia.name) and
      table.contains(data.tos, player) and
      table.find(player:getPile("daijia_pile"), function (id)
        return Fk:getCardById(id).suit ~= Card.NoSuit
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local listNames = { "log_spade", "log_club", "log_heart", "log_diamond" }
    local listCards = { {}, {}, {}, {} }
    for _, id in ipairs(player:getPile("daijia_pile")) do
      local suit = Fk:getCardById(id).suit
      if suit ~= Card.NoSuit then
        table.insertIfNeed(listCards[suit], id)
      end
    end
    local choice = U.askForChooseCardList(room, player, listNames, listCards, 1, 1, daijia.name, "#daijia-prey", false, false)
    room:moveCardTo(listCards[table.indexOf(listNames, choice[1])], Card.PlayerHand, player, fk.ReasonJustMove, daijia.name, nil, false, player)
  end,
})

return daijia
