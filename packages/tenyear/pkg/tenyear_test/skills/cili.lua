
local cili = fk.CreateSkill{
  name = "cili",
}

Fk:loadTranslationTable{
  ["cili"] = "慈厉",
  [":cili"] = "每轮开始时，你可以选择一名角色并记录其当前体力值，直到其下个回合结束时，若其于此回合内使用的牌数："..
  "小于记录值，你可以令一名角色随机弃置记录值张牌；大于等于记录值，你可以令一名角色摸记录值张牌。",

  ["#cili-choose"] = "慈厉：选择一名角色，记录其体力值，其回合结束时根据其本回合使用牌数执行效果",
  ["#cili-discard"] = "慈厉：你可以令一名角色随机弃置%arg张牌",
  ["#cili-draw"] = "慈厉：你可以令一名角色摸%arg张牌",

  ["$cili1"] = "",
  ["$cili2"] = "",
}

cili:addEffect(fk.RoundStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(cili.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      prompt = "#cili-choose",
      skill_name = cili.name,
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:setPlayerMark(to, "cili_hp-round", to.hp)
    room:addTableMark(to, "cili-round", player)
  end,
})

cili:addEffect(fk.TurnEnd, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(cili.name) and
      table.contains(target:getTableMark("cili-round"), player)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local use_events = room.logic:getEventsOfScope(GameEvent.UseCard, 999, function (e)
      return e.data.from == target
    end, Player.HistoryTurn)
    local n = target:getMark("cili_hp-round")
    if n > #use_events then
      local targets = table.filter(room.alive_players, function (p)
        return not p:isNude()
      end)
      if #targets > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = cili.name,
          prompt = "#cili-discard:::"..n,
          cancelable = true,
        })
        if #to > 0 then
          event:setCostData(self, { tos = to, choice = "discard" })
          return true
        end
      end
    else
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = room.alive_players,
        skill_name = cili.name,
        prompt = "#cili-draw:::"..n,
        cancelable = true,
      })
      if #to > 0 then
        event:setCostData(self, { tos = to, choice = "draw" })
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local choice = event:getCostData(self).choice
    if choice == "discard" then
      room:throwCard(room:tableRandomPick(to:getCardIds("he"), target:getMark("cili_hp-round")), cili.name, to, to)
    else
      to:drawCards(target:getMark("cili_hp-round"), cili.name)
    end
  end,

  late_refresh = true,
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "cili-round", 0)
  end,
})

return cili
