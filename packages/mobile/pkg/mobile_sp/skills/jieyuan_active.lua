
local jieyuan_active = fk.CreateSkill {
  name = "#mobile__jieyuan_active",
}

Fk:loadTranslationTable{
  ["#mobile__jieyuan_active"] = "竭缘",
}

jieyuan_active:addEffect("active", {
  interaction = function (self, player)
    local event = self.event
    local n = (player:getMark("mobile__jieyuan_black") > 0 or player:getMark("mobile__jieyuan_red") > 0) and 2 or 1
    local choices = {}
    if event == 1 then
      choices = { "mobile__jieyuan_draw:::"..n..":black", "mobile__jieyuan_discard:::+"..n..":black" }
    else
      choices = { "mobile__jieyuan_draw:::"..n..":red", "mobile__jieyuan_discard:::-"..n..":red" }
    end
    if n == 1 then
      table.insert(choices, "mobile__jieyuan_beishui")
    end
    return UI.ComboBox { choices = choices }
  end,
  min_card_num = 0,
  max_card_num = 0,
  target_num = 0,
  card_filter = function (self, player, to_select, selected)
    if #selected == 0 and not player:prohibitDiscard(to_select) and
      not self.interaction.data:startsWith("mobile__jieyuan_draw") then
      if self.event == 1 then
        return Fk:getCardById(to_select).color == Card.Black
      else
        return Fk:getCardById(to_select).color == Card.Red
      end
    end
  end,
  feasible = function (self, player, selected, selected_cards, card)
    if self.interaction.data:startsWith("mobile__jieyuan_draw") then
      return #selected_cards == 0
    else
      return #selected_cards == 1
    end
  end,
})

return jieyuan_active
