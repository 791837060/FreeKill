local yingxiang = fk.CreateSkill{
  name = "yingxiang",
}

Fk:loadTranslationTable{
  ["yingxiang"] = "迎乡",
  [":yingxiang"] = "出牌阶段结束时，你可以声明一种基本牌或单目标普通锦囊牌的牌名，并与一名角色拼点，赢的角色视为使用你声明的牌。"..
  "若声明的牌与任意拼点牌牌名相同，你视为未发动过〖恤民〗；若均不同，你获得所有拼点牌并失去一个技能。",

  ["#yingxiang-choose"] = "迎乡：声明一种牌名并与一名角色拼点，赢者视为使用此牌",
  ["#yingxiang-use"] = "迎乡：请视为使用【%arg】",
  ["#yingxiang-lose"] = "迎乡：失去一个技能",

  ["$yingxiang1"] = "颍川冲要，不捍大难，冀州虽鄙，堪留余谷。",
  ["$yingxiang2"] = "西山冷冷，众卿莫怀守土依依。",
  ["$yingxiang3"] = "遣骑迎乡人，则韩氏不来唯荀姓独往。",
}

local U = require "packages.utility.utility"

yingxiang:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(yingxiang.name) and player.phase == Player.Play and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return player:canPindian(p)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choice = U.askForChooseCardNames(room, player, room:getBanner(yingxiang.name), 1, 1, yingxiang.name,
      "#yingxiang-choose", room:getBanner(yingxiang.name), true)
    if #choice == 0 then return end
    local targets = table.filter(room.alive_players, function(p)
      return player:canPindian(p)
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = yingxiang.name,
      prompt = "#yingxiang-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to, choice = choice[1]})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local choice = event:getCostData(self).choice
    room:sendLog{
      type = "#Choice",
      from = player.id,
      arg = choice,
      toast = true,
    }
    local pindian = player:pindian({to}, yingxiang.name)
    local winner = pindian.results[to].winner
    if not winner then return end
    if not winner.dead then
      room:askToUseVirtualCard(winner, {
        name = choice,
        skill_name = yingxiang.name,
        prompt = "#yingxiang-use:::"..choice,
        cancelable = false,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        },
      })
    end
    if player.dead then return end
    local yes = false
    if pindian.fromCard and (pindian.fromCard.name == choice or pindian.fromCard.trueName == choice) then
      yes = true
    end
    if pindian.results[to].toCard and (pindian.results[to].toCard.name == choice or pindian.results[to].toCard.trueName == choice) then
      yes = true
    end
    if yes then
      player:setSkillUseHistory("xumin", 0, Player.HistoryGame)
    else
      local cards = {}
      if pindian.fromCard then
        cards = table.filter(Card:getIdList(pindian.fromCard), function (id)
          return table.contains(room.discard_pile, id)
        end)
      end
      if pindian.results[to].toCard then
        for _, id in ipairs(Card:getIdList(pindian.results[to].toCard)) do
          if table.contains(room.discard_pile, id) then
            table.insertIfNeed(cards, id)
          end
        end
      end
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, yingxiang.name, nil, true, player)
      end
      if player.dead then return end
      if #player:getSkillNameList() > 0 then
        choice = U.askToChooseSkills(player, {
          skill_name = yingxiang.name,
          prompt = "#yingxiang-lose",
          min_num = 1, max_num = 1,
          skills = player:getSkillNameList(),
        })
        room:handleAddLoseSkills(player, "-"..choice[1])
      end
    end
  end,
})

yingxiang:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if not room:getBanner(yingxiang.name) then
    local all_names = Fk:getAllCardNames("b", true)
    for _, name in ipairs(Fk:getAllCardNames("t")) do
      if not Fk:cloneCard(name).multiple_targets and not Fk:cloneCard(name).is_passive then
        table.insert(all_names, name)
      end
    end
    room:setBanner(yingxiang.name, all_names)
  end
end)

return yingxiang
