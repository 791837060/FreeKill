local qixian = fk.CreateSkill {
  name = "peixiu__qixian",
}

Fk:loadTranslationTable {
  ["peixiu_qixian"] = "祁县",
  [":peixiu_qixian"] = "你获得此技能后，你可以重铸一张装备牌，视为使用一张【杀】或【过河拆桥】（每回合限一次）。",

  ["#peixiu_qixian-invoke"] = "祁县：重铸一张装备牌，视为使用一张【杀】或【过河拆桥】",
}

qixian:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == qixian.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local equips = player:getCardIds("e")
    if #equips == 0 then return false end

    local card = room:askToChooseCard(player, {
      flag = "e",
      skill_name = qixian.name,
    })
    if #card == 0 then return false end
    event:setCostData(self, { cards = card })
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = event:getCostData(self).cards

    room:recastCard(card, qixian.name, player)
    if player.dead then return end

    local choices = {"slash", "dismantlement"}
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = qixian.name,
    })
    room:useVirtualCard(choice, nil, player, player, qixian.name)
  end
})

return qixian
