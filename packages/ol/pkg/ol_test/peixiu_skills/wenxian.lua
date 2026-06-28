local wenxian = fk.CreateSkill {
  name = "peixiu__wenxian",
}

Fk:loadTranslationTable {
  ["peixiu_wenxian"] = "温县",
  [":peixiu_wenxian"] = "你获得此技能后，加1点体力上限并回复1点体力，然后获得一张【虚妄之冤】。",
}

wenxian:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == wenxian.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    room:changeMaxHp(player, 1)
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = wenxian.name,
    }
    local card = room:printCard("xuwang_zhiyuan", Card.Spade, 1)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, wenxian.name, nil, true, player)
  end
})

return wenxian
