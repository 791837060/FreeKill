local bingzhou = fk.CreateSkill {
  name = "peixiu__bingzhou",
}

Fk:loadTranslationTable {
  ["peixiu_bingzhou"] = "并州",
  [":peixiu_bingzhou"] = "你获得此技能后，可以视为使用一张【决斗】。",

  ["#peixiu_bingzhou-invoke"] = "并州：是否视为使用一张【决斗】？",
}

bingzhou:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == bingzhou.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if not room:askToSkillInvoke(player, {skill_name = bingzhou.name, prompt = "#peixiu_bingzhou-invoke"}) then return false end
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:useVirtualCard("duel", nil, player, player, bingzhou.name)
  end
})

return bingzhou
