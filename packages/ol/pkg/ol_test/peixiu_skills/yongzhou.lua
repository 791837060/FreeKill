local yongzhou = fk.CreateSkill {
  name = "peixiu__yongzhou",
}

Fk:loadTranslationTable {
  ["peixiu_yongzhou"] = "雍州",
  [":peixiu_yongzhou"] = "你获得此技能后，可以摸两张牌，然后将手牌弃至手牌上限。",

  ["#peixiu_yongzhou-invoke"] = "雍州：是否摸两张牌，然后将手牌弃至手牌上限？",
}

yongzhou:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == yongzhou.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if not room:askToSkillInvoke(player, {skill_name = yongzhou.name, prompt = "#peixiu_yongzhou-invoke"}) then return false end
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(2, yongzhou.name)
    if not player.dead then
      local handcards = player:getCardIds("h")
      local max = player.maxHp
      if #handcards > max then
        local to_discard = room:askToDiscard(player, {
          min_num = #handcards - max,
          max_num = #handcards - max,
          skill_name = yongzhou.name,
        })
        if #to_discard > 0 then
          room:throwCard(to_discard, yongzhou.name, player, player)
        end
      end
    end
  end
})

return yongzhou
