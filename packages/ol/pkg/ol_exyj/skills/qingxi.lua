local qingxi = fk.CreateSkill {
  name = "ol_ex__qingxi",
}

Fk:loadTranslationTable{
  ["ol_ex__qingxi"] = "倾袭",
  [":ol_ex__qingxi"] = "当你使用【杀】对目标角色造成伤害时，你可以令其选择一项：1.弃置你攻击范围张牌；"..
  "2.令此【杀】对其伤害+1。若你的装备区有武器牌，则改为其依次执行这两项，然后弃置你装备区的武器牌。",

  ["#ol_ex__qingxi-invoke"] = "倾袭：是否对 %dest 发动“倾袭”？",
  ["#ol_ex__qingxi-discard"] = "倾袭：弃置%arg张牌，否则伤害+1",

  ["$ol_ex__qingxi1"] = "",
  ["$ol_ex__qingxi2"] = "",
}

qingxi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qingxi.name) and
      data.card and data.card.trueName == "slash" and data.by_user
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = qingxi.name,
      prompt = "#ol_ex__qingxi-invoke::"..data.to.id,
    }) then
      event:setCostData(self, { tos = { data.to } })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #player:getEquipCards(Card.SubtypeWeapon) > 0 then
      room:askToDiscard(data.to, {
        min_num = player:getAttackRange(),
        max_num = player:getAttackRange(),
        include_equip = true,
        skill_name = qingxi.name,
        cancelable = false,
      })
      data:changeDamage(1)
      room:throwCard(player:getEquipCards(Card.SubtypeWeapon), qingxi.name, player, player)
      return
    end
    if #room:askToDiscard(data.to, {
      min_num = player:getAttackRange(),
      max_num = player:getAttackRange(),
      include_equip = true,
      skill_name = qingxi.name,
      cancelable = true,
      prompt = "#ol_ex__qingxi-discard:::"..player:getAttackRange(),
    }) == player:getAttackRange() then
      room:throwCard(player:getEquipments(Card.SubtypeWeapon), qingxi.name, player, data.to)
    else
      data:changeDamage(1)
    end
  end,
})

return qingxi
