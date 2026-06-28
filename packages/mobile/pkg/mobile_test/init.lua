local extension = Package:new("mobile_test")
extension.extensionName = "mobile"

extension:loadSkillSkelsByPath("./packages/mobile/pkg/mobile_test/skills")

Fk:loadTranslationTable{
  ["mobile_test"] = "手杀-测试服",
  ["m_liuyi"] = "六艺",
  ["m_sp_lord"] = "活动武将",
  ["m_yuan"] = "缘",
}

General:new(extension, "mobile__xianglang", "shu", 3):addSkills { "naxue", "yijie" }
Fk:loadTranslationTable{
  ["mobile__xianglang"] = "向朗",

  ["~mobile__xianglang"] = "子曰：有教无类。惜哉，未入学者多矣……",
}

General:new(extension, "m_friend__cuijun", "qun", 3):addSkills { "shunyi", "biwei", "cuijun__gongli" }
Fk:loadTranslationTable{
  ["m_friend__cuijun"] = "友崔钧",
  ["#m_friend__cuijun"] = "日奋金丝",
  ["illustrator:m_friend__cuijun"] = "凝聚永恒",

  ["~m_friend__cuijun"] = "与君等交何其之快，只惜无再聚之日矣……",
}

General:new(extension, "m_friend__shitao", "qun", 3):addSkills { "qinying", "lunxiong", "shitao__gongli" }
Fk:loadTranslationTable{
  ["m_friend__shitao"] = "友石韬",
  ["#m_friend__shitao"] = "月堕窠臼",
  ["illustrator:m_friend__shitao"] = "凝聚永恒",

  ["~m_friend__shitao"] = "空有一腔热血，却是报国无门……",
}

General:new(extension, "m_liuyi__caoxing", "qun", 4):addSkills { "jinzu", "anxianc" }
Fk:loadTranslationTable{
  ["m_liuyi__caoxing"] = "射曹性",
  ["#m_liuyi__caoxing"] = "喙晴阴鸷",
  ["~m_liuyi__caoxing"] = "未想此子，竟恐怖如斯……",
}

General:new(extension, "m_liuyi__luyu", "wei", 3):addSkills { "bingfa", "shuxing" }
Fk:loadTranslationTable{
  ["m_liuyi__luyu"] = "礼卢毓",
  ["#m_liuyi__luyu"] = "规鉴清理",
  ["illustrator:m_liuyi__luyu"] = "凝聚永恒",

  ["~m_liuyi__luyu"] = "臣闻君明则臣直，此所以有过敢谏也。",
}

local yuezhouyu = General:new(extension, "m_liuyi__zhouyu", "wu", 3)
yuezhouyu:addSkills { "shouyuez", "dieyin" }
yuezhouyu:addRelatedSkill("qinyin")
Fk:loadTranslationTable{
  ["m_liuyi__zhouyu"] = "乐周瑜",
  ["#m_liuyi__zhouyu"] = "顾曲周郎",
  ["illustrator:m_liuyi__zhouyu"] = "凝聚永恒",

  ["$qinyin_m_liuyi__zhouyu1"] = "散音沉沉，若松根盘壑。",
  ["$qinyin_m_liuyi__zhouyu2"] = "泛音泠泠，如江水流渚。",

  ["~m_liuyi__zhouyu"] = "伯牙碎琴酬知己，非昔绝响贵真意。",
}

General:new(extension, "m_liuyi__caozhi", "wei", 3):addSkills { "chongsi", "peidong" }
Fk:loadTranslationTable{
  ["m_liuyi__caozhi"] = "御曹植",
  ["#m_liuyi__caozhi"] = "赋怀河山",
  ["illustrator:m_liuyi__caozhi"] = "凝聚永恒",

  ["~m_liuyi__caozhi"] = "闲居非吾志，甘心赴国忧。",
}

local zhangzhi = General:new(extension, "m_liuyi__zhangzhi", "qun", 3)
zhangzhi:addSkill("mobile__shiju")
zhangzhi:addRelatedSkill("kubai")
Fk:loadTranslationTable{
  ["m_liuyi__zhangzhi"] = "书张芝",
  ["#m_liuyi__zhangzhi"] = "草圣",
  ["illustrator:m_liuyi__zhangzhi"] = "凝聚永恒",

  ["~m_liuyi__zhangzhi"] = "笔锋尽处，已无死生之隔。",
}

General:new(extension, "m_liuyi__liuhui", "qun", 3):addSkills { "mobile__geyuan", "chongcha" }
Fk:loadTranslationTable{
  ["m_liuyi__liuhui"] = "数刘徽",
  ["#m_liuyi__liuhui"] = "周天古率",
  ["illustrator:m_liuyi__liuhui"] = "凝聚永恒",

  ["~m_liuyi__liuhui"] = "九章注述已尽，吾可安心去矣。",
}

