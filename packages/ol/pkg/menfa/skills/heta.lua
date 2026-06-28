local heta = fk.CreateSkill{
  name = "heta",
}

Fk:loadTranslationTable{
  ["heta"] = "和他",
  [":heta"] = "出牌阶段开始时，你可以进入连环状态。然后本回合当你使用牌时，你可以解除连环状态，为此牌增加或减少任意个目标"..
  "（必须选择本回合此前你对其使用过牌的角色，无距离限制）。",

  ["#heta-choose"] = "和他：为%arg增加/减少任意个目标",
  ["@@heta_must"] = "自动强制选择",

  ["$heta1"] = "兵者不可为首，待他州发动再和之不迟。",
  ["$heta2"] = "学从袁，职自董，当助袁氏乎？当助董氏乎？",
}

heta:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(heta.name) and player.phase == Player.Play and
      not player.chained
  end,
  on_use = function (self, event, target, player, data)
    player:setChainState(true)
  end,
})

heta:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(heta.name) and
      player.chained and player:usedSkillTimes(heta.name, Player.HistoryTurn) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:setChainState(false)
    if player.dead then return end
    local must_targets = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      if e.data == data then
        return true
      else
        local use = e.data
        if use.from == player then
          for _, p in ipairs(use.tos) do
            table.insertIfNeed(must_targets, p)
          end
        end
      end
    end, Player.HistoryTurn)
    local extra_targets = data:getExtraTargets({bypass_distances = true})
    local contemporary_targets = data.tos
    local targets = table.connectIfNeed(extra_targets, contemporary_targets)
    must_targets = table.filter(must_targets, function (t)
      return table.contains(targets, t) -- 排除不合法的
    end)
    if #targets == 0 then return false end
    local all_targets = table.map(targets, Util.IdMapper)
    if #must_targets > 0 then
      targets = table.filter(targets, function (t)
        return not table.contains(must_targets, t)
      end)
    end
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = #targets,
      prompt = "#heta-choose:::"..data.card:toLogString(),
      skill_name = heta.name,
      cancelable = true,
      target_tip_name = "heta_tip",
      extra_data = {
        all_targets = all_targets,
        must_targets = table.map(must_targets, Util.IdMapper),
        contemporary_targets = table.map(contemporary_targets, Util.IdMapper),
      }
    })
    tos = table.connect(tos, must_targets)
    room:sortByAction(tos)
    local added, removed = {}, {}
    for _, p in ipairs(tos) do
      if table.contains(contemporary_targets, p) then
        table.insert(removed, p)
        data:removeTarget(p)
      else
        table.insert(added, p)
        data:addTarget(p)
      end
    end
    room:sendLog{
      type = "#RemoveTargetsBySkill",
      from = target.id,
      to = table.map(removed, Util.IdMapper),
      arg = heta.name,
      arg2 = data.card:toLogString(),
    }
    room:sendLog{
      type = "#AddTargetsBySkill",
      from = target.id,
      to = table.map(added, Util.IdMapper),
      arg = heta.name,
      arg2 = data.card:toLogString(),
    }
  end,
})

Fk:addTargetTip{
  name = "heta_tip", -- 修改自 addandcanceltarget_tip
  target_tip = function(_, _, to_select, _, _, _, selectable, extra_data)
    local data = extra_data.extra_data
    if not table.contains(data.all_targets, to_select.id) then return end
    local ret = {}
    if table.contains(data.contemporary_targets, to_select.id) then
      table.insert(ret, {content = "@@CancelTarget", type = "warning"} )
    else
      table.insert(ret, {content = "@@AddTarget", type = "normal"} )
    end
    if table.contains(data.must_targets, to_select.id) then
      table.insert(ret, {content = "@@heta_must", type = "warning"})
    end
    return ret
  end,
}

return heta
