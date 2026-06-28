local huozhong = fk.CreateSkill {
  name = "ty__huozhong_active",
}

Fk:loadTranslationTable {
  ["ty__huozhong_active"] = "惑众",
  ["ty__huozhong_give"] = "给出牌",
  ["ty__huozhong_prey"] = "获得牌"
}

huozhong:addEffect("active", {
  interaction = function(self, player)
    local choices = { "ty__huozhong_prey", "ty__huozhong_give" }
    if player:isNude() then
      table.removeOne(choices, "ty__huozhong_give")
    end
    local huozhongUser = player:getMark("ty__huozhong-temp")
    if not table.find(Fk:currentRoom().alive_players, function(p)
          return not p:isNude() and p ~= player and p.id ~= huozhongUser
        end) then
      table.removeOne(choices, "ty__huozhong_prey")
    end
    if #choices == 0 then
      choices = { "ty__huozhong_give" }
    end
    return UI.ComboBox { choices = choices }
  end,
  card_num = function(self, player)
    return self.interaction.data == "ty__huozhong_give" and 1 or 0
  end,
  target_filter = function(self, player, to_select, selected, selected_cards, card, extra_data)
    if self.interaction.data == "ty__huozhong_prey" and not to_select:isNude() and player ~= to_select and to_select.id ~= extra_data.huozhongUser then
      return #selected == 0
    else
      return false
    end
  end,
  card_filter = function(self, player, to_select, selected)
    if self.interaction.data == "ty__huozhong_give" then
      return #selected == 0
    end
    return false
  end,
})

return huozhong
