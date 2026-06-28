local qiongtu = fk.CreateSkill {
  name = "ol__qiongtu",
  tags = { Skill.AttachedKingdom },
  attached_kingdom = {"qun"},
  derived_piles = "ol__qiongtu",
}

Fk:loadTranslationTable{
  ["ol__qiongtu"] = "穷途",
  [":ol__qiongtu"] = "群势力技，每回合限一次，你可视为使用一张【无懈可击】并摸一张牌，然后你须将一张非基本牌置于你的武将牌上。"..
    "若你未因此放置牌，你获得武将牌上的所有牌，并变更势力为魏。",

  ["#ol__qiongtu"] = "穷途：你可视为使用一张【无懈可击】并摸一张牌",
  ["#ol__qiongtu-ask"] = "穷途：选择一张非基本牌置于你的武将牌上",

  ["$ol__qiongtu1"] = "箭倒辕门，徒无用也，今大势去矣。",
  ["$ol__qiongtu2"] = "前狼后虎，凶蛇两端，不知何处能归？",
}

qiongtu:addEffect("viewas", {
  anim_type = "control",
  pattern = "nullification",
  prompt = "#ol__qiongtu",
  card_num = 0,
  card_filter = Util.FalseFunc,
  view_as = function(self, player)
    local card = Fk:cloneCard("nullification")
    card.skillName = qiongtu.name
    return card
  end,
  after_use = function(self, player, use)
    if player.dead then return end
    player:drawCards(1, qiongtu.name)
    local room = player.room
    if player.dead then return end
    local cards = room:askToCards(player, {
      skill_name = qiongtu.name,
      include_equip = true,
      min_num = 1,
      max_num = 1,
      pattern = ".|.|.|.|.|trick,equip",
      prompt = "#ol__qiongtu-ask",
      cancelable = false,
    })
    if #cards == 0 then
      cards = player:getPile(qiongtu.name)
      if #cards > 0 then
        room:obtainCard(player, cards, true, fk.ReasonJustMove, player, qiongtu.name)
        if player.dead then return end
      end
      room:changeKingdom(player, "wei", true)
    else
      player:addToPile(qiongtu.name, cards, true, qiongtu.name)
    end
  end,
  enabled_at_response = function(self, player, response)
    return not response and player:usedSkillTimes(qiongtu.name, Player.HistoryTurn) == 0
  end,
})

return qiongtu
