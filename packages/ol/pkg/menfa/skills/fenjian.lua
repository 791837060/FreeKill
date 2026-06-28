local fenjian = fk.CreateSkill{
  name = "ol__fenjian",
  max_branches_use_time = {
    ["large"] = {
      [Player.HistoryPhase] = 1
    },
    ["equal"] = {
      [Player.HistoryPhase] = 1
    },
    ["small"] = {
      [Player.HistoryPhase] = 1
    },
  }
}

Fk:loadTranslationTable{
  ["ol__fenjian"] = "奋剑",
  [":ol__fenjian"] = "出牌阶段每项限一次，你可以弃置一张牌，视为对一名角色使用一张【杀】，该角色攻击范围须：1.小于你；2.等于你；3.大于你。"..
  "若此【杀】造成伤害，你本回合攻击范围-1（至多减至0）。",

  ["#ol__fenjian"] = "奋剑：弃置一张牌，视为对一名角色使用【杀】",

  ["$ol__fenjian1"] = "",
  ["$ol__fenjian2"] = "",
}

fenjian:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ol__fenjian",
  card_num = 1,
  target_num = 1,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    if #selected == 0 and not to_select:isNude() then
      if fenjian:withinBranchTimesLimit(player, "large", Player.HistoryPhase) then
        if to_select:getAttackRange() > player:getAttackRange() then
          return true
        end
      end
      if fenjian:withinBranchTimesLimit(player, "equal", Player.HistoryPhase) then
        if to_select:getAttackRange() == player:getAttackRange() then
          return true
        end
      end
      if fenjian:withinBranchTimesLimit(player, "small", Player.HistoryPhase) then
        if to_select:getAttackRange() < player:getAttackRange() then
          return true
        end
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if target:getAttackRange() > player:getAttackRange() then
      player:addSkillBranchUseHistory(fenjian.name, "large", 1)
    elseif target:getAttackRange() == player:getAttackRange() then
      player:addSkillBranchUseHistory(fenjian.name, "equal", 1)
    elseif target:getAttackRange() < player:getAttackRange() then
      player:addSkillBranchUseHistory(fenjian.name, "small", 1)
    end
    room:throwCard(effect.cards, fenjian.name, player, player)
    if target.dead then return end
    local use = room:useVirtualCard("slash", nil, player, target, fenjian.name, true)
    if use and use.damageDealt and player:getAttackRange() > 0 then
      room:addPlayerMark(player, "ol__fenjian-turn", 1)
    end
  end,
}, { check_skill_limit = true })

fenjian:addEffect("atkrange", {
  correct_func = function(self, from, to)
    return -from:getMark("ol__fenjian-turn")
  end,
})

return fenjian
