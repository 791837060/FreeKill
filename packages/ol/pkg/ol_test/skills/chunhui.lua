
local chunhui = fk.CreateSkill{
  name = "chunhui",
  dynamic_desc = function (self, player, lang)
    if player:getMark("chunhui") > 0 then
      return "chunhui_inner"
    end
  end,
}

Fk:loadTranslationTable{
  ["chunhui"] = "春晖",
  [":chunhui"] = "准备阶段或当你受到伤害后，你可以令一名其他角色交给你一张牌，若此牌为黑色，本轮你与其下一次使用红色牌时，你可以为此牌"..
  "增加或减少一个目标（目标数至少为1）。",

  [":chunhui_inner"] = "准备阶段或当你受到伤害后，你可以令一名其他角色交给你一张牌，若此牌为黑色，本轮你与其下一次使用黑色牌时，你可以为此牌"..
  "增加或减少一个目标（目标数至少为1）。",

  ["#chunhui-choose"] = "春晖：令一名角色交给你一张牌，若为黑色则双方下次使用牌可增减目标",
  ["#chunhui-give"] = "春晖：请交给 %src 一张牌，若为黑色则双方下次使用牌可增减目标",
  ["@@chunhui-round"] = "春晖",
  ["#chunhui-add"] = "春晖：你可以为%arg增加或减少一个目标",

  ["$chunhui1"] = "",
  ["$chunhui2"] = "",
}

local spec = {
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return not p:isNude()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = chunhui.name,
      prompt = "#chunhui-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, { tos = to })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = room:askToCards(to, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = chunhui.name,
      prompt = "#chunhui-give:"..player.id,
      cancelable = false,
    })
    local yes = Fk:getCardById(cards[1]).color == Card.Black
    room:obtainCard(player, cards, false, fk.ReasonGive, to, chunhui.name)
    if yes then
      if not player.dead then
        room:addTableMarkIfNeed(player, "@@chunhui-round", player)
      end
      if not to.dead then
        room:addTableMarkIfNeed(to, "@@chunhui-round", player)
      end
    end
  end,
}

chunhui:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(chunhui.name) and player.phase == Player.Start and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not p:isNude()
      end)
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})
chunhui:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(chunhui.name) and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not p:isNude()
      end)
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

chunhui:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return table.contains(target:getTableMark("@@chunhui-round"), player) and
      player:getMark(chunhui.name) + data.card.color == 2
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:removeTableMark(target, "@@chunhui-round", player)
    local targets = data:getExtraTargets()
    if #data.tos > 1 then
      table.insertTableIfNeed(targets, data.tos)
    end
    if #targets > 0 then
      local tos = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#chunhui-add:::"..data.card:toLogString(),
        skill_name = chunhui.name,
        cancelable = true,
        extra_data = table.map(data.tos, Util.IdMapper),
        target_tip_name = "addandcanceltarget_tip",
      })
      if #tos > 0 then
        local to = tos[1]
        if table.contains(data.tos, to) then
          data:removeTarget(to)
        else
          data:addTarget(to)
        end
      end
    end
  end,
})

chunhui:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, chunhui.name, 0)
end)

return chunhui
