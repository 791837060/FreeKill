
local qiumu = fk.CreateSkill({
  name = "qiumu",
  tags = { Skill.Compulsory },
  dynamic_desc = function (self, player, lang)
    if player:getMark("qiumu") > 0 then
      return "qiumu_inner"
    end
  end,
})

Fk:loadTranslationTable{
  ["qiumu"] = "秋暮",
  [":qiumu"] = "锁定技，本回合成为过红色牌目标的角色进入濒死状态时，你获得其所有黑色牌，并将〖春晖〗〖夏晟〗〖秋暮〗描述中的“红色”均改为“黑色”。",

  [":qiumu_inner"] = "锁定技，本回合成为过黑色牌目标的角色进入濒死状态时，你获得其所有黑色牌。",

  ["$qiumu1"] = "",
  ["$qiumu2"] = "",
}

qiumu:addEffect(fk.EnterDying, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(qiumu.name) and
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        if table.contains(e.data.tos, target) then
          if player:getMark(qiumu.name) == 0 then
            return e.data.card.color == Card.Red
          else
            return e.data.card.color == Card.Black
          end
        end
        return (e.data.card.color == Card.Red) and table.contains(e.data.tos, target)
      end, Player.HistoryTurn) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(target:getCardIds("he"), function (id)
      return Fk:getCardById(id).color == Card.Black
    end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, qiumu.name, nil, false, player)
    end
    if not player.dead then
      for _, s in ipairs({ "chunhui", "xiasheng", "qiumu" }) do
        if player:hasSkill(s, true) then
          room:setPlayerMark(player, s, 1)
        end
      end
    end
  end,
})

qiumu:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, qiumu.name, 0)
end)

return qiumu
