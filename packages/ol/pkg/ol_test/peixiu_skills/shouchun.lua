local shouchun = fk.CreateSkill {
  name = "peixiu__shouchun",
}

Fk:loadTranslationTable {
  ["peixiu_shouchun"] = "寿春",
  [":peixiu_shouchun"] = "你获得此技能后，可令一名角色加1点体力上限。",

  ["#peixiu_shouchun-choose"] = "寿春：选择一名角色，令其加1点体力上限",
}

shouchun:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == shouchun.name
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
        skill_name = shouchun.name,
        prompt = "#peixiu_shouchun-choose",
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
    room:changeMaxHp(to, 1)
  end
})

return shouchun
