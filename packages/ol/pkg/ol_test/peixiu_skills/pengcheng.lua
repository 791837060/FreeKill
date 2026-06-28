local pengcheng = fk.CreateSkill {
  name = "peixiu__pengcheng",
}

Fk:loadTranslationTable {
  ["peixiu_pengcheng"] = "彭城",
  [":peixiu_pengcheng"] = "你获得此技能后，可以令一名其他角色交给你一张牌，然后其回复1点体力。",

  ["#peixiu_pengcheng-choose"] = "彭城：选择一名其他角色，其交给你一张牌，然后其回复1点体力",
}

pengcheng:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == pengcheng.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
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
        skill_name = pengcheng.name,
        prompt = "#peixiu_pengcheng-choose",
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

    local cards = room:askToChooseCard(to, {
      flag = "h",
      skill_name = pengcheng.name,
    })
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, pengcheng.name, nil, false, to)
      if not to.dead and to:isWounded() then
        room:recover{
          who = to,
          num = 1,
          recoverBy = player,
          skillName = pengcheng.name,
        }
      end
    end
  end
})

return pengcheng
