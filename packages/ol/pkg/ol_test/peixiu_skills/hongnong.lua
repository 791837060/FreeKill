local hongnong = fk.CreateSkill {
  name = "peixiu__hongnong",
}

Fk:loadTranslationTable {
  ["peixiu_hongnong"] = "弘农",
  [":peixiu_hongnong"] = "你获得此技能后，可以重铸任意张装备牌并回复1点体力。",

  ["#peixiu_hongnong-discard"] = "弘农：重铸任意张装备牌并回复1点体力",
}

hongnong:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == hongnong.name
  end,
  on_cost = function (self, event, target, player, data)
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if player.dead then return end
    if not player:isWounded() then return end
    local equips = player:getCardIds("e")
    if #equips == 0 then return end
    local cards = room:askToDiscard(player, {
      min_num = 0,
      max_num = #equips,
      include_equip = true,
      skill_name = hongnong.name,
      prompt = "#peixiu_hongnong-discard",
      cancelable = true,
      skip = true,
    })
    if #cards > 0 then
      room:recastCard(cards, hongnong.name, player)
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = hongnong.name,
      }
    end
  end
})

return hongnong
