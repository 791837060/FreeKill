local dingnan = fk.CreateSkill {
  name = "dingnan",
}

Fk:loadTranslationTable{
  ["dingnan"] = "定南",
  [":dingnan"] = "出牌阶段限一次，你可以令至少一名角色依次选择一项：1.打出一张【杀】；2.受到1点伤害。",

  ["#dingnan-active"] = "定南：你可令至少一名角色依次打出一张【杀】，否则其受到1点伤害",
  ["#dingnan-response"] = "定南：请打出一张【杀】，否则受到1点伤害",
}

dingnan:addEffect("active", {
  prompt = "#dingnan-active",
  card_num = 0,
  min_target_num = 1,
  max_target_num = 999,
  can_use = function (self, player)
    return player:usedSkillTimes(dingnan.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.TrueFunc,
  on_use = function (self, room, effect)
    local tos = effect.tos
    room:sortByAction(tos)
    table.forEach(tos, function(p)
      if p:isAlive() then
        local response = room:askToResponse(
          p,
          {
            pattern = "slash",
            skill_name = dingnan.name,
            prompt = "#dingnan-response",
          }
        )

        if response then
          room:responseCard(response)
        else
          room:damage{
            to = p,
            damage = 1,
            skillName = dingnan.name,
          }
        end
      end
    end)
  end,
})

return dingnan
