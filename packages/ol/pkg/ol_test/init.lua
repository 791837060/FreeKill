local extension = Package:new("ol_test")
extension.extensionName = "ol"

extension:loadSkillSkelsByPath("./packages/ol/pkg/ol_test/skills")

Fk:loadTranslationTable{
  ["ol_test"] = "OL-测试服",
}

General:new(extension, "dongtuna", "qun", 4):addSkills { "jianman" }
Fk:loadTranslationTable{
  ["dongtuna"] = "董荼那",
  ["#dongtuna"] = "铅刀拿云",
  ["designer:dongtuna"] = "大宝",
  ["illustrator:dongtuna"] = "monkey",

  ["~dongtuna"] = "孟获小儿，安敢杀我！",
}

General:new(extension, "ol__peixiu", "wei", 4):addSkills { "maozhu", "jinlan", "caifeng" }
extension:loadSkillSkelsByPath("./packages/ol/pkg/ol_test/peixiu_skills")
Fk:loadTranslationTable{
  ["ol__peixiu"] = "裴秀",
  ["#ol__peixiu"] = "勋德茂著",
  ["illustrator:ol__peixiu"] = "塔普",

  ["~ol__peixiu"] = "",
}

General:new(extension, "budugen", "qun", 4):addSkills { "kouchao" }
Fk:loadTranslationTable{
  ["budugen"] = "步度根",
  ["#budugen"] = "秋城雁阵",

  ["~budugen"] = "",
}

General:new(extension, "ol__liuzhang", "qun", 3):addSkills { "fengwei", "zonghu" }
Fk:loadTranslationTable{
  ["ol__liuzhang"] = "刘璋",
  --["#ol__liuzhang"] = "",

  ["~ol__liuzhang"] = "刘备呀刘备，我怎么就信了你！",
}

General:new(extension, "ol__yangfeng", "qun", 4):addSkills { "jiawei", "qujia" }
Fk:loadTranslationTable{
  ["ol__yangfeng"] = "杨奉",
  --["#ol__yangfeng"] = "",

  ["~ol__yangfeng"] = "刘使君，我乃陛下亲随呀！",
}

General:new(extension, "hanshiwuhu", "wei", 4):addSkills { "juejueh", "pimi" }
Fk:loadTranslationTable{
  ["hanshiwuhu"] = "韩氏五虎",
  ["#hanshiwuhu"] = "盛怒难却",
  ["illustrator:hanshiwuhu"] = "匠人绘",

  ["~hanshiwuhu"] = "我的儿呀！好你个老匹夫！",
}

General:new(extension, "ol__xiahouen", "wei", 4):addSkills { "yinfeng", "fulux" }
Fk:loadTranslationTable{
  ["ol__xiahouen"] = "夏侯恩",
  ["#ol__xiahouen"] = "长坂剑圣",--称号出自2026收藏
  ["illustrator:ol__xiahouen"] = "黯荧岛",

  ["~ol__xiahouen"] = "丞相！就是他抢咱们东西！",
}

General:new(extension, "ol__caizhenji", "wei", 3, 3, General.Female):addSkills { "kedi", "cunze" }
Fk:loadTranslationTable{
  ["ol__caizhenji"] = "蔡贞姬",
  --["#ol__caizhenji"] = "",

  ["~ol__caizhenji"] = "",
}

General:new(extension, "ol__qiaoxuan", "qun", 4):addSkills { "tingji", "xuanliu" }
Fk:loadTranslationTable{
  ["ol__qiaoxuan"] = "桥玄",
  ["#ol__qiaoxuan"] = "秉文握武",

  ["~ol__qiaoxuan"] = "瞒小子，你可听到鹿鸣呦呦？",
}

General:new(extension, "ol__fanyufeng", "qun", 3, 3, General.Female):addSkills { "zhuoyue", "qiaowu" }
Fk:loadTranslationTable{
  ["ol__fanyufeng"] = "樊氏",
  --["#ol__fanyufeng"] = "",

  ["~ol__fanyufeng"] = "",
}

General:new(extension, "ol__zhengxuan", "qun", 3):addSkills { "shixing", "dejiao" }
Fk:loadTranslationTable{
  ["ol__zhengxuan"] = "郑玄",
  ["#ol__zhengxuan"] = "弘道传德",

  ["~ol__zhengxuan"] = "汝等，汝等当慎行，慎行啊……",
}

General:new(extension, "ol__caojinyu", "wei", 3, 3, General.Female):addSkills { "chunhui", "xiasheng", "qiumu" }
Fk:loadTranslationTable{
  ["ol__caojinyu"] = "曹金玉",
  ["#ol__caojinyu"] = "春秋盈昃",

  ["~ol__caojinyu"] = "",
}

General:new(extension, "ol__dongguiren", "qun", 3, 3, General.Female):addSkills { "hexu", "zeguang", "chengen" }
Fk:loadTranslationTable{
  ["ol__dongguiren"] = "董予安",
  --["#ol__dongguiren"] = "",

  ["~ol__dongguiren"] = "汉之广矣，不可泳思。",
}

General:new(extension, "tangtang", "qun", 3, 3, General.Female):addSkills { "zexing", "zhiyit" }
Fk:loadTranslationTable{
  ["tangtang"] = "唐棠",
  ["#tangtang"] = "伊侍佐佑",

  ["~tangtang"] = "",
}

General:new(extension, "ol__liuye", "wei", 3):addSkills { "pingyuan", "liaoyil" }
Fk:loadTranslationTable{
  ["ol__liuye"] = "刘晔",
  --["#ol__liuye"] = "",

  ["~ol__liuye"] = "料尽天下事，难料吾之归途……",
}

General:new(extension, "pangji", "qun", 3):addSkills { "biguo", "douyu" }
Fk:loadTranslationTable{
  ["pangji"] = "逄纪",
  --["#pangji"] = "",

  ["~pangji"] = "",
}

General:new(extension, "huangfusong", "qun", 4):addSkills { "yanjing", "fenyue" }
Fk:loadTranslationTable{
  ["huangfusong"] = "皇甫嵩",
  --["#huangfusong"] = "",

  ["~huangfusong"] = "",
}

General:new(extension, "ol__duanwei", "qun", 4):addSkills { "taohuai" }
Fk:loadTranslationTable{
  ["ol__duanwei"] = "段煨",
  --["#ol__duanwei"] = "",

  ["~ol__duanwei"] = "",
}

General:new(extension, "ol__sunhanhua", "wu", 3, 3, General.Female):addSkills { "ol__dangmo", "jihui", "xiaju" }
Fk:loadTranslationTable{
  ["ol__sunhanhua"] = "孙寒华",
  --["#ol__sunhanhua"] = "",

  ["~ol__sunhanhua"] = "",
}

General:new(extension, "ol__xielingyu", "wu", 3, 3, General.Female):addSkills { "ol__yuandi", "ol__xinyou" }
Fk:loadTranslationTable{
  ["ol__xielingyu"] = "谢灵毓",
  --["#ol__xielingyu"] = "",

  ["~ol__xielingyu"] = "",
}

return extension
