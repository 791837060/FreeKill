
local function HeyuFriend(room, player, friend)
  return (room:isGameMode("1v2_mode") or room:isGameMode("2v2_mode")) and
    table.find(room.alive_players, function (p)
      return p.role == player.role and (p.general == friend or p.deputyGeneral == friend)
    end)
end

local heyu = fk.CreateSkill {
  name = "zhangliao__heyu",
  tags = { Skill.Compulsory },
  dynamic_desc = function(self, player)
    if HeyuFriend(Fk:currentRoom(), player, "m_thoroughbred__yuejin") and
      HeyuFriend(Fk:currentRoom(), player, "m_thoroughbred__lidian") then
      return "zhangliao__heyu"
    elseif HeyuFriend(Fk:currentRoom(), player, "m_thoroughbred__yuejin") then
      return "zhangliao__heyu_yuejin"
    elseif HeyuFriend(Fk:currentRoom(), player, "m_thoroughbred__lidian") then
      return "zhangliao__heyu_lidian"
    end
    return "dummyskill"
  end,
}

Fk:loadTranslationTable{
  ["zhangliao__heyu"] = "合御",
  [":zhangliao__heyu"] = "锁定技，若友方骥乐进在场，〖冲垒〗的“非基本手牌”改为“手牌”；"..
  "若友方骥李典在场，〖荡势〗的X固定为3。（仅斗地主和2v2模式生效）",

  [":zhangliao__heyu_yuejin"] = "锁定技，若友方骥乐进在场，〖冲垒〗的“非基本手牌”改为“手牌”。",
  [":zhangliao__heyu_lidian"] = "锁定技，若友方骥李典在场，〖荡势〗的X固定为3。",

  ["$zhangliao__heyu1"] = "",
  ["$zhangliao__heyu2"] = "",
}

heyu:addEffect("targetmod", {
})

return heyu
