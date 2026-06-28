local liangzhou = fk.CreateSkill {
  name = "peixiu__liangzhou",
}

Fk:loadTranslationTable {
  ["peixiu_liangzhou"] = "梁州",
  [":peixiu_liangzhou"] = "你成为【杀】的目标后，使用者弃置一张牌。",
}

liangzhou:addEffect(fk.TargetConfirmed, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(self.name) then return false end
    if data.card.trueName ~= "slash" then return false end
    local from = data.from
    if not from or from.dead then return false end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    if from:isNude() then return end
    local card = room:askToDiscard(from, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = self.name,
      prompt = "#peixiu_liangzhou-discard",
    })
    if #card > 0 then
      room:throwCard(card, self.name, from, from)
    end
  end,
})

Fk:loadTranslationTable {
  ["#peixiu_liangzhou-discard"] = "梁州：请弃置一张牌",
}

return liangzhou
