local zhoufa = fk.CreateSkill {
  name = "zhoufa",
}

Fk:loadTranslationTable{
  ["zhoufa"] = "咒法",
  [":zhoufa"] = "出牌阶段限一次，你可以将一张非基本牌当伤害牌使用，此牌造成的伤害改为雷电伤害。",

  ["#zhoufa-viewas"] = "咒法：将一张非基本牌当伤害牌使用，此牌造成伤害改为雷电伤害",
}

zhoufa:addEffect("viewas", {
  prompt = "#zhoufa-viewas",
  pattern = ".",
  interaction = function(self, player)
    local allNames = {}
    for _, name in ipairs(Fk:getAllCardNames("bt")) do
      local card = Fk.all_card_types[name]
      if card.is_damage_card and not card.is_derived then
        table.insertIfNeed(allNames, card.name)
      end
    end
    local names = player:getViewAsCardNames(zhoufa.name, allNames)
    return UI.CardNameBox { choices = names, all_choices = allNames }
  end,
  handly_pile = true,
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = ".|.|.|.|.|^basic",
  },
  view_as = function(self, player, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then
      return
    end

    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = zhoufa.name
    return card
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(zhoufa.name, Player.HistoryPhase) == 0
  end,
  enabled_at_response = Util.FalseFunc,
  enabled_at_nullification = Util.FalseFunc,
})

zhoufa:addEffect(fk.DamageCaused, {
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return
      target == player and
      data.card and
      table.contains(data.card.skillNames, zhoufa.name) and
      player.room.logic:damageByCardEffect()
  end,
  on_use = function (self, event, target, player, data)
    data.damageType = fk.ThunderDamage
  end,
})

return zhoufa
