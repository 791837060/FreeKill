local qiaoxian = fk.CreateSkill {
  name = "peixiu__qiaoxian",
}

Fk:loadTranslationTable {
  ["peixiu_qiaoxian"] = "谯县",
  [":peixiu_qiaoxian"] = "你受到伤害后，可以摸一张牌。",

  ["#peixiu_qiaoxian-invoke"] = "谯县：是否摸一张牌？",
}

qiaoxian:addEffect(fk.Damaged, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not room:askToSkillInvoke(player, {skill_name = self.name, prompt = "#peixiu_qiaoxian-invoke"}) then return end
    player:drawCards(1, self.name)
  end,
})

return qiaoxian
