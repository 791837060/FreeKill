local nanyang = fk.CreateSkill {
  name = "peixiu__nanyang",
}

Fk:loadTranslationTable {
  ["peixiu_nanyang"] = "南阳",
  [":peixiu_nanyang"] = "你获得此技能后，可以重铸一张锦囊牌，与一名角色各回复1点体力。",

  ["#peixiu_nanyang-choose"] = "南阳：选择一名角色，重铸一张锦囊牌，与目标各回复1点体力",
}

nanyang:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == nanyang.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if not player:isWounded() then return false end

    local tricks = {}
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeTrick then
        table.insert(tricks, id)
      end
    end
    if #tricks == 0 then return false end

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
        skill_name = nanyang.name,
        prompt = "#peixiu_nanyang-choose",
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

    local card = room:askToChooseCard(player, {
      flag = "h",
      skill_name = nanyang.name,
    })
    if #card > 0 then
      room:recastCard(card, nanyang.name, player)
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = nanyang.name,
      }
      if not to.dead then
        room:recover{
          who = to,
          num = 1,
          recoverBy = player,
          skillName = nanyang.name,
        }
      end
    end
  end
})

return nanyang
