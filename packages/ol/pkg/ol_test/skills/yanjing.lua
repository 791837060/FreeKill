local yanjing = fk.CreateSkill {
  name = "yanjing",
}

Fk:loadTranslationTable{
  ["yanjing"] = "焰靖",
  [":yanjing"] = "准备阶段，你可以指定一名其他角色并跳过本回合下X个阶段，对其造成1点火焰伤害（X为其体力值）。",

  ["#yanjing-choose"] = "焰靖：选择一名角色，跳过其体力值个阶段，对其造成1点火焰伤害",

  ["$yanjing1"] = "",
  ["$yanjing2"] = ""
}

yanjing:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yanjing.name) and player.phase == Player.Start and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
      prompt = "#yanjing-choose",
      skill_name = yanjing.name,
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
    room:addPlayerMark(player, "yanjing-turn", to.hp)
    room:damage{
      from = player,
      to = to,
      damage = 1,
      damageType = fk.FireDamage,
      skillName = yanjing.name,
    }
  end,
})

yanjing:addEffect(fk.EventPhaseChanging, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("yanjing-turn") > 0 and
      data.phase < Player.NotActive and not data.skipped
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:removePlayerMark(player, "yanjing-turn", 1)
    data.skipped = true
  end,
})

return yanjing
