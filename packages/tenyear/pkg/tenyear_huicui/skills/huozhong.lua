local huozhong = fk.CreateSkill {
  name = "ty__huozhong",
}

Fk:loadTranslationTable {
  ["ty__huozhong"] = "惑众",
  [":ty__huozhong"] = "出牌阶段限两次，你可以展示一张手牌并选择攻击范围内任意名其他角色，这些角色依次选择一项：" ..
      "1.获得一名不为其与你的角色一张牌；2.交给你一张牌。然后手牌数最多的其他角色展示手牌并将所有与你展示牌类型相同的牌置入牌堆顶。",

  ["#ty__huozhong"] = "惑众：选择一张手牌展示",
  ["#ty__huozhong-choose"] = "惑众：选择攻击范围内任意名角色",
  ["#ty__huozhong-select"] = "惑众：选择获得另一名角色一张牌或交给 %src 一张牌",

  ["$ty__huozhong1"] = "杀贼之荣光，我魏讽，岂能独享！",
  ["$ty__huozhong2"] = "事败才叫造反，功成即是勤王！"
}

huozhong:addEffect("active", {
  anim_type = "control",
  prompt = "#ty__huozhong",
  card_num = 1,
  target_num = 0,
  max_phase_use_time = 2,
  times = function(self, player)
    return player.phase == Player.Play and 2 - player:usedEffectTimes(huozhong.name, Player.HistoryPhase) or -1
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local c_type = Fk:getCardById(effect.cards[1]).type
    player:showCards(effect.cards)
    if player.dead then return end
    local targets = table.filter(room.alive_players, function(p)
      return player:inMyAttackRange(p)
    end)
    if #targets == 0 then return end
    targets = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = #targets,
      prompt = "#ty__huozhong-choose",
      skill_name = huozhong.name,
      cancelable = true,
    })
    if #targets == 0 then return end
    room:sortByAction(targets)
    for _, p in ipairs(targets) do
      if p.dead then
        goto continue
      end
      local cards, tos = {}, {}
      if not p:isNude() then
        cards = { p:getCardIds("he")[1] }
      else
        tos = { table.find(room.alive_players, function(to) return to ~= p and to ~= player and not to:isNude() end) }
      end
      if #cards == 0 and #tos == 0 then
        goto continue
      end
      room:setPlayerMark(p, "ty__huozhong-temp", player.id)
      local success, dat = room:askToUseActiveSkill(p, {
        skill_name = "ty__huozhong_active",
        prompt = "#ty__huozhong-select:" .. player.id,
        cancelable = false,
        extra_data = { huozhongUser = player.id }
      })
      room:setPlayerMark(p, "ty__huozhong-temp", 0)
      if success and dat then
        cards = dat.cards
        tos = dat.targets
      end
      if #cards > 0 then
        room:moveCardTo(cards, Player.Hand, player, fk.ReasonGive, huozhong.name, nil, false, p)
      elseif #tos > 0 then
        local to = tos[1]
        local card = room:askToChooseCard(p, {
          target = to,
          flag = "he",
          skill_name = huozhong.name,
        })
        room:obtainCard(p, card, false, fk.ReasonPrey, p, huozhong.name)
      end
      ::continue::
    end
    targets = {}
    local max_hc = 1
    for _, p in ipairs(room:getAlivePlayers()) do
      if p ~= player then
        local x = p:getHandcardNum()
        if x > max_hc then
          max_hc = x
          targets = { p }
        elseif x == max_hc then
          table.insert(targets, p)
        end
      end
    end
    for _, p in ipairs(targets) do
      if not (p.dead or p:isKongcheng()) then
        local cards = table.filter(p:getCardIds("h"), function(id)
          return Fk:getCardById(id).type == c_type
        end)
        p:showCards(p:getCardIds("h"))
        cards = table.filter(p:getCardIds("h"), function(id)
          return table.contains(cards, id)
        end)
        if #cards > 0 then
          room:moveCardTo(cards, Card.DrawPile, nil, fk.ReasonPut, huozhong.name, nil, true, p)
        end
      end
    end
  end,
})

return huozhong
