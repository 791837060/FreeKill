local jiejie = fk.CreateSkill{
  name = "jiejie&",
}

Fk:loadTranslationTable{
  ["jiejie&"] = "诫节",
  [":jiejie&"] = "出牌阶段限一次，你可以令势辛宪英观看你的手牌，然后其可以选择一种花色，若你手牌："..
  "包含此花色，你本回合使用此花色的牌无次数限制，然后弃置其余花色的手牌；不包含此花色，你获得此花色的一张牌。"..
  "若你以此法向势辛宪英展示牌所包含的花色为本轮唯一最多，其视为对你发动一次〖清识〗。",

  ["#jiejie&"] = "诫节：令势辛宪英观看你的手牌，然后其选择一种花色，根据是否包含此花色执行效果",
}

local function findSkillOwner(skill_name)
  return table.filter(Fk:currentRoom().alive_players, function (p)
    return p:hasSkill(skill_name) and p:usedSkillTimes(skill_name, Player.HistoryPhase) == 0
  end)
end

jiejie:addEffect("active", {
  anim_type = "control",
  prompt = "#jiejie&",
  card_num = 0,
  min_target_num = 0,
  max_target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and #findSkillOwner("jiejie") > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function (self, player, to_select, selected)
    if #findSkillOwner("jiejie") == 1 then
      return false
    else
      return #selected == 0 and table.contains(findSkillOwner("jiejie"), to_select)
    end
  end,
  feasible = function (self, player, selected)
    if #findSkillOwner("jiejie") == 1 then
      return #selected == 0
    else
      return #selected == 1
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = findSkillOwner("jiejie")[1]
    if #effect.tos > 0 then
      target = effect.tos[1]
    end
    target:addSkillUseHistory("jiejie", 1)
    target:broadcastSkillInvoke("jiejie")
    local suits = {}
    for _, id in ipairs(player:getCardIds("h")) do
      table.insertIfNeed(suits, Fk:getCardById(id).suit)
    end
    table.removeOne(suits, Card.NoSuit)
    local yes = #suits > target:getMark("@jiejie-round")
    if yes then
      room:setPlayerMark(target, "@jiejie-round", #suits)
    end
    local choice = room:askToViewCardsAndChoice(target, {
      cards = player:getCardIds("h"),
      choices = { "log_spade", "log_heart", "log_club", "log_diamond", "Cancel" },
      skill_name = "jiejie",
      prompt = "#jiejie-choice::"..player.id,
    })
    if choice ~= "Cancel" then
      if table.find(player:getCardIds("h"), function (id)
        return Fk:getCardById(id):getSuitString(true) == choice
      end) then
        local others = table.filter(player:getCardIds("h"), function (id)
          return Fk:getCardById(id):getSuitString(true) ~= choice and not player:prohibitDiscard(id)
        end)
        if #others > 0 then
          room:throwCard(others, "jiejie", player, player)
        end
        if not player.dead then
          room:addTableMarkIfNeed(player, "jiejie-turn", choice)
        end
      else
        local card = room:getCardsFromPileByRule(".|.|" .. string.sub(choice, 5))
        if #card == 0 then
          card = room:getCardsFromPileByRule(".|.|" .. string.sub(choice, 5), 1, "discardPile")
        end
        if #card > 0 then
          room:obtainCard(player, card, false, fk.ReasonPrey, player, jiejie.name)
        end
      end
    end
    if
      yes and
      not player.dead and
      not target.dead and
      Fk.skills["jiejie"]:getSkeleton():withinBranchTimesLimit(target, "jiejie_most", Player.HistoryRound)
    then
      target:addSkillBranchUseHistory("jiejie", "jiejie_most", 1)
      local skill = Fk.skills["qingshix"]
      local event = fk.Damaged:new(room, target, {})
      event:setCostData(skill, {tos = {player}})
      skill:use(event, target, target, {})
    end
  end,
})

return jiejie
