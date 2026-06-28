local chouxi = fk.CreateSkill {
  name = "chouxic",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["chouxic"] = "仇隙",
  [":chouxic"] = "限定技，出牌阶段或受到伤害后，你可视为对一名其他角色使用一张无距离限制的【杀】，"..
    "若该角色本轮对你造成过伤害其随机弃置一张手牌。"..
    "当你弃置手牌时，若弃置手牌数大于等于当前你剩余手牌数，此技能视为未发动过。",

  ["#chouxic-invoke"] = "仇隙：你可视为使用一张【杀】",

  ["$chouxic1"] = "",
  ["$chouxic2"] = "",
}

---@param player ServerPlayer
---@param target ServerPlayer
local chouxiOnUse = function(player, target)
  local room = player.room
  local slash = Fk:cloneCard("slash")
  slash.skillName = chouxi.name
  room:useCard {
    from = player,
    tos = { target },
    card = slash,
    extraUse = true
  }
  if target.dead then return end
  local cards = target:getCardIds("h")
  if #cards == 0 then return end
  if #room.logic:getActualDamageEvents(1, function(e)
    local damage = e.data
    return damage.from == target and damage.to == player
  end, Player.HistoryRound) > 0 then
    cards = table.filter(cards, function(id)
      return not target:prohibitDiscard(id)
    end)
    if #cards > 0 then
      room:throwCard(room:tableRandomPick(cards, 1), chouxi.name, target, target)
    end
  end
end

chouxi:addEffect("active", {
  anim_type = "offensive",
  prompt = "#chouxic-invoke",
  can_use = function(self, player)
    if player:usedSkillTimes(chouxi.name, Player.HistoryGame) < 1 then
      local slash = Fk:cloneCard("slash")
      slash.skillName = chouxi.name
      return not player:prohibitUse(slash)
    end
  end,
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected == 0 and to_select ~= player then
      local slash = Fk:cloneCard("slash")
      slash.skillName = chouxi.name
      return not player:isProhibited(to_select, slash)
    end
  end,
  on_use = function(self, room, effect)
    chouxiOnUse(effect.from, effect.tos[1])
  end,
})

chouxi:addEffect(fk.Damaged, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player == target and player:hasSkill(chouxi.name) and
      player:usedSkillTimes(chouxi.name, Player.HistoryGame) < 1 then
      local slash = Fk:cloneCard("slash")
      slash.skillName = chouxi.name
      return not player:prohibitUse(slash)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local slash = Fk:cloneCard("slash")
    slash.skillName = chouxi.name
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and not player:isProhibited(p, slash)
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = chouxi.name,
      prompt = "#chouxic-invoke",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, { tos = to })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    chouxiOnUse(player, event:getCostData(self).tos[1])
  end,
})

chouxi:addEffect(fk.AfterCardsMove, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(chouxi.name) and player:usedSkillTimes(chouxi.name, Player.HistoryGame) > 0 then
      local n = player:getHandcardNum()
      for _, move in ipairs(data) do
        if move.from == player and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Player.Hand then
              n = n - 1
              if n < 1 then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:setSkillUseHistory(chouxi.name, 0, Player.HistoryGame)
  end,
})

return chouxi
