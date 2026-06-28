
local juexun = fk.CreateSkill{
  name = "juexun",
}

Fk:loadTranslationTable{
  ["juexun"] = "绝殉",
  [":juexun"] = "有角色失去最后的手牌后，你可以对自己造成1点火焰伤害并重置〖燃缕〗，"..
  "若你因此进入濒死状态，令处于横置状态的其他角色下次受到火焰伤害+1。",

  ["#juexun-invoke"] = "绝殉：你可以对自己造成1点火焰伤害并重置“燃缕”",
  ["@@juexun"] = "受到火焰伤害+1",

  ["$juexun1"] = "",
  ["$juexun2"] = "",
}

---@param player ServerPlayer
---@param data MoveCardsData[]
---@return ServerPlayer[]
local getTargets = function(player, data)
  local room = player.room
  local targets = {}
  for _, move in ipairs(data) do
    if move.from and not table.contains(targets, move.from) and move.from:isKongcheng() then
      for _, info in ipairs(move.moveInfo) do
        if info.fromArea == Card.PlayerHand then
          table.insert(targets, move.from)
          break
        end
      end
    end
  end
  return targets
end

juexun:addEffect(fk.AfterCardsMove, {
  anim_type = "masochism",
  trigger_times = function(self, event, target, player, data)
    local room = player.room
    local targets = event:getSkillData(self, self.name .. ":" .. player.id)
    if targets then
      return #targets.unDone + (event.invoked_times[self.name] or 0)
    else
      return #getTargets(player, data)
    end
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(juexun.name)
  end,
  on_trigger = function(self, event, target, player, data)
    event:setSkillData(self, "cancel_cost", false)
    self:doCost(event, target, player, data)
    event:setSkillData(self, "cancel_cost", false)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = event:getSkillData(self, self.name .. ":" .. player.id)
    local to
    if targets then
      while #targets.unDone > 0 do
        local p = table.remove(targets.unDone, 1)
        table.insert(targets.done, p)
        to = p
        break
      end
    else
      local targets = getTargets(player, data)
      if #targets > 0 then
        room:sortByAction(targets)
        to = table.remove(targets, 1)
        event:setSkillData(self, self.name .. ":" .. player.id, { done = { to }, unDone = targets })
      end
    end
    if to and player.room:askToSkillInvoke(player, {
      skill_name = juexun.name,
      prompt = "#juexun-invoke",
    }) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:damage{
      from = player,
      to = player,
      damage = 1,
      damageType = fk.FireDamage,
      skillName = juexun.name,
    }
    room:setPlayerMark(player, "ranlv", 0)
  end,
})

juexun:addEffect(fk.EnterDying, {
  can_refresh = function(self, event, target, player, data)
    return target == player and
      data.damage and data.damage.skillName == juexun.name and data.damage.from == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if p.chained then
        room:setPlayerMark(p, "@@juexun", 1)
      end
    end
  end,
})

juexun:addEffect(fk.DamageInflicted, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and data.damage == fk.FireDamage and player:getMark("@@juexun") > 0
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(1)
    player.room:setPlayerMark(player, "@@juexun", 0)
  end,
})

return juexun
