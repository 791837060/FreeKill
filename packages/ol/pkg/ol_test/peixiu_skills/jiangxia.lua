local jiangxia = fk.CreateSkill {
  name = "peixiu__jiangxia",
}

Fk:loadTranslationTable {
  ["peixiu_jiangxia"] = "江夏",
  [":peixiu_jiangxia"] = "你获得此技能后，可以令一名其他角色摸两张牌，然后交给你一张牌。",

  ["#peixiu_jiangxia-choose"] = "江夏：选择一名其他角色，其摸两张牌然后交给你一张牌",
}

jiangxia:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == jiangxia.name
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
        skill_name = jiangxia.name,
        prompt = "#peixiu_jiangxia-choose",
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

    to:drawCards(2, jiangxia.name)
    if not to.dead and not to:isKongcheng() then
      local cards = room:askToChooseCard(to, {
        flag = "h",
        skill_name = jiangxia.name,
      })
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, jiangxia.name, nil, false, to)
      end
    end
  end
})

return jiangxia
