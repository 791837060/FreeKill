local huirui = fk.CreateSkill {
  name = "huirui",
}

Fk:loadTranslationTable{
  ["huirui"] = "挥锐",
  [":huirui"] = "出牌阶段开始或当你受到伤害后，你可以选择一项发动：1.获得两个“骑”；2.移动场上任意一个“骑”至任意其他角色处；"..
	"3.你视为使用一张【杀】。",

  ["#huirui-invoke"] = "挥锐：选择一项效果",
  ["huirui_gain"] = "获得2个“骑”",
  ["huirui_move"] = "移动场上1个“骑”给其他角色",
  ["huirui_slash"] = "视为使用一张【杀】",

  ["$huirui1"] = "",
  ["$huirui2"] = "",
}

---@type TrigSkelSpec<TrigFunc>
local spec = {
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = table.filter(room.alive_players, function(p)
      return p:getMark("@heqim") > 0
    end)
    if not (#tos > 1 or tos[1] == player) then
      room:addPlayerMark(player, "@heqim", 2)
      return
    end
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "huirui_active",
      prompt = "#huirui-invoke",
      cancelable = true,
      skip = true,
    })
    if success and dat then
      if dat.interaction == "huirui_move" then
        room:removePlayerMark(dat.targets[1], "@heqim", 1)
        room:addPlayerMark(dat.targets[2], "@heqim", 1)
      elseif dat.interaction == "huirui_slash" then
        local slash = Fk:cloneCard("slash")
        slash.skillName = "huirui"
        room:useCard {
          from = player,
          card = slash,
          tos = dat.targets,
          extraUse = true
        }
      else
        room:addPlayerMark(player, "@heqim", 2)
      end
    else
      room:addPlayerMark(player, "@heqim", 2)
    end
  end
}

--实测是必发效果（点取消会自动加标记）
huirui:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huirui.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = spec.on_use,
})

huirui:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:hasSkill(huirui.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = spec.on_use,
})

return huirui
