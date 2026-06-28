local hanzhong = fk.CreateSkill {
  name = "peixiu__hanzhong",
}

Fk:loadTranslationTable {
  ["peixiu_hanzhong"] = "汉中",
  [":peixiu_hanzhong"] = "你获得此技能后，可以与一名其他角色交换手牌。",

  ["#peixiu_hanzhong-choose"] = "汉中：选择一名其他角色交换手牌",
}

hanzhong:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == hanzhong.name
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
        skill_name = hanzhong.name,
        prompt = "#peixiu_hanzhong-choose",
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
    room:swapAllCards(player, {player, to}, hanzhong.name)
  end
})

return hanzhong
