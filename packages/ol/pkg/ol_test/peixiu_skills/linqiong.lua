local linqiong = fk.CreateSkill {
  name = "peixiu__linqiong",
}

Fk:loadTranslationTable {
  ["peixiu_linqiong"] = "临邛",
  [":peixiu_linqiong"] = "你获得此技能后，可以令任意名角色同时弃置一张牌。",

  ["#peixiu_linqiong-choose"] = "临邛：选择任意名角色，令其同时弃置一张牌",
}

linqiong:addEffect(fk.EventAcquireSkill, {
  can_trigger = function (self, event, target, player, data)
    return target == player and data.skill.name == linqiong.name
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = #room.alive_players,
      targets = room.alive_players,
      skill_name = linqiong.name,
      prompt = "#peixiu_linqiong-choose",
    })
    if #targets == 0 then return false end
    event:setCostData(self, { tos = targets })
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = event:getCostData(self).tos

    for _, p in ipairs(targets) do
      if not p.dead and not p:isNude() then
        local card = room:askToChooseCard(p, {
          flag = "he",
          skill_name = linqiong.name,
        })
        if #card > 0 then
          room:throwCard(card, linqiong.name, p, p)
        end
      end
    end
  end
})

return linqiong
