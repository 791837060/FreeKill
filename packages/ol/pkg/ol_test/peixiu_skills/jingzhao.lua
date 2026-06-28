local jingzhao = fk.CreateSkill {
  name = "peixiu__jingzhao",
}

Fk:loadTranslationTable {
  ["peixiu_jingzhao"] = "京兆",
  [":peixiu_jingzhao"] = "若有角色本回合对你使用过：【杀】/伤害锦囊牌，伤害锦囊牌/【杀】对你无效。",
}

jingzhao:addEffect(fk.TargetConfirming, {
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(self.name) then return false end
    local card = data.card
    if not card then return false end
    local room = player.room
    local from = data.from
    if not from then return false end
    if card.type == Card.TypeTrick and card.isDamageTrick then
      -- 检查本回合是否被使用过杀
      for _, record in ipairs(room.log) do
        if record.type == fk.CardUsing and record.from == from and record.card.trueName == "slash" then
          return true
        end
      end
    end
    if card.trueName == "slash" then
      -- 检查本回合是否被使用过伤害锦囊
      for _, record in ipairs(room.log) do
        if record.type == fk.CardUsing and record.from == from and record.card.type == Card.TypeTrick and record.card.isDamageTrick then
          return true
        end
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    return true
  end,
})

return jingzhao
