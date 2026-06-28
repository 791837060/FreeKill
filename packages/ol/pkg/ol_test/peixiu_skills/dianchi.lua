local dianchi = fk.CreateSkill {
  name = "peixiu__dianchi",
}

Fk:loadTranslationTable {
  ["peixiu_dianchi"] = "滇池",
  [":peixiu_dianchi"] = "一名角色受到火焰伤害后，你可以令其失去1点体力（每回合限一次）。",

  ["#peixiu_dianchi-invoke"] = "滇池：是否令 %dest 失去1点体力？",
}

dianchi:addEffect(fk.Damaged, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self.name) then return false end
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return false end
    if target.dead then return false end
    return data.damageType == fk.FireDamage
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not room:askToSkillInvoke(player, {skill_name = self.name, prompt = "#peixiu_dianchi-invoke", tos = {target}}) then return end
    room:loseHp(target, 1, self.name)
  end,
})

return dianchi
