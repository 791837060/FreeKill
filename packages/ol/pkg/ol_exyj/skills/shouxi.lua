local shouxi = fk.CreateSkill {
  name = "ol_ex__shouxi",
}

Fk:loadTranslationTable{
  ["ol_ex__shouxi"] = "守玺",
  [":ol_ex__shouxi"] = "每回合限一次，当你成为伤害牌的目标后，你可以弃置至少一张伤害牌，对使用者造成1点伤害。"..
  "然后若此牌未对你造成伤害，你摸牌至手牌上限。",

  ["#ol_ex__shouxi-invoke"] = "守玺：你可以弃置任意张伤害牌，对 %dest 造成1点伤害",

  ["$ol_ex__shouxi1"] = "皇天在上，必不佑尔佞臣贼子。",
  ["$ol_ex__shouxi2"] = "昔父执鞭以安天下，今兄何功得御九州？"
}

shouxi:addEffect(fk.TargetConfirmed, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shouxi.name) and
      data.card.is_damage_card and not player:isKongcheng() and
      player:usedSkillTimes(shouxi.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("h"), function (id)
      return Fk:getCardById(id).is_damage_card
    end)
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = player:getHandcardNum(),
      include_equip = false,
      skill_name = shouxi.name,
      cancelable = true,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "#ol_ex__shouxi-invoke::"..data.from.id,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, { tos = { data.from }, cards = card })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.extra_data = data.extra_data or {}
    data.extra_data.ol_ex__shouxi = data.extra_data.ol_ex__shouxi or {}
    table.insertIfNeed(data.extra_data.ol_ex__shouxi, player)
    room:throwCard(event:getCostData(self).cards, shouxi.name, player, player)
    if not data.from or data.from.dead then return end
    room:damage{
      from = player,
      to = data.from,
      damage = 1,
      skillName = shouxi.name,
    }
  end
})

shouxi:addEffect(fk.CardUseFinished, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and not (data.damageDealt and data.damageDealt[player]) and
      player:getHandcardNum() < player:getMaxCards() and
      data.extra_data and data.extra_data.ol_ex__shouxi and table.contains(data.extra_data.ol_ex__shouxi, player)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:getMaxCards() - player:getHandcardNum(), shouxi.name)
  end,
})

return shouxi
