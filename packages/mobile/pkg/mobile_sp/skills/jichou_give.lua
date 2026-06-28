local jichouGive = fk.CreateSkill {
  name = "jichou_give&",
}

Fk:loadTranslationTable{
  ["jichou_give&"] = "<font color='grey'>急筹[给牌]</font>",
  [":jichou_give&"] = "<font color='grey'>出牌阶段限一次，你可将至少一张“急筹”记录过牌名的牌交给一名角色。</font>",
}

jichouGive:addEffect("active", {
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(jichouGive.name, Player.HistoryPhase) == 0
  end,
  min_card_num = 1,
  max_card_num = 999,
  card_filter = function(self, player, to_select, selected)
    return table.contains(player:getTableMark("@$jichou"), Fk:getCardById(to_select).name)
  end,
  target_filter = function(self, player, to_select, selected)
    return to_select ~= player
  end,
  target_num = 1,
  on_use = function(self, room, effect)
    room:obtainCard(effect.tos[1], effect.cards, false, fk.ReasonGive, effect.from, jichouGive.name)
  end,
})

return jichouGive
