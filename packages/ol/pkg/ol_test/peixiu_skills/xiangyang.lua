local xiangyang = fk.CreateSkill {
  name = "peixiu__xiangyang",
}

Fk:loadTranslationTable {
  ["peixiu_xiangyang"] = "襄阳",
  [":peixiu_xiangyang"] = "你获得此技能后，可以移动场上一张牌。",

  ["#peixiu_xiangyang-choose"] = "襄阳：选择一张场上的牌进行移动",
}

xiangyang:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == xiangyang.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = room:askToChooseCard(player, {
      flag = "hej",
      skill_name = xiangyang.name,
    })
    if #cards == 0 then return false end

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
        skill_name = xiangyang.name,
        prompt = "#peixiu_xiangyang-choose",
      })
      if #tos == 0 then return false end
      to = tos[1]
    end
    event:setCostData(self, { tos = { to }, cards = cards })
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = event:getCostData(self).cards

    room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonJustMove, xiangyang.name, nil, true, player)
  end
})

return xiangyang
