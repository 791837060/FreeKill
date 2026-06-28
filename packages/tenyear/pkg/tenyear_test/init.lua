local extension = Package:new("tenyear_test")
extension.extensionName = "tenyear"

extension:loadSkillSkelsByPath("./packages/tenyear/pkg/tenyear_test/skills")

Fk:loadTranslationTable{
  ["tenyear_test"] = "十周年-测试服",
}

General:new(extension, "ty_sp__puyuan", "shu", 4):addSkills { "biancai", "cuiren", "shenfeng" }
Fk:loadTranslationTable{
  ["ty_sp__puyuan"] = "蒲元",
  --["#ty_sp__puyuan"] = "",

  --["~ty_sp__puyuan"] = "",
}

General:new(extension, "luwenyi", "wu", 3, 3, General.Female):addSkills { "caiyun", "qieyan" }
Fk:loadTranslationTable{
  ["luwenyi"] = "陆文漪",
  ["#luwenyi"] = "卷中避世",

  --["~luwenyi"] = "",
}

General:new(extension, "ty__huanshujun", "wei", 3, 3, General.Female):addSkills { "lianyou", "cili" }
Fk:loadTranslationTable{
  ["ty__huanshujun"] = "环怀瑾",
  ["#ty__huanshujun"] = "慧心育麟",

  --["~ty__huanshujun"] = "",
}

General:new(extension, "fugan", "qun", 3):addSkills { "qiaojian", "xicha" }
Fk:loadTranslationTable{
  ["fugan"] = "傅干",
  ["#fugan"] = "察策明谏",

  --["~fugan"] = "",
}

General:new(extension, "cuizhi", "shu", 3, 3, General.Female):addSkills { "ranlv", "juexun" }
Fk:loadTranslationTable{
  ["cuizhi"] = "崔芷",
  ["#cuizhi"] = "烈烛烬明",

  --["~cuizhi"] = "",
}

return extension
