local liangzhou = fk.CreateSkill {
  name = "peixiu__liangzhou2",
}

Fk:loadTranslationTable {
  ["peixiu_liangzhou2"] = "凉州",
  [":peixiu_liangzhou2"] = "你获得此技能后，可以将一张黑色牌当【杀】使用。",

  ["#peixiu_liangzhou2-invoke"] = "凉州：是否将一张黑色牌当【杀】使用？",
}

liangzhou:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == liangzhou.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if not room:askToSkillInvoke(player, {skill_name = liangzhou.name, prompt = "#peixiu_liangzhou2-invoke"}) then return false end
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:useVirtualCard("slash", nil, player, player, liangzhou.name, true)
  end
})

return liangzhou
