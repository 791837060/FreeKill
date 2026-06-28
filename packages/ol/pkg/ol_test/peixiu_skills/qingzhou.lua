local qingzhou = fk.CreateSkill {
  name = "peixiu__qingzhou",
}

Fk:loadTranslationTable {
  ["peixiu_qingzhou"] = "青州",
  [":peixiu_qingzhou"] = "你获得此技能后，可以弃置所有手牌，然后摸等量的牌。",

  ["#peixiu_qingzhou-invoke"] = "青州：是否弃置所有手牌，然后摸等量的牌？",
}

qingzhou:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == qingzhou.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if player:isKongcheng() then return false end
    if not room:askToSkillInvoke(player, {skill_name = qingzhou.name, prompt = "#peixiu_qingzhou-invoke"}) then return false end
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local handcards = player:getCardIds("h")
    local n = #handcards
    room:throwCard(handcards, qingzhou.name, player, player)
    if not player.dead then
      player:drawCards(n, qingzhou.name)
    end
  end
})

return qingzhou
