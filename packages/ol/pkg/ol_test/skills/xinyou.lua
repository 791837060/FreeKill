
local xinyou = fk.CreateSkill{
  name = "ol__xinyou",
}

Fk:loadTranslationTable{
  ["ol__xinyou"] = "心幽",
  [":ol__xinyou"] = "出牌阶段限一次，你可以弃置任意张基本牌，然后摸一张牌，并重复此流程，直到你因此获得未弃置牌名的基本牌（至多摸五张）。",

  ["#ol__xinyou"] = "心幽：弃置任意张基本牌，摸牌直到摸到未弃置牌名的基本牌",

  ["$ol__xinyou1"] = "",
  ["$ol__xinyou2"] = "",
}

xinyou:addEffect("active", {
  anim_type = "drawcard",
  max_phase_use_time = 1,
  prompt = "#ol__xinyou",
  min_card_num = 1,
  target_num = 0,
  can_use = function (self, player)
    return player:usedSkillTimes(xinyou.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return not player:prohibitDiscard(to_select) and Fk:getCardById(to_select).type == Card.TypeBasic
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local names = table.map(effect.cards, function (id)
      return Fk:getCardById(id).trueName
    end)
    room:throwCard(effect.cards, xinyou.name, player, player)
    for _ = 1, 5 do
      if player.dead then return end
      local cards = player:drawCards(1, xinyou.name)
      if table.find(cards, function (id)
        return Fk:getCardById(id).type == Card.TypeBasic and not table.contains(names, Fk:getCardById(id).trueName)
      end) then
        return
      end
    end
  end,
})

return xinyou