General:new(extension, "m_sp_lord__yuanshu", "qun", 4):addSkills { "jimi", "maodiey" }
Fk:loadTranslationTable{
  ["m_sp_lord__yuanshu"] = "集蜜袁术",
  -- ["#m_sp_lord__yuanshu"] = "",
  -- ["illustrator:m_sp_lord__yuanshu"] = "",

  ["~m_sp_lord__yuanshu"] = "朕集的蜜哪里去了……",
}

General:new(extension, "wooden_ox", "shu", 4):addSkills { "shezi", "yixing" }
Fk:loadTranslationTable{
  ["wooden_ox"] = "木牛流马",
  ["illustrator:wooden_ox"] = "特特肉",

  ["~wooden_ox"] = "机能有损，不能为丞相北伐效力了……",
}

General:new(extension, "chitu", "qun", 4):addSkills { "junkui", "chiyuanc" }
Fk:loadTranslationTable{
  ["chitu"] = "赤兔",
  ["illustrator:chitu"] = "特特肉",

  ["~chitu"] = "敬公之高义，愿与将军同死！",
}

General:new(extension, "dilu", "shu", 4):addSkills { "jiguan", "yuetan" }
Fk:loadTranslationTable{
  ["dilu"] = "的卢",
  ["illustrator:dilu"] = "特特肉",

  ["~dilu"] = "我果然，妨主了吗……",
}

General:new(extension, "jueying", "wei", 4):addSkills { "jiguan", "zhengpeng" }
Fk:loadTranslationTable{
  ["jueying"] = "绝影",
  ["illustrator:jueying"] = "特特肉",

  ["$jiguan_jueying1"] = "纵横宇内，追风绝影！",
  ["$jiguan_jueying2"] = "钢筋铁骨，力负千钧！",
  ["~jueying"] = "主公，奔赴美好的明天吧！",
}

General:new(extension, "m_yuan__tanshihuai", "qun", 4):addSkills { "lianzhant", "kouluet" }
Fk:loadTranslationTable{
  ["m_yuan__tanshihuai"] = "缘檀石槐",

  ["~m_yuan__tanshihuai"] = "儿郎们暂退阴山，他日我必卷土重来。",
}

General:new(extension, "m_yuan__lvbu", "qun", 4):addSkills { "luezhen", "hengwei" }
Fk:loadTranslationTable{
  ["m_yuan__lvbu"] = "缘吕布",

  ["~m_yuan__lvbu"] = "刘备小儿？安敢害我。",
}

General:new(extension, "m_yuan__gaoshun", "qun", 4):addSkills { "jiren", "juezhig" }
Fk:loadTranslationTable{
  ["m_yuan__gaoshun"] = "缘高顺",

  ["~m_yuan__gaoshun"] = "文远真英雄也。",
}

General:new(extension, "m_yuan__tadun", "qun", 4):addSkills { "youlve", "lianxi" }
Fk:loadTranslationTable{
  ["m_yuan__tadun"] = "缘蹋顿",

  ["~m_yuan__tadun"] = "袁氏误我啊！",
}

General:new(extension, "m_yuan__guanyu", "shu", 4):addSkills { "m_yuan__wusheng", "m_yuan__yijue" }
Fk:loadTranslationTable{
  ["m_yuan__guanyu"] = "缘关羽",

  ["~m_yuan__guanyu"] = "非关某无情，实各为其主。",
}

General:new(extension, "m_yuan__chenlan", "qun", 4):addSkills { "mobile__jujun" }
Fk:loadTranslationTable{
  ["m_yuan__chenlan"] = "缘陈兰",

  ["~m_yuan__chenlan"] = "天柱虽险，难挡真虎将……",
}

General:new(extension, "m_yuan__meicheng", "qun", 4):addSkills { "bixian" }
Fk:loadTranslationTable{
  ["m_yuan__meicheng"] = "缘梅成",

  ["~m_yuan__meicheng"] = "这张辽，果是一把好手……",
}

General:new(extension, "m_yuan__sunquan", "wu", 4):addSkills { "shizhong", "caowei" }
Fk:loadTranslationTable{
  ["m_yuan__sunquan"] = "缘孙权",

  ["~m_yuan__sunquan"] = "大业未成，当整军再战。",
}

General:new(extension, "m_yuan__zhangliao", "qun", 4):addSkills { "chonglei", "mou__tuxi", "kunfen" }
Fk:loadTranslationTable{
  ["m_yuan__zhangliao"] = "少年张辽",

  ["~m_yuan__zhangliao"] = "",
}

Fk:loadTranslationTable{
  ["m_liuyi__sunquan"] = "射孙权",
  ["#m_liuyi__sunquan"] = "",
  ["illustrator:m_liuyi__sunquan"] = "凝聚永恒",

  ["~m_liuyi__sunquan"] = "",
}

return extension
