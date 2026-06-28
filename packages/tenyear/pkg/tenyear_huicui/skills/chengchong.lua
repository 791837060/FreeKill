local chengchong = fk.CreateSkill {
  name = "chengchong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["chengchong"] = "承宠",
  [":chengchong"] = "锁定技，你不以此技能获得牌时，若你手牌中红色牌数大于等于黑色牌，你摸2张牌，"..
    "然后对一名其他角色使用手牌中的黑色牌，若没有可对其使用的黑色牌则改为对其造成1点伤害。",

  ["#chengchong-choose"] = "承宠：选择1张黑色手牌对1名其他角色使用",
  ["#chengchong-damage"] = "承宠：选择1名其他角色，对其造成1点伤害",

  ["$chengchong1"] = "",
  ["$chengchong2"] = "",
}

chengchong:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(chengchong.name) then
      local handCards = player:getCardIds("h")
      local isGainOtherCard = false
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand and move.skillName ~= chengchong.name then
          isGainOtherCard = true
          for _, info in ipairs(move.moveInfo) do
            table.removeOne(handCards, info.cardId)
          end
        end
      end
      if not isGainOtherCard then
        return false
      end
      local colorDiff = 0
      for _, cardId in ipairs(handCards) do
        local card = Fk:getCardById(cardId)
        if card.color == Card.Red then
          colorDiff = colorDiff + 1
        elseif card.color == Card.Black then
          colorDiff = colorDiff - 1
        end
      end
      return colorDiff >= 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local skillName = chengchong.name
    player:drawCards(2, skillName)
    if player.dead then return end
    local room = player.room
    local players = room:getOtherPlayers(player, false)
    if #players == 0 then return end
    local useExtraData = { bypass_times = true, bypass_distances = true, exclusive_targets = table.map(players, Util.IdMapper) }
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if card.color == Card.Black then
        local tos = card:getDefaultTarget(player, useExtraData)
        if #tos > 0 then
          local success, dat = player.room:askToUseActiveSkill(player, {
            skill_name = "chengchong_active",
            prompt = "#chengchong-choose",
            cancelable = false,
          })
          local use
          if success and dat then
            use = {
              from = player,
              card = Fk:getCardById(dat.cards[1]),
              tos = dat.targets,
              extraUse = true,
            }
          else
            use = {
              from = player,
              card = card,
              tos = tos,
              extraUse = true,
            }
          end
          room:useCard(use)
          return
        end
      end
    end
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = players,
      skill_name = skillName,
      prompt = "#chengchong-damage",
      cancelable = false,
    })
    room:damage{
      from = player,
      to = tos[1],
      damage = 1,
      skillName = skillName,
    }
  end,
})

return chengchong
