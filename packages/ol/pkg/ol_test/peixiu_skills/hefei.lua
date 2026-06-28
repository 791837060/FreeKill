local hefei = fk.CreateSkill {
  name = "peixiu__hefei",
}

Fk:loadTranslationTable {
  ["peixiu_hefei"] = "合肥",
  [":peixiu_hefei"] = "你获得此技能后，可以弃置至多两张牌，然后摸等量的牌。",

  ["#peixiu_hefei-discard"] = "合肥：弃置至多两张牌，然后摸等量的牌",
}

hefei:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == hefei.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    if player:isNude() then return end
    local cards = room:askToDiscard(player, {
      min_num = 0,
      max_num = 2,
      include_equip = true,
      skill_name = hefei.name,
      prompt = "#peixiu_hefei-discard",
      cancelable = true,
      skip = true,
    })
    if #cards > 0 then
      room:throwCard(cards, hefei.name, player, player)
      player:drawCards(#cards, hefei.name)
    end
  end
})

return hefei
