local yinzhan = fk.CreateSkill {
  name = "yinzhan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["yinzhan"] = "饮战",
  -- [":yinzhan"] = "锁定技，当你使用【杀】对一名角色造成伤害时，若你的：体力值小于其，此伤害+1；手牌数小于其，" ..
  -- "你于此【杀】结算结束后弃置其一张牌。<a href='#ChengShi'>乘势</a>：你回复1点体力并获得其弃置的牌。",

  [":yinzhan"] = "锁定技，当你使用【杀】对一名角色造成伤害时，若你的：体力值不大于其，此伤害+1；手牌数不大于其，" ..
      "你于此【杀】结算结束后弃置其一张牌。<a href='#ChengShi'>乘势</a>：你回复1点体力并获得其弃置的牌。",

  ["$yinzhan1"] = "征战沙场，实乃平生快事。",
  ["$yinzhan2"] = "为主破敌，如鱼饮水。",
  ["$yinzhan3"] = "魏文长在此，尔辈何敢乃尔！",
}

yinzhan:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return
        target == player and
        data.card and
        data.card.trueName == "slash" and
        player:hasSkill(yinzhan.name) and
        data.to:isAlive() and
        (player.hp <= data.to.hp or #player:getCardIds("h") <= #data.to:getCardIds("h"))
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke(
      yinzhan.name,
      (player.hp <= data.to.hp and #player:getCardIds("h") <= #data.to:getCardIds("h")) and 3 or math.random(1, 2)
    )
    player.room:notifySkillInvoked(player, yinzhan.name, "offensive")

    local damageIncreased = false
    if player.hp <= data.to.hp then
      damageIncreased = true
      data:changeDamage(1)
    end

    local useEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if not useEvent then
      return false
    end
    local use = useEvent.data
    if #player:getCardIds("h") <= #data.to:getCardIds("h") then
      use.extra_data = use.extra_data or {}
      use.extra_data.yinzhanUser = player
      use.extra_data.yinzhanTargets = use.extra_data.yinzhanTargets or {}
      table.insert(use.extra_data.yinzhanTargets, data.to)
      if damageIncreased then
        use.extra_data.yinzhanChengShi = use.extra_data.yinzhanChengShi or {}
        table.insert(use.extra_data.yinzhanChengShi, data.to)
      end
    end
  end,
})

yinzhan:addEffect(fk.CardUseFinished, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return (data.extra_data or {}).yinzhanUser == player and player:isAlive()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = yinzhan.name
    local room = player.room
    room:sortByAction(data.extra_data.yinzhanTargets)

    for _, p in ipairs(data.extra_data.yinzhanTargets) do
      local throw_card
      if p:isAlive() and not p:isNude() then
        local card = room:askToChooseCard(
          player,
          {
            flag = "he",
            skill_name = skillName,
            target = p,
          }
        )
        throw_card = card
        room:throwCard(card, skillName, p, player)
      end

      if table.contains(data.extra_data.yinzhanChengShi or {}, p) then
        table.removeOne(data.extra_data.yinzhanChengShi, p)
        room:recover {
          who = player,
          num = 1,
          recoverBy = player,
          skillName = skillName,
        }

        if throw_card and room:getCardArea(throw_card) == Card.DiscardPile then
          room:obtainCard(player, throw_card, true, fk.ReasonPrey, player, skillName)
        end
      end
    end
  end,
})

return yinzhan
