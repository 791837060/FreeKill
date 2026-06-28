local mianzhu = fk.CreateSkill {
  name = "peixiu__mianzhu",
}

Fk:loadTranslationTable {
  ["peixiu_mianzhu"] = "绵竹",
  [":peixiu_mianzhu"] = "结束阶段，你观看牌堆顶三张牌，然后可以获得其中类型不同的牌各一张。",

  ["#peixiu_mianzhu-choose"] = "绵竹：选择要获得的牌",
}

mianzhu:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Finish
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local top = room:getNCards(3)
    if #top == 0 then return end
    local cards = room:askToChooseCard(player, {
      min_num = 0,
      max_num = #top,
      pattern = ".",
      skill_name = self.name,
      prompt = "#peixiu_mianzhu-choose",
      extra_data = top,
    })
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, self.name, "", false, player)
    end
    -- 将未获得的牌放回牌堆顶
    local remaining = table.filter(top, function(id)
      return not table.contains(cards, id)
    end)
    if #remaining > 0 then
      room:moveCardTo(remaining, Card.DrawPile, nil, fk.ReasonPut, self.name, "", false, player)
    end
  end,
})

return mianzhu
