local poyin_active = fk.CreateSkill{
  name = "#poyin_active",
}

Fk:loadTranslationTable{
  ["#poyin_active"] = "迫饮",
  ["poyin_losthp"] = "已损失体力",
  ["poyin_hp"] = "当前体力",
}

poyin_active:addEffect("active", {
  target_num = 0,
  interaction = UI.ComboBox { choices = { "poyin_losthp", "poyin_hp" }},
  card_filter = function(self, player, to_select, selected)
    if table.contains(self.cards, to_select) then
      if self.interaction.data == "poyin_losthp" then
        return #selected < player:getLostHp()
      elseif self.interaction.data == "poyin_hp" then
        return #selected < player.hp
      end
    end
  end,
  feasible = function (self, player, selected, selected_cards, card)
    if #selected_cards == 0 then return end
    if self.interaction.data == "poyin_losthp" then
      return #selected_cards == player:getLostHp()
    elseif self.interaction.data == "poyin_hp" then
      return #selected_cards == player.hp
    end
  end,
})

return poyin_active
