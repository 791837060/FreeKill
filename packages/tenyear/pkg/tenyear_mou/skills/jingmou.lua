local jingmou = fk.CreateSkill {
  name = "jingmou",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["jingmou"] = "靖谋",
  [":jingmou"] = "转换技，游戏开始时你可自选阴阳状态。一名角色的出牌阶段开始时，若你没有记录的花色或类别，" ..
  "你可弃置至少一张牌并秘密记录其中包含的花色与类别各一种；当一名角色使用与你记录的花色或类别相同的牌时，移除该记录，然后" ..
  "阳：此牌无效，你可弃置一张与之花色相同的手牌对使用者造成1点火焰伤害；阴：此牌结算结束后你将之交给一名角色。" ..
  "若你移除过所有花色和类别，你获得技能“<a href=':dingnan'>定南</a>”。",

  ["@[jingmouRecord]"] = "靖谋",
  ["#jingmou-discard"] = "靖谋：你可弃置至少一张牌，记录其中包含的花色与类别各一种",
  ["#jingmou-suit"] = "靖谋：请选择要记录的花色",
  ["#jingmou-type"] = "靖谋：请选择要记录的类别",
  ["#jingmou-damage"] = "靖谋：你可弃置一张%arg手牌，对 %dest 造成1点火焰伤害",
  ["#jingmou-choose"] = "靖谋：请选择一名角色，将%arg交给其",

  ["#JingMouRemoved"] = "已移除过的花色和类别",
  ["#JingMouSuits"] = "当前记录的花色",
  ["#JingMouTypes"] = "当前记录的类别",
  ["#JingMouNone"] = "无",
}

local U = require "packages.utility.utility"

jingmou:addEffect(fk.EventPhaseStart, {
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    if not (target.phase == Player.Play and player:hasSkill(jingmou.name)) then
      return false
    end

    local record = player:getMark("@[jingmouRecord]")
    record = type(record) == "table" and record or {}
    return #(record.suits or {}) == 0 and #(record.types or {}) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local ids = player.room:askToDiscard(
      player,
      {
        min_num = 1,
        max_num = #player:getCardIds("he"),
        skill_name = jingmou.name,
        include_equip = true,
        prompt = "#jingmou-discard",
        skip = true,
      }
    )

    if #ids > 0 then
      event:setCostData(self, { cards = ids })
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    ---@type string
    local skillName = jingmou.name
    local room = player.room

    ---@type integer[]
    local cards = event:getCostData(self).cards
    room:throwCard(cards, skillName, player, player)
    if not player:isAlive() then
      return false
    end

    local suits = {}
    local types = {}
    table.forEach(cards, function(id)
      local card = Fk:getCardById(id)
      table.insertIfNeed(types, card:getTypeString())
      if card.suit ~= Card.NoSuit then
        table.insertIfNeed(suits, card:getSuitString())
      end
    end)

    local record = player:getMark("@[jingmouRecord]")
    record = type(record) == "table" and record or {}
    if #suits > 0 then
      local suit = room:askToChoice(
        player,
        {
          choices = suits,
          prompt = "#jingmou-suit",
          skill_name = skillName,
        }
      )

      record.suits = record.suits or {}
      table.insertIfNeed(record.suits, suit)
    end

    if #types > 0 then
      local cardType = room:askToChoice(
        player,
        {
          choices = types,
          prompt = "#jingmou-type",
          skill_name = skillName,
        }
      )

      record.types = record.types or {}
      table.insertIfNeed(record.types, cardType)
    end

    room:setPlayerMark(player, "@[jingmouRecord]", record)
  end,
})

