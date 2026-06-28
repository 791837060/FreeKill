
local lianyou = fk.CreateSkill {
  name = "lianyou",
  max_branches_use_time = {
    ["lianyou_recover"] = {
      [Player.HistoryRound] = 1,
    },
    ["lianyou_equip"] = {
      [Player.HistoryRound] = 1,
    },
    ["lianyou_draw"] = {
      [Player.HistoryRound] = 1,
    },
  },
}

Fk:loadTranslationTable{
  ["lianyou"] = "怜幼",
  [":lianyou"] = "每轮每项限一次，当你受到伤害后，你可以选择一项：1.令一名体力值最少的角色回复2点体力；"..
  "2.令一名装备区牌最少的角色随机使用牌堆或弃牌堆中两张装备牌；3.摸三张牌并可以交给一名手牌数最少的其他角色三张牌。",

  ["#lianyou-invoke"] = "怜幼：你可以选择一项执行",
  ["lianyou_recover"] = "令一名角色回复2点体力",
  ["lianyou_equip"] = "令一名角色随机使用两张装备",
  ["lianyou_draw"] = "摸三张牌并可以交出三张牌",
  ["#lianyou-use"] = "怜幼：请使用%arg",
  ["#lianyou-give"] = "怜幼：你可以交给一名其他角色三张牌",

  ["$lianyou1"] = "",
  ["$lianyou2"] = "",
}

lianyou:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(lianyou.name) and
      player:usedSkillTimes(lianyou.name, Player.HistoryRound) < 3
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "#lianyou_active",
      prompt = "#lianyou-invoke",
      cancelable = true,
      skip = true,
    })
    if success and dat then
      event:setCostData(self, { tos = dat.targets, choice = dat.interaction })
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    player:addSkillBranchUseHistory(lianyou.name, choice, 1)
    if choice == "lianyou_recover" then
      local to = event:getCostData(self).tos[1]
      room:recover({
        who = to,
        num = 2,
        recoverBy = player,
        skillName = lianyou.name,
      })
    elseif choice == "lianyou_equip" then
      local to = event:getCostData(self).tos[1]
      for _ = 1, 2 do
        local cards = table.filter(room.draw_pile, function(id)
          return Fk:getCardById(id).type == Card.TypeEquip and to:canUse(Fk:getCardById(id))
        end)
        if #cards > 0 then
          local card = Fk:getCardById(room:tableRandomPick(cards))
          if to:canUseTo(card, to) then
            room:useCard{
              from = to,
              tos = {to},
              card = card,
            }
          else
            room:askToUseRealCard(to, {
              pattern = { card.id },
              skill_name = lianyou.name,
              prompt = "#lianyou-use:::"..card:toLogString(),
              cancelable = false,
              expand_pile = { card.id },
            })
          end
        end
      end
    elseif choice == "lianyou_draw" then
      player:drawCards(3, lianyou.name)
      if #player:getCardIds("he") < 3 or #room:getOtherPlayers(player, false) == 0 then return end
      local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return table.every(room:getOtherPlayers(player, false), function (q)
          return p:getHandcardNum() <= q:getHandcardNum()
        end)
      end)
      local to, cards = room:askToChooseCardsAndPlayers(player, {
        min_card_num = 3,
        max_card_num = 3,
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = lianyou.name,
        prompt = "#lianyou-give",
        cancelable = true,
      })
      if #to > 0 and #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, to[1], fk.ReasonGive, lianyou.name, nil, false, player)
      end
    end
  end,
})

return lianyou
