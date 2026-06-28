local taohuai = fk.CreateSkill {
  name = "taohuai",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["taohuai"] = "讨怀",
  [":taohuai"] = "转换技，你使用手牌中点数：<br>阳：最大的牌；<br>阴：最小的牌。<br>摸一张牌。<br>否则你可弃置一张牌。",

  ["#taohuai-discard"] = "讨怀：你可以弃置一张牌（不会转换技能的阴阳状态）",

  ["$taohuai1"] = "",
  ["$taohuai2"] = "",
}

taohuai:addEffect(fk.CardUsing, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(taohuai.name) then
      if not player:isNude() then return true end
      local n = data.card.number
      if n == 0  or not data:isUsingHandcard(player) then return false end
      if player:getSwitchSkillState(taohuai.name) == fk.SwitchYang then
        return table.every(player:getCardIds("h"), function(id)
          return Fk:getCardById(id).number <= n
        end)
      else
        return table.every(player:getCardIds("h"), function(id)
          return Fk:getCardById(id).number >= n
        end)
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local n = data.card.number
    if n > 0 and data:isUsingHandcard(player) then
      if player:getSwitchSkillState(taohuai.name) == fk.SwitchYang then
        if table.every(player:getCardIds("h"), function(id)
            return Fk:getCardById(id).number <= n
        end) then
          return true
        end
      else
        if table.every(player:getCardIds("h"), function(id)
            return Fk:getCardById(id).number >= n
        end) then
          return true
        end
      end
    end
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = taohuai.name,
      cancelable = true,
      prompt = "#taohuai-discard",
      skip = true
    })
    if #card > 0 then
      --段家族特色？带一个不触发阴阳转换的效果
      event:setCostData(self, { cards = card, anim_type = "negative", no_switch = true })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event:getCostData(self) then
      player.room:throwCard(event:getCostData(self).cards, taohuai.name, player, player)
    else
      player:drawCards(1, taohuai.name)
    end
  end,
})

return taohuai
