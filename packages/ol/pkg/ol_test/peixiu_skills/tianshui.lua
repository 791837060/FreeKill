local tianshui = fk.CreateSkill {
  name = "peixiu__tianshui",
}

Fk:loadTranslationTable {
  ["peixiu_tianshui"] = "天水",
  [":peixiu_tianshui"] = "你获得此技能后，可以弃置一名角色一张手牌，若不为【杀】，你摸两张牌。",

  ["#peixiu_tianshui-choose"] = "天水：选择一名角色，弃置其一张手牌",
}

tianshui:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == tianshui.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return not p:isKongcheng()
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
        skill_name = tianshui.name,
        prompt = "#peixiu_tianshui-choose",
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
      skill_name = tianshui.name,
    })
    if #cards > 0 then
      local card = Fk:getCardById(cards[1])
      room:throwCard(cards, tianshui.name, to, to)
      if card.trueName ~= "slash" then
        player:drawCards(2, tianshui.name)
      end
    end
  end
})

return tianshui
