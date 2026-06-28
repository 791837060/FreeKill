local youlong = fk.CreateSkill{
  name = "youlong",
  tags = { Skill.Switch },
  max_branches_use_time = {
    ["yang"] = {
      [Player.HistoryRound] = 1
    },
    ["yin"] = {
      [Player.HistoryRound] = 1
    },
  }
}

Fk:loadTranslationTable{
  ["youlong"] = "游龙",
  [":youlong"] = "转换技，每轮各限一次，你可以废除一个装备栏并视为使用一张未以此法使用过的：阳：普通锦囊牌；阴：基本牌。",

  ["@$youlong"] = "游龙",
  ["#youlong-choice"] = "游龙: 请选择废除一个装备栏",
  ["#youlong-yang"] = "游龙：你可以废除一个装备栏，视为使用一张未以此法使用过的普通锦囊牌",
  ["#youlong-yin"] = "游龙：你可以废除一个装备栏，视为使用一张未以此法使用过的基本牌",

  ["$youlong1"] = "赤壁献策，再谱春秋！",
  ["$youlong2"] = "卧龙出山，谋定万古！",
}

youlong:addEffect("viewas", {
  anim_type = "switch",
  pattern = ".",
  prompt = function(self, player, selected_cards, selected)
    return "#youlong-"..player:getSwitchSkillState(youlong.name, false, true)
  end,
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames(player:getSwitchSkillState(youlong.name) == fk.SwitchYang and "t" or "b")
    local names = player:getViewAsCardNames(youlong.name, all_names, {})
    local used = player:getTableMark("@$youlong")
    names = table.filter(names, function(name) return not table.contains(used, name) end)
    if #names > 0 then
      return UI.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  filter_pattern = {
    min_num = 0,
    max_num = 0,
    pattern = "",
    subcards = {}
  },
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = youlong.name
    return card
  end,
  history_branch = function(self, player, data)
    return player:getSwitchSkillState(youlong.name, false, true)
  end,
  before_use = function(self, player, use)
    local room = player.room
    room:addTableMark(player, "@$youlong", use.card.name)
    local choice = room:askToChoice(player, {
      choices = player:getAvailableEquipSlots(),
      skill_name = youlong.name,
      prompt = "#youlong-choice",
    })
    room:abortPlayerArea(player, choice)
  end,
  enabled_at_play = function(self, player)
    local state = player:getSwitchSkillState(youlong.name, false, true)
    return youlong:withinBranchTimesLimit(player, state, Player.HistoryRound) and #player:getAvailableEquipSlots() > 0
  end,
  enabled_at_response = function(self, player, response)
    if response or #player:getAvailableEquipSlots() == 0 then return end
    local state = player:getSwitchSkillState(youlong.name, false, true)
    if not youlong:withinBranchTimesLimit(player, state, Player.HistoryRound) then return end
    local names = player:getViewAsCardNames(youlong.name, Fk:getAllCardNames(state == "yang" and "t" or "b"), {})
    local used = player:getTableMark("@$youlong")
    return table.find(names, function(name) return not table.contains(used, name) end) ~= nil
  end,
  enabled_at_nullification = function(self, player, data)
    return #player:getAvailableEquipSlots() > 0 and
      player:getSwitchSkillState(youlong.name, false) == fk.SwitchYang and
      youlong:withinBranchTimesLimit(player, "yang", Player.HistoryRound) and
      not table.contains(player:getTableMark("@$youlong"), "nullification")
  end,
}, { check_skill_limit = true })

return youlong
