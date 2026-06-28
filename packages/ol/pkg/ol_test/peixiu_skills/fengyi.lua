local fengyi = fk.CreateSkill {
  name = "peixiu__fengyi",
}

Fk:loadTranslationTable {
  ["peixiu_fengyi"] = "冯翊",
  [":peixiu_fengyi"] = "你获得此技能后，可以回复1点体力。",

  ["#peixiu_fengyi-invoke"] = "冯翊：是否回复1点体力？",
}

fengyi:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == fengyi.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if not player:isWounded() then return false end
    if not room:askToSkillInvoke(player, {skill_name = fengyi.name, prompt = "#peixiu_fengyi-invoke"}) then return false end
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = fengyi.name,
    }
  end
})

return fengyi
