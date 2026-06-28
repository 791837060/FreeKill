local juancheng = fk.CreateSkill {
  name = "peixiu__juancheng",
}

Fk:loadTranslationTable {
  ["peixiu_juancheng"] = "鄄城",
  [":peixiu_juancheng"] = "你获得此技能后，判定，若为黑色，你获得判定牌并重复此流程。",
}

juancheng:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == juancheng.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end

    while true do
      local judge = room:judge{
        who = player,
        skillName = juancheng.name,
      }
      if judge.card.color == Card.Black then
        room:moveCardTo(judge.card, Card.PlayerHand, player, fk.ReasonJustMove, juancheng.name, nil, true, player)
      else
        break
      end
    end
  end
})

return juancheng
