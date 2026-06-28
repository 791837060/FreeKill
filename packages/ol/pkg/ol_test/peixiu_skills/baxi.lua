local baxi = fk.CreateSkill {
  name = "peixiu_baxi",
}

Fk:loadTranslationTable {
  ["peixiu_baxi"] = "巴西",
  [":peixiu_baxi"] = "你获得此技能后，可以指定一名其他角色，其当前手牌无次数限制。",

  ["#peixiu_baxi-choose"] = "巴西：可选择一名其他角色，其当前手牌无次数限制",
  ["@@peixiu_baxi-inhand"] = "巴西",
}

baxi:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == baxi.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and not p:isKongcheng()
    end)
    if #targets == 0 then return false end
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = baxi.name,
      prompt = "#peixiu_baxi-choose",
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    for _, id in ipairs(to:getCardIds("h")) do
      room:setCardMark(Fk:getCardById(id), "@@peixiu_baxi-inhand", 1)
    end
  end
})

baxi:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and card:getMark("@@peixiu_baxi-inahd") > 0
  end,
})

return baxi
