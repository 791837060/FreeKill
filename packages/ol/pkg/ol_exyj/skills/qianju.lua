
local qianju = fk.CreateSkill {
  name = "ol_ex__qianju",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ol_ex__qianju"] = "千驹",
  [":ol_ex__qianju"] = "锁定技，你每损失1点体力，你计算与其他角色的距离便-1；若全场其他角色均在你的攻击范围内，你出牌阶段使用【杀】的次数+1。",
}

qianju:addEffect("distance", {
  correct_func = function(self, from, to)
    if from:hasSkill(qianju.name) then
      return -from:getLostHp()
    end
  end,
})

qianju:addEffect("targetmod", {
  residue_func = function (self, player, skill, scope, card, to)
    if player:hasSkill(qianju.name) and
      table.every(Fk:currentRoom().alive_players, function (p)
        return p == player or player:inMyAttackRange(p)
      end) and
      card and card.trueName == "slash" then
      return 1
    end
  end,
})

return qianju
