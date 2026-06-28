local skel = fk.CreateSkill{
  name = "#UseCardRecoder",
}

skel:addEffect(fk.AfterCardUseDeclared, {
  priority = 1.001,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player == target and data.card
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, "UseCardRecord", data.card)
    room:addTableMark(player, "UseCardRecord-phase", data.card)
    room:addTableMark(player, "UseCardRecord-turn", data.card)
    room:addTableMark(player, "UseCardRecord-round", data.card)
  end
})

return skel
