local shunji = fk.CreateSkill {
  name = "shunji",
  max_branches_use_time = function(self, player)
    local ret = {}
    for _, to in ipairs(Fk:currentRoom().players) do
      ret[tostring(to.id)] = {
        [Player.HistoryRound] = 1,
      }
    end
    return ret
  end
}

local U = require "packages.utility.utility"

Fk:loadTranslationTable {
  ["shunji"] = "顺机",
  [":shunji"] = "每轮每名角色限一次，当一名角色受到伤害后，你可以摸至多两张牌，然后交给其等量张牌。若你因此失去了一个牌名的所有牌" ..
      "（每个牌名限一次），你对其造成1点伤害。",

  ["#shunji-invoke"] = "顺机：是否对 %dest 发动“顺机”，摸1~2张牌并交给其等量张牌",
  ["#shunji-give"] = "顺机：交给 %dest %arg张牌，交出特定牌对其造成1点伤害",
  ["@@shunji-tmp"] = "顺机",
  ["@[private]$shunji"] = "顺机",

  ["$shunji1"] = "人臣匡世，岂处今日之功而能久者？",
  ["$shunji2"] = "公复间之，可使两贼相持，坐待其弊。",
  ["$shunji3"] = "吾但顺时而行，自得其所成也。",
}

shunji:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return
      player:hasSkill(shunji.name) and
      not target.dead and
      shunji:withinBranchTimesLimit(player, tostring(target.id), Player.HistoryRound)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      skill_name = shunji.name,
      choices = { "1", "2", "Cancel" },
      prompt = "#shunji-invoke::" .. target.id,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {
        tos = { target },
        choice = tonumber(choice),
        history_branch = tostring(target.id)
      })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = event:getCostData(self).choice
    player:drawCards(n, shunji.name)

    if player == target or player.dead or target.dead or player:isNude() then
      return
    end

    local record = player:getTableMark(shunji.name)
    local nameBanSet = {}
    for _, name in ipairs(record) do
      nameBanSet[name] = true
    end

    --FIXME: 等待card_tip功能
    local allHeIds = player:getCardIds("he")
    local cardCache = {}
    for _, cid in ipairs(allHeIds) do
      local c = Fk:getCardById(cid)
      cardCache[cid] = c
      room:setCardMark(c, "@@shunji-tmp", nameBanSet[c.trueName] and 0 or 1)
    end

    local cards = room:askToCards(player, {
      min_num = n,
      max_num = n,
      include_equip = true,
      skill_name = shunji.name,
      prompt = "#shunji-give::" .. target.id .. ":" .. n,
      cancelable = false,
    })

    for _, cid in ipairs(allHeIds) do
      local c = cardCache[cid]
      if c then
        room:setCardMark(c, "@@shunji-tmp", 0)
      end
    end

    local damage = false
    local selectedIdSet = {}
    local selectedNames = {}
    for _, cid in ipairs(cards) do
      selectedIdSet[cid] = true
      selectedNames[cardCache[cid].trueName] = true
    end

    local remainNames = {}
    for _, cid in ipairs(allHeIds) do
      if not selectedIdSet[cid] then
        remainNames[cardCache[cid].trueName] = true
      end
    end

    for _, cid in ipairs(cards) do
      local name = cardCache[cid].trueName
      if selectedNames[name] and not remainNames[name] and not nameBanSet[name] then
        nameBanSet[name] = true
        record[#record + 1] = name
        damage = true
      end
    end

    if damage then
      U.setPrivateMark(player, "$shunji", record)
      room:setPlayerMark(player, shunji.name, record)
    end

    room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, shunji.name, nil, false, player)

    if damage and not target.dead then
      room:damage {
        from = player,
        to = target,
        damage = 1,
      }
    end
  end,
})

shunji:addLoseEffect(function(self, player, is_death)
  player.room:setPlayerMark(player, shunji.name, 0)
end)

return shunji
