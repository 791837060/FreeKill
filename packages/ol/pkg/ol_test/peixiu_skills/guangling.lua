local guangling = fk.CreateSkill {
  name = "peixiu__guangling",
}

Fk:loadTranslationTable {
  ["peixiu_guangling"] = "广陵",
  [":peixiu_guangling"] = "你获得此技能后，可以将两张牌当一张【五谷丰登】使用。",

  ["#peixiu_guangling-invoke"] = "广陵：是否将两张牌当【五谷丰登】使用？",
}

guangling:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == guangling.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if player:isNude() then return false end
    if not room:askToSkillInvoke(player, {skill_name = guangling.name, prompt = "#peixiu_guangling-invoke"}) then return false end
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:useVirtualCard("amazing_grace", nil, player, player, guangling.name, true)
  end
})

return guangling
