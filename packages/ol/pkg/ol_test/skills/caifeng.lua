local caifeng = fk.CreateSkill{
  name = "caifeng",
}

Fk:loadTranslationTable{
  ["caifeng"] = "采风",
  [":caifeng"] = "出牌阶段每幅地图限一次，你可以弃置任意张牌，然后从牌堆或弃牌堆中随机获得等量张其余花色的牌。",

  ["#caifeng"] = "采风：弃置任意张牌，获得等量张其余花色的牌",

  ["$caifeng1"] = "",
  ["$caifeng2"] = "",
}

caifeng:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#caifeng",
  min_card_num = 1,
  target_num = 0,
  can_use = function (self, player)
    return player:getMark("@[maozhu]") ~= 0 and
      not table.contains(player:getTableMark("caifeng-phase"), player:getMark("@[maozhu]").name)
  end,
  card_filter = function(self, player, to_select, selected)
    return not player:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:addTableMark(player, "caifeng-phase", player:getMark("@[maozhu]").name)
    local suits = { "spade", "heart", "club", "diamond" }
    for _, id in ipairs(effect.cards) do
      table.removeOne(suits, Fk:getCardById(id):getSuitString())
    end
    room:throwCard(effect.cards, caifeng.name, player, player)
    if player.dead then return end
    local suit_pattern = table.concat(suits, ",")
    local cards = room:getCardsFromPileByRule(".|.|" .. suit_pattern, #effect.cards, "allPiles")
    if #cards > 0 then
      room:obtainCard(player, cards, false, fk.ReasonJustMove, player, caifeng.name)
    end
  end,
})

return caifeng
