local runan = fk.CreateSkill {
  name = "peixiu__runan",
}

Fk:loadTranslationTable {
  ["peixiu_runan"] = "汝南",
  [":peixiu_runan"] = "你获得此技能后，可以令一名角色摸等同于你手牌上限的牌。",

  ["#peixiu_runan-choose"] = "汝南：选择一名角色，其摸等同于你手牌上限的牌",
}

runan:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == runan.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = room.alive_players
    local to
    if #targets == 1 then
      to = targets[1]
    else
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = runan.name,
        prompt = "#peixiu_runan-choose",
      })
      if #tos == 0 then return false end
      to = tos[1]
    end
    event:setCostData(self, { tos = { to } })
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    to:drawCards(player.maxHp, runan.name)
  end
})

return runan
