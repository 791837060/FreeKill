local zhuangshi = fk.CreateSkill {
  name = "zhuangshi",
}

Fk:loadTranslationTable{
  ["zhuangshi"] = "壮誓",
  [":zhuangshi"] = "出牌阶段开始时，你可以依次执行至少一项：1.弃置至少一张手牌，然后你此阶段使用的前X张牌无距离限制且不可被响应" ..
  "（X为你以此法弃置的牌数）；2.失去至少1点体力，然后你此阶段使用的前等量张牌不计入次数。",

  ["#zhuangshi-discard"] = "壮誓：你可弃置至少一张手牌，令本阶段使用前等量张牌无视距离且不可响应",
  ["#zhuangshi-loseHp"] = "壮誓：你可失去至少一点体力，令本阶段使用前等量张牌不计次数",
  ["@zhuangshi-phase"] = "壮誓",

  ["$zhuangshi1"] = "若魏寇将十万之众，延当为主公尽歼。	",
  ["$zhuangshi2"] = "纵曹贼举天下进犯，延亦可勠力拒退。",
}

zhuangshi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhuangshi.name) and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    ---@type string
    local skillName = zhuangshi.name
    local room = player.room

    local toDiscard = room:askToDiscard(
      player,
      {
        min_num = 1,
        max_num = player:getHandcardNum(),
        skill_name = skillName,
        prompt = "#zhuangshi-discard",
        skip = true,
      }
    )

    local toLose
    if player.hp > 0 then
      toLose = room:askToNumber(
        player,
        {
          min = 1,
          max = player.hp,
          skill_name = skillName,
          cancelable = true,
          prompt = "#zhuangshi-loseHp"
        }
      )
    end

    if #toDiscard > 0 or toLose then
      event:setCostData(self, { cards = toDiscard, hp = toLose })
    else
      event:setCostData(self, { cancelled = true })
    end

    return true
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = zhuangshi.name
    local room = player.room

    local costData = event:getCostData(self) or Util.DummyTable
    if not costData.cancelled then
      if #(costData.cards or {}) > 0 or (costData.hp or 0) > 0 then
        room:setPlayerMark(player, "@zhuangshi-phase", { #costData.cards, costData.hp })
      end
      if #(costData.cards or {}) > 0 then
        room:throwCard(costData.cards, skillName, player, player)
      end

      if not player:isAlive() then
        return false
      end

      if costData.hp then
        room:loseHp(player, costData.hp, skillName)
      end
    end
  end,
})

zhuangshi:addEffect(fk.PreCardUse, {
  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    return target == player and #player:getTableMark("@zhuangshi-phase") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local zhuangshiBuff = player:getTableMark("@zhuangshi-phase")
    if #zhuangshiBuff > 0 and zhuangshiBuff[1] > 0 then
      zhuangshiBuff[1] = zhuangshiBuff[1] - 1
      data.disresponsiveList = room:getAllPlayers(false)
    end

    if #zhuangshiBuff > 1 and zhuangshiBuff[2] > 0 then
      zhuangshiBuff[2] = zhuangshiBuff[2] - 1
      data.extraUse = true
    end

    if table.every(zhuangshiBuff, function(buff) return buff == 0 end) then
      zhuangshiBuff = 0
    end

    room:setPlayerMark(player, "@zhuangshi-phase", zhuangshiBuff)
  end,
})

zhuangshi:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card, to)
    if not card then
      return false
    end

    local zhuangshiBuff = player:getTableMark("@zhuangshi-phase")
    return #zhuangshiBuff > 0 and zhuangshiBuff[1] > 0
  end,
})

zhuangshi:addLoseEffect(function(self, player)
  if player:getMark("@zhuangshi-phase") ~= 0 then
    player.room:setPlayerMark(player, "@zhuangshi-phase", 0)
  end
end)

return zhuangshi
