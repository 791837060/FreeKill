local shawuActive = fk.CreateSkill {
  name = "shawu_active",
}

Fk:loadTranslationTable{
  ["shawu_active"] = "沙舞",
  ["shawu_discard"] = "弃置两张牌",
  ["shawu_remove"] = "移去1枚“沙”标记"
}

shawuActive:addEffect("active", {
  interaction = function(self, player)
    local choices = { "shawu_discard", "shawu_remove" }
    if player:getMark("@xiaowu_sand") == 0 then
      table.remove(choices, 2)
    end

    return UI.ComboBox { choices = choices, all_choices = { "shawu_discard", "shawu_remove" } }
  end,
  card_num = function(self, player)
    return self.interaction.data == "shawu_discard" and 2 or 0
  end,
  target_num = 0,
  card_filter = function(self, player, to_select, selected)
    if self.interaction.data == "shawu_discard" then
      return
        #selected < 2 and
        Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand and
        not player:prohibitDiscard(to_select)
    end

    return false
  end,
})

return shawuActive
