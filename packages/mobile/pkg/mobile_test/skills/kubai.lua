local kubai = fk.CreateSkill {
  name = "kubai",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["kubai"] = "枯白",
  [":kubai"] = "1级：锁定技，你于回合内使用每种颜色的第一张牌时，你摸一张牌；其他角色于你的回合内不能使用有颜色且你未使用过的颜色的牌。<br />" ..
  "2级：锁定技，你于回合内使用每种花色的第一张牌时，你摸一张牌；其他角色于你的回合内不能使用有花色且你未使用过的花色的牌。<br />" ..
  "3级：锁定技，你于回合内使用每种点数的第一张牌时，你摸一张牌；其他角色于你的回合内不能使用有点数且你未使用过的点数的牌。",

  ["@kubai_level-noclear"] = "枯白等级",

  ["$kubai1"] = "字之体势，须一笔而成。",
  ["$kubai2"] = "偶有不连，而血脉不断。",
  ["$kubai3"] = "专精一体，方致绝伦。",
  ["$kubai4"] = "五合交臻，神融笔畅。",
  ["$kubai5"] = "转精其巧，亦可后来居上。",
  ["$kubai6"] = "一笔飞白，可堪独步无双。",
}

kubai:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    local current = player.room:getCurrent()
    if not (target == player and current == player and player:hasSkill(kubai.name)) then
      return false
    end

    local kubaiLevel = player:getMark("@kubai_level-noclear")
    if kubaiLevel <= 1 then
      return (data.extra_data or {}).firstKubaiColor
    elseif kubaiLevel == 2 then
      return (data.extra_data or {}).firstKubaiSuit
    else
      return (data.extra_data or {}).firstKubaiNumber
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, kubai.name)
  end,
})

kubai:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    local kubaiLevel = player:getMark("@kubai_level-noclear")
    if kubaiLevel <= 1 then
      return
        data.card.color ~= Card.NoColor and
        not table.contains(player:getTableMark("kubai_record-turn"), data.card.color)
    elseif kubaiLevel == 2 then
      return
        data.card.suit ~= Card.NoSuit and
        not table.contains(player:getTableMark("kubai_record-turn"), data.card.suit)
    else
      return
        data.card.number > 0 and
        not table.contains(player:getTableMark("kubai_record-turn"), data.card.number)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local kubaiLevel = player:getMark("@kubai_level-noclear")
    local toRecord
    data.extra_data = data.extra_data or {}
    if kubaiLevel <= 1 then
      toRecord = data.card.color
      data.extra_data.firstKubaiColor = true
    elseif kubaiLevel == 2 then
      toRecord = data.card.suit
      data.extra_data.firstKubaiSuit = true
    else
      toRecord = data.card.number
      data.extra_data.firstKubaiNumber = true
    end

    player.room:addTableMarkIfNeed(player, "kubai_record-turn", toRecord)
  end,
})

kubai:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    local current = Fk:currentRoom():getCurrent()
    if not (card and current and current ~= player and current:hasSkill(kubai.name)) then
      return false
    end

    local kubaiLevel = current:getMark("@kubai_level-noclear")
    if kubaiLevel <= 1 then
      return
        card.color ~= Card.NoColor and
        not table.contains(current:getTableMark("kubai_record-turn"), card.color)
    elseif kubaiLevel == 2 then
      return
        card.suit ~= Card.NoSuit and
        not table.contains(current:getTableMark("kubai_record-turn"), card.suit)
    else
      return
        card.number > 0 and
        not table.contains(current:getTableMark("kubai_record-turn"), card.number)
    end
  end,
})

kubai:addAcquireEffect(function(self, player)
  player.room:setPlayerMark(player, "@kubai_level-noclear", 1)
end)

kubai:addLoseEffect(function(self, player, isDeath)
  if not isDeath then
    player.room:setPlayerMark(player, "@kubai_level-noclear", 0)
  end
end)

return kubai
