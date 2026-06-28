local zhijiant = fk.CreateSkill {
  name = "zhijiant",
}

Fk:loadTranslationTable{
  ["zhijiant"] = "执谏",
  [":zhijiant"] = "出牌阶段限一次，你可以令一名其他角色声明一个牌的类别，然后你摸一张牌并交给其一张牌（若上一次发动此技能也指定该角色，则多摸一张牌），"..
  "若此牌与声明的类别不同，其可以对你使用一张【杀】。",

  ["zhijiant_target"] = "上次目标",
  ["#zhijiant"] = "执谏：令一名角色声明一个类别，你摸牌并交给其一张牌",
  ["#zhijiant-choice"] = "执谏：声明一个类别，%src 摸牌并交给你一张牌",
  ["#zhijiant-give"] = "执谏：交给 %dest 一张牌，若不为%arg，其可以对你使用一张【杀】",
  ["#zhijiant-slash"] = "执谏：你可以对 %src 使用一张【杀】",

  ["$zhijiant1"] = "",
  ["$zhijiant2"] = "",
}

zhijiant:addEffect("active", {
  anim_type = "support",
  prompt = "#zhijiant",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(zhijiant.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  target_tip = function (self, player, to_select, selected, selected_cards, card, selectable, extra_data)
    if selectable and player:getMark(zhijiant.name) == to_select then
      return "zhijiant_target"
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local n = player:getMark(zhijiant.name) == target and 2 or 1
    room:setPlayerMark(player, zhijiant.name, target)
    local choice = room:askToChoice(target, {
      choices = { "basic", "trick", "equip" },
      skill_name = zhijiant.name,
      prompt = "#zhijiant-choice:"..player.id,
    })
    room:sendLog{
      type = "#Choice",
      from = target.id,
      arg = choice,
      toast = true,
    }
    player:drawCards(n, zhijiant.name)
    if player:isNude() or target.dead then return end
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = zhijiant.name,
      prompt = "#zhijiant-give::"..target.id..":"..choice,
      cancelable = false,
    })
    local yes = Fk:getCardById(card[1]):getTypeString() ~= choice
    room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonGive, zhijiant.name, nil, false, player)
    if yes and not player.dead and not target.dead then
      local use = room:askToUseCard(target, {
        skill_name = zhijiant.name,
        pattern = "slash",
        prompt = "#zhijiant-slash:"..player.id,
        extra_data = {
          bypass_distances = true,
          bypass_times = true,
          exclusive_targets = { player.id },
        }
      })
      if use then
        use.extraUse = true
        room:useCard(use)
      end
    end
  end,
})

return zhijiant
