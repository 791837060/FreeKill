local jiexun_active = fk.CreateSkill{
  name = "#mobile__jiexun_active",
}

Fk:loadTranslationTable{
  ["#mobile__jiexun_active"] = "诫训",
  ["mobile__jiexun_num"] = "%arg（%arg2张）",
}

jiexun_active:addEffect("active", {
  card_num = 0,
  target_num = 1,
  interaction = function ()
    local mapper = {
      log_spade = 0,
      log_club = 0,
      log_heart = 0,
      log_diamond = 0,
    }
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      for _, id in ipairs(p:getCardIds("ej")) do
        local suit = Fk:getCardById(id):getSuitString(true)
        mapper[suit] = mapper[suit] + 1
      end
    end
    local choices = {}
    for k, v in pairs(mapper) do
      v = math.min(v, 5)
      table.insert(choices, "mobile__jiexun_num:::"..k..":"..v)
    end
    return UI.ComboBox { choices = choices }
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
})

return jiexun_active
