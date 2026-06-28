
local function HeyuFriend(room, player, friend)
  return (room:isGameMode("1v2_mode") or room:isGameMode("2v2_mode")) and
    table.find(room.alive_players, function (p)
      return p.role == player.role and (p.general == friend or p.deputyGeneral == friend)
    end)
end

local heyu = fk.CreateSkill {
  name = "lidian__heyu",
  tags = { Skill.Compulsory },
  dynamic_desc = function(self, player)
    if HeyuFriend(Fk:currentRoom(), player, "m_thoroughbred__yuejin") and
      HeyuFriend(Fk:currentRoom(), player, "m_thoroughbred__zhangliao") then
      return "lidian__heyu"
    elseif HeyuFriend(Fk:currentRoom(), player, "m_thoroughbred__yuejin") then
      return "lidian__heyu_yuejin"
    elseif HeyuFriend(Fk:currentRoom(), player, "m_thoroughbred__zhangliao") then
      return "lidian__heyu_zhangliao"
    end
    return "dummyskill"
  end,
}

Fk:loadTranslationTable{
  ["lidian__heyu"] = "合御",
  [":lidian__heyu"] = "锁定技，若友方骥乐进在场，你获得因〖断津〗弃置的牌；"..
  "若友方骥张辽在场，〖概公〗使用的牌不可被响应。（仅斗地主和2v2模式生效）",

  [":lidian__heyu_yuejin"] = "锁定技，若友方骥乐进在场，你获得因〖断津〗弃置的牌。",
  [":lidian__heyu_zhangliao"] = "锁定技，若友方骥张辽在场，〖概公〗使用的牌不可被响应。",

  ["$lidian__heyu1"] = "",
  ["$lidian__heyu2"] = "",
}

heyu:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(heyu.name) and HeyuFriend(player.room, player, "m_thoroughbred__yuejin") then
      for _, move in ipairs(data) do
        if move.skillName == "duanjin" and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard and
          move.proposer == player then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player.room.discard_pile, info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, move in ipairs(data) do
      if move.skillName == "duanjin" and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard and
        move.proposer == player then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(room.discard_pile, info.cardId) then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, heyu.name, nil, true, player)
  end,
})

heyu:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(heyu.name) and
      HeyuFriend(player.room, player, "m_thoroughbred__zhangliao") and
      data.extra_data and data.extra_data.gaigong == player
  end,
  on_use = function (self, event, target, player, data)
    data.disresponsiveList = table.simpleClone(player.room.players)
  end,
})

return heyu
