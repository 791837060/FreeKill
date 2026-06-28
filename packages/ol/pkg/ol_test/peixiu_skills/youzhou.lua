local youzhou = fk.CreateSkill {
  name = "peixiu__youzhou",
}

Fk:loadTranslationTable {
  ["peixiu_youzhou"] = "幽州",
  [":peixiu_youzhou"] = "你获得此技能后，加1点体力上限。",
}

youzhou:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == youzhou.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    room:changeMaxHp(player, 1)
  end
})

return youzhou
