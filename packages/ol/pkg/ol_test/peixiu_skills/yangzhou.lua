local yangzhou = fk.CreateSkill {
  name = "peixiu__yangzhou",
}

Fk:loadTranslationTable {
  ["peixiu_yangzhou"] = "扬州",
  [":peixiu_yangzhou"] = "你获得此技能后，可以令一名其他角色回复1点体力。",

  ["#peixiu_yangzhou-choose"] = "扬州：选择一名其他角色，令其回复1点体力",
}

yangzhou:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == yangzhou.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and p:isWounded()
    end)
    if #targets == 0 then return false end

    local to
    if #targets == 1 then
      to = targets[1]
    else
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = yangzhou.name,
        prompt = "#peixiu_yangzhou-choose",
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

    room:recover{
      who = to,
      num = 1,
      recoverBy = player,
      skillName = yangzhou.name,
    }
  end
})

return yangzhou
