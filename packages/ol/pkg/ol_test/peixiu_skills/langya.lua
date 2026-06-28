local langya = fk.CreateSkill {
  name = "peixiu__langya",
}

Fk:loadTranslationTable {
  ["peixiu_langya"] = "琅琊",
  [":peixiu_langya"] = "你获得此技能后，观看牌堆顶的五张牌，然后以任意顺序置于牌堆顶或牌堆底。",
}

langya:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == langya.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end

    local cards = room:getNCards(5)
    room:askToArrangeCards(player, {
      cards = cards,
      skill_name = langya.name,
      areas = {"Top", "Bottom"},
      max_num = 5,
    })
  end
})

return langya
