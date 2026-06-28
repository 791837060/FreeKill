local shangyong = fk.CreateSkill {
  name = "peixiu__shangyong",
}

Fk:loadTranslationTable {
  ["peixiu_shangyong"] = "上庸",
  [":peixiu_shangyong"] = "你获得此技能后，可以与一名其他角色各摸一张牌。",

  ["#peixiu_shangyong-choose"] = "上庸：选择一名其他角色，与其各摸一张牌",
}

shangyong:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == shangyong.name
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
        skill_name = shangyong.name,
        prompt = "#peixiu_shangyong-choose",
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

    player:drawCards(1, shangyong.name)
    if not to.dead then
      to:drawCards(1, shangyong.name)
    end
  end
})

return shangyong
