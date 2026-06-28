local nanfu = fk.CreateSkill {
  name = "peixiu__nanfu",
}

Fk:loadTranslationTable {
  ["peixiu_nanfu"] = "南涪",
  [":peixiu_nanfu"] = "你获得此技能后，可以失去1点体力，视为使用一张【杀】。",

  ["#peixiu_nanfu-invoke"] = "南涪：是否失去1点体力，视为使用一张【杀】？",
}

nanfu:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == nanfu.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if player.hp <= 0 then return false end
    if not room:askToSkillInvoke(player, {skill_name = nanfu.name, prompt = "#peixiu_nanfu-invoke"}) then return false end
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, nanfu.name)
    if not player.dead then
      room:useVirtualCard("slash", nil, player, player, nanfu.name)
    end
  end
})

return nanfu
