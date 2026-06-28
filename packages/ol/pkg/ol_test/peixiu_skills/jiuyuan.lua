local jiuyuan = fk.CreateSkill {
  name = "peixiu__jiuyuan",
}

Fk:loadTranslationTable {
  ["peixiu_jiuyuan"] = "九原",
  [":peixiu_jiuyuan"] = "你使用【杀】可以额外指定任意名目标。",
}

jiuyuan:addEffect("targetmod", {
  extra_target_func = function(self, player, skill, scope, card, to)
    if card and card.trueName == "slash" then
      return #room.alive_players
    end
    return 0
  end,
})

return jiuyuan
