local zhuti = fk.CreateSkill {
  name = "peixiu_zhuti",
}

Fk:loadTranslationTable {
  ["peixiu_zhuti"] = "朱提",
  [":peixiu_zhuti"] = "你受到属性伤害改为回复等量体力（每回合限一次）。",
}

zhuti:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(zhuti.name) then return false end
    if player:usedSkillTimes(zhuti.name, Player.HistoryTurn) > 0 then return false end
    return data.damageType ~= fk.NormalDamage
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover{
      who = player,
      num = data.damage,
      recoverBy = player,
      skillName = zhuti.name,
    }
    data:preventDamage()
    return true
  end,
})

return zhuti
