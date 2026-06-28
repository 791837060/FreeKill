local juchao = fk.CreateSkill {
  name = "peixiu__juchao",
}

Fk:loadTranslationTable {
  ["peixiu_juchao"] = "居巢",
  [":peixiu_juchao"] = "你获得此技能后，你可以弃置你与一名角色各一张牌。",

  ["#peixiu_juchao-choose"] = "居巢：选择一名角色，弃置你和其各一张牌",
}

juchao:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == juchao.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if player:isNude() then return false end

    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and not p:isNude()
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
        skill_name = juchao.name,
        prompt = "#peixiu_juchao-choose",
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

    local my_card = room:askToChooseCard(player, {
      flag = "he",
      skill_name = juchao.name,
    })
    if #my_card == 0 then return end
    room:throwCard(my_card, juchao.name, player, player)

    if to.dead then return end
    local his_card = room:askToChooseCard(to, {
      flag = "he",
      skill_name = juchao.name,
    })
    if #his_card > 0 then
      room:throwCard(his_card, juchao.name, to, to)
    end
  end
})

return juchao
