local lujiang = fk.CreateSkill {
  name = "peixiu__lujiang",
}

Fk:loadTranslationTable {
  ["peixiu_lujiang"] = "庐江",
  [":peixiu_lujiang"] = "你获得此技能后，你可以拼点，赢的角色摸两张牌。",

  ["#peixiu_lujiang-choose"] = "庐江：选择一名角色拼点，赢的角色摸两张牌",
}

lujiang:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == lujiang.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if player:isKongcheng() then return false end

    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and not p:isKongcheng()
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
        skill_name = lujiang.name,
        prompt = "#peixiu_lujiang-choose",
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

    local pindian = room:askForPindian(player, to, lujiang.name)
    if pindian.results[player].winner then
      player:drawCards(2, lujiang.name)
    else
      to:drawCards(2, lujiang.name)
    end
  end
})

return lujiang
