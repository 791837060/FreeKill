local anding = fk.CreateSkill {
  name = "peixiu_anding",
}

Fk:loadTranslationTable {
  ["peixiu_anding"] = "安定",
  [":peixiu_anding"] = "防止你因传导受到的属性伤害。",
}

anding:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and data.damageType ~= fk.NormalDamage and data.chain
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:preventDamage()
    return true
  end,
})

return anding
