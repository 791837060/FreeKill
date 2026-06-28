local fanyang = fk.CreateSkill {
  name = "peixiu__fanyang",
}

Fk:loadTranslationTable {
  ["peixiu_fanyang"] = "范阳",
  [":peixiu_fanyang"] = "你获得此技能后，可以对攻击范围内的一名角色造成1点伤害。",

  ["#peixiu_fanyang-choose"] = "范阳：选择攻击范围内的一名角色，对其造成1点伤害",
}

fanyang:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == fanyang.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and player:inMyAttackRange(p)
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
        skill_name = fanyang.name,
        prompt = "#peixiu_fanyang-choose",
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

    room:damage{
      from = player,
      to = to,
      damage = 1,
      skillName = fanyang.name,
    }
  end
})

return fanyang
