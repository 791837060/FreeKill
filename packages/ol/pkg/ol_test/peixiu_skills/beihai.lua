local beihai = fk.CreateSkill {
  name = "peixiu__beihai",
}

Fk:loadTranslationTable {
  ["peixiu_beihai"] = "北海",
  [":peixiu_beihai"] = "你获得此技能后，将手牌摸至体力上限。",
}

beihai:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == beihai.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room

    local n = player.maxHp - player:getHandcardNum()
    if n > 0 then
      player:drawCards(n, beihai.name)
    end
  end
})

return beihai
