local bohai = fk.CreateSkill {
  name = "peixiu__bohai",
}

Fk:loadTranslationTable {
  ["peixiu_bohai"] = "渤海",
  [":peixiu_bohai"] = "你获得此技能后，可以弃置一张武器牌，然后摸两张牌。",

  ["#peixiu_bohai-discard"] = "渤海：弃置一张武器牌，然后摸两张牌",
}

bohai:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == bohai.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = bohai.name,
      prompt = "#peixiu_bohai-discard",
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      room:throwCard(card, bohai.name, player, player)
      player:drawCards(2, bohai.name)
    end
  end
})

return bohai
