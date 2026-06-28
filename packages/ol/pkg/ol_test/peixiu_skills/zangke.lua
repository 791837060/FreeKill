local zangke = fk.CreateSkill {
  name = "peixiu__zangke",
}

Fk:loadTranslationTable {
  ["peixiu_zangke"] = "牂牁",
  [":peixiu_zangke"] = "你受到伤害后，你可以弃置你与伤害来源各一张牌。",

  ["#peixiu_zangke-invoke"] = "牂牁：是否弃置你与 %src 各一张牌？",
}

zangke:addEffect(fk.Damaged, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(self.name) then return false end
    local from = data.from
    if not from or from.dead then return false end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    if not room:askToSkillInvoke(player, {skill_name = self.name, prompt = "#peixiu_zangke-invoke", tos = {from}}) then return end

    if not player:isNude() then
      local my_card = room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = self.name,
        prompt = "#peixiu_zangke-my",
      })
      if #my_card > 0 then
        room:throwCard(my_card, self.name, player, player)
      end
    end

    if not from:isNude() then
      local his_card = room:askToDiscard(from, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = self.name,
        prompt = "#peixiu_zangke-his",
      })
      if #his_card > 0 then
        room:throwCard(his_card, self.name, from, from)
      end
    end
  end,
})

Fk:loadTranslationTable {
  ["#peixiu_zangke-my"] = "牂牁：请弃置你的一张牌",
  ["#peixiu_zangke-his"] = "牂牁：请弃置你的一张牌",
}

return zangke