jingmou:addEffect(fk.CardUsing, {
  can_trigger = function (self, event, target, player, data)
    local record = player:getMark("@[jingmouRecord]")
    if not (player:hasSkill(jingmou.name) and record ~= 0) then
      return false
    end

    record = type(record) == "table" and record or {}
    return
      table.contains(record.suits or {}, data.card:getSuitString()) or
      table.contains(record.types or {}, data.card:getTypeString())
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, { switchState = player:getSwitchSkillState(jingmou.name) })
    return true
  end,
  on_use = function (self, event, target, player, data)
    ---@type string
    local skillName = jingmou.name
    local room = player.room
    local switchState = event:getCostData(self).switchState
    U.SetSwitchSkillState(player, skillName, player:getSwitchSkillState(skillName))

    local record = player:getMark("@[jingmouRecord]")
    record = type(record) == "table" and record or {}
    local curSuit = data.card:getSuitString()
    if table.contains(record.suits or {}, curSuit) then
      table.removeOne(record.suits, curSuit)
      record.removed = record.removed or {}
      table.insertIfNeed(record.removed, curSuit)
    end

    local curType = data.card:getTypeString()
    if table.contains(record.types or {}, curType) then
      table.removeOne(record.types, curType)
      record.removed = record.removed or {}
      table.insertIfNeed(record.removed, curType)
    end

    room:setPlayerMark(player, "@[jingmouRecord]", record)
    if #(record.removed or {}) > 6 then
      room:handleAddLoseSkills(player, "dingnan")
    end

    if switchState == fk.SwitchYang then
      data.toCard = nil
      data:removeAllTargets()
      if data.from:isAlive() and not player:isKongcheng() then
        local ids = room:askToDiscard(
          player,
          {
            min_num = 1,
            max_num = 1,
            pattern = ".|.|" .. data.card:getSuitString(),
            include_equip = false,
            skill_name = skillName,
            prompt = "#jingmou-damage::" .. data.from.id .. ":" .. data.card:getSuitString(),
            skip = true,
          }
        )

        if #ids > 0 then
          room:throwCard(ids, skillName, player, player)
          room:doIndicate(player, { data.from })
          room:damage{
            from = player,
            to = data.from,
            damage = 1,
            damageType = fk.FireDamage,
            skillName = skillName,
          }
        end
      end
    else
      data.extra_data = data.extra_data or {}
      data.extra_data.jingmouYinOwner = data.extra_data.jingmouYinOwner or {}
      table.insert(data.extra_data.jingmouYinOwner, player)
    end
  end,
})

jingmou:addEffect(fk.CardUseFinished, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return
      player:isAlive() and
      table.contains((data.extra_data or {}).jingmouYinOwner or {}, player) and
      player.room:getCardArea(data.card) == Card.Processing
  end,
  on_use = function (self, event, target, player, data)
    ---@type string
    local skillName = jingmou.name
    local room = player.room
    local tos = room:askToChoosePlayers(
      player,
      {
        min_num = 1,
        max_num = 1,
        targets = room:getAlivePlayers(false),
        skill_name = skillName,
        prompt = "#jingmou-choose:::" .. data.card:toLogString(),
        cancelable = false,
      }
    )

    room:obtainCard(tos[1], data.card, true, fk.ReasonGive, player, skillName)
  end,
})

jingmou:addEffect(fk.GameStart, {
  mute = true,
  is_delay_effect = true,
  priority = 1.5,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jingmou.name, true)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(
      player,
      {
        choices = { "tymou_switch:::jingmou:yang", "tymou_switch:::jingmou:yin" },
        skill_name = jingmou.name,
        prompt = "#tymou_switch-choice:::jingmou",
      }
    )
    choice = choice:endsWith("yang") and fk.SwitchYang or fk.SwitchYin
    U.SetSwitchSkillState(player, jingmou.name, choice)
  end,
})

Fk:addQmlMark{
  name = "jingmouRecord",
  how_to_show = function (name, value, player)
    return " "
  end,
  qml = function (name, value, player)
    if Self == player then
      return {
        url = "packages/tenyear/qml/JingMouBox.qml",
        prop = {
          name = name, value = value,
        },
      }
    end
  end,
}

return jingmou
