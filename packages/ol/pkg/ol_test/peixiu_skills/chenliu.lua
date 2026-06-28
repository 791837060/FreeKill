local chenliu = fk.CreateSkill {
  name = "peixiu__chenliu",
}

Fk:loadTranslationTable {
  ["peixiu_chenliu"] = "陈留",
  [":peixiu_chenliu"] = "你跳过弃牌阶段。",
}

chenliu:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Discard
  end,
  on_use = function(self, event, target, player, data)
    player:skip(Player.Discard)
  end,
})

return chenliu
