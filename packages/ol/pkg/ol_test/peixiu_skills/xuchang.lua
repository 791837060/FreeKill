local xuchang = fk.CreateSkill {
  name = "peixiu__xuchang",
}

Fk:loadTranslationTable {
  ["peixiu_xuchang"] = "许昌",
  [":peixiu_xuchang"] = "你获得此技能后，可令一名其他角色攻击范围增加至与你相同。",

  ["#peixiu_xuchang-choose"] = "许昌：选择一名其他角色，令其攻击范围增加至与你相同",
}

xuchang:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == xuchang.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player
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
        skill_name = xuchang.name,
        prompt = "#peixiu_xuchang-choose",
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

    local my_range = player:getAttackRange()
    local his_range = to:getAttackRange()
    if my_range > his_range then
      local diff = my_range - his_range
      room:setPlayerMark(to, "@@peixiu_xuchang-range", diff)
    end
  end
})

xuchang:addEffect("targetmod", {
  extra_attack_range_func = function(self, player)
    return player:getMark("@@peixiu_xuchang-range") or 0
  end,
})

xuchang:addLoseEffect(function(self, player)
  player.room:setPlayerMark(player, "@@peixiu_xuchang-range", 0)
end)

return xuchang
