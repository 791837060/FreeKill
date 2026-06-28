local maozhu = fk.CreateSkill{
  name = "maozhu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["maozhu"] = "茂著",
  [":maozhu"] = "锁定技，回合开始，或你绘制了一幅“地图”的所有城市，你将手牌中的花色补至4，并展开一幅“地图”。"..
  "回合结束时，你<font color='red'>获得一个本回合已展开的“地图”技能（暂无）</font>，直到你下回合结束。"..
  "<b><font color='red'>声明：裴秀目前机制不明且未正式上线，本实现仅供娱乐！</font></b>",

  ["@[maozhu]"] = "茂著",

  ["$maozhu1"] = "",
  ["$maozhu2"] = "",
}

local M = require "packages.ol.pkg.ol_test.peixiu_util"

maozhu:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(maozhu.name)
  end,
  on_use = function(self, event, target, player, data)
    M.maozhuEffect(player)
  end,
})

maozhu:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return player == target and player:hasSkill(maozhu.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@[maozhu]", 0)
    -- TODO: 选技能
  end,
})

Fk:addQmlMark({
  name = "maozhu",
  how_to_show = function(name, value, player)
    if type(value) ~= "table" then return " " end
    local ret = Fk:translate(value.name)
    local n = M.effectToBeDone(value.map)
    ret = ret .. " 剩" .. n
    return ret
  end,
  qml = {
    url = "packages/ol/qml/Maozhu.qml",
  }
})

return maozhu
