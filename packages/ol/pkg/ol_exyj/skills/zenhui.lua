local zenhui = fk.CreateSkill {
  name = "ol_ex__zenhui",
  max_branches_use_time = {
    ["choice1"] = {
      [Player.HistoryPhase] = 1
    },
    ["choice2"] = {
      [Player.HistoryPhase] = 1
    },
  }
}

Fk:loadTranslationTable{
  ["ol_ex__zenhui"] = "谮毁",
  [":ol_ex__zenhui"] = "出牌阶段各限一次，当你使用【杀】或普通锦囊牌（不含【借刀杀人】）指定目标时，你可以令另一名能成为此牌目标的其他角色选择一项："..
  "1.交给你一张牌并代替你成为此牌的使用者（不计次数）；2.成为此牌的额外目标。",

  ["#ol_ex__zenhui-choose"] = "谮毁：你可以令一名角色选择：交给你一张牌并成为此牌的使用者；或成为此牌的额外目标",
  ["#ol_ex__zenhui-choose1"] = "谮毁：你可以令一名角色交给你一张牌并成为%arg的使用者",
  ["#ol_ex__zenhui-choose2"] = "谮毁：你可以令一名角色成为%arg的额外目标",

  ["$ol_ex__zenhui1"] = "父疾，而子不侍，此为不孝。",
  ["$ol_ex__zenhui2"] = "君患，而臣不忧，是为不忠。"
}

zenhui:addEffect(fk.TargetSpecifying, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zenhui.name) and player.phase == Player.Play and data.firstTarget and
      (data.card.trueName == "slash" or (data.card.trueName ~= "collateral" and data.card:isCommonTrick())) and
      #data:getExtraTargets({bypass_times = true}) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local extras = data:getExtraTargets({bypass_times = true})
    table.removeOne(extras, player)
    local branch = nil
    if #extras == 0 then return end
    local prompt = "#ol_ex__zenhui-choose:::"
    if not zenhui:withinBranchTimesLimit(player, "choice1", Player.HistoryPhase) then
      prompt = "#ol_ex__zenhui-choose2:::"
      branch = "choice2"
    elseif not zenhui:withinBranchTimesLimit(player, "choice2", Player.HistoryPhase) then
      extras = table.filter(extras, function(p) return not p:isNude() end)
      prompt = "#ol_ex__zenhui-choose1:::"
      branch = "choice1"
    end
    if #extras == 0 then return end
    local to = room:askToChoosePlayers(player, {
      skill_name = zenhui.name,
      targets = extras,
      min_num = 1,
      max_num = 1,
      prompt = prompt .. data.card:toLogString(),
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to, history_branch = branch})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local dat = event:getCostData(self)
    local to, branch = dat.tos[1], dat.history_branch
    local card = {}
    if not to:isNude() and branch ~= "choice2" then
      card = room:askToCards(to, {
        skill_name = zenhui.name,
        include_equip = true,
        min_num = 1,
        max_num = 1,
        prompt = "#zenhui-give::"..player.id,
        cancelable = branch ~= "choice1",
      })
    end
    if #card > 0 then
      player:addSkillBranchUseHistory(zenhui.name, "choice1")
      room:obtainCard(player, card, false, fk.ReasonGive, to, zenhui.name)
      data.from = to
      if not data.use.extraUse then
        data.use.extraUse = true
        player:addCardUseHistory(data.card.trueName, -1)
      end
    else
      player:addSkillBranchUseHistory(zenhui.name, "choice2")
      data:addTarget(to)
      room:sendLog{
        type = "#AddTargetsBySkill",
        from = player.id,
        to = {to.id},
        arg = zenhui.name,
        arg2 = data.card:toLogString(),
      }
    end
  end,
}, { check_skill_limit = true })

return zenhui
