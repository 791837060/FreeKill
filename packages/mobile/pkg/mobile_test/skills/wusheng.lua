local wusheng = fk.CreateSkill{
  name = "m_yuan__wusheng",
}

Fk:loadTranslationTable{
  ["m_yuan__wusheng"] = "武圣",
  [":m_yuan__wusheng"] = "你可以将任意张牌当无距离限制的【杀】使用或打出，此【杀】结算后，若你本回合首次以此数量转化牌，你摸两张牌且此【杀】不计入次数。",

  ["#m_yuan__wusheng"] = "武圣：你可以将任意张牌当无距离限制的【杀】使用或打出",

  ["$m_yuan__wusheng1"] = "斩奸除贼，誓卫汉祚！",
  ["$m_yuan__wusheng2"] = "非某好杀，实诛不义！",
  ["$m_yuan__wusheng3"] = "纵有千军贼兵，难挡关某一骑！",
  ["$m_yuan__wusheng4"] = "身陷重围？正合吾杀敌之志！",
}

wusheng:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#m_yuan__wusheng",
  handly_pile = true,
  filter_pattern = {
    min_num = 1,
    max_num = math.huge,
    pattern = ".",
  },
  view_as = function(self, player, cards)
    if #cards == 0 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = wusheng.name
    c:addSubcards(cards)
    return c
  end,
  after_use = function (self, player, use)
    if not player.dead then
      local room = player.room
      if #room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
        return e.data.from == player and e.data.card:isConverted() and
          #Card:getIdList(e.data.card) == #Card:getIdList(use.card)
      end, Player.HistoryTurn) +
        #room.logic:getEventsOfScope(GameEvent.RespondCard, 2, function (e)
        return e.data.from == player and e.data.card:isConverted() and
          #Card:getIdList(e.data.card) == #Card:getIdList(use.card)
      end, Player.HistoryTurn) == 1 then
        player:drawCards(2, wusheng.name)
        if not use.extraUse then
          use.extraUse = true
          player:addCardUseHistory(use.card.trueName, -1)
        end
      end
    end
  end,
})

wusheng:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return card and table.contains(card.skillNames, wusheng.name)
  end,
})

return wusheng
