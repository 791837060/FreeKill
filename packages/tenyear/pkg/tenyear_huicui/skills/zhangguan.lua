local zhangguan = fk.CreateSkill {
  name = "zhangguan",
}

Fk:loadTranslationTable {
  ["zhangguan"] = "仗关",
  [":zhangguan"] = "每个回合开始时，你可以将手牌数调整至体力值，若你的手牌数因此：不变，你回复1点体力；减少，你获得当前回合角色一张牌。",

  ["$zhangguan1"] = "大将军战于前，我等何患之有？",
  ["$zhangguan2"] = "立国四十年，江油无战事！",
}

zhangguan:addEffect(fk.TurnStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhangguan.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getHandcardNum() - player.hp
    if n < 0 then
      player:drawCards(-n, zhangguan.name)
    elseif n == 0 then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = zhangguan.name,
      }
    elseif n > 0 then
      if #room:askToDiscard(player, {
        min_num = n,
        max_num = n,
        skill_name = zhangguan.name,
        cancelable = false,
        include_equip = false,
      }) == 0 then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = zhangguan.name,
        }
      elseif not player.dead and (target == player and #player:getCardIds("e") > 0 or not target:isNude()) then
        local id = room:askToChooseCard(player, {
          target = target,
          flag = target == player and "e" or "he",
          skill_name = zhangguan.name,
        })
        room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonPrey, zhangguan.name, nil, false, player)
      end
    end
  end,
})

return zhangguan
