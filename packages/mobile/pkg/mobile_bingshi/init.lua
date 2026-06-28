local extension = Package:new("mobile_bingshi")
extension.extensionName = "mobile"

extension:loadSkillSkelsByPath("./packages/mobile/pkg/mobile_bingshi/skills")

Fk:loadTranslationTable{
  ["mobile_bingshi"] = "手杀-兵势篇",
  ["m_shi"] = "势",
  ["#ChengShi"] = "乘势是一种特殊的附加效果，在多分支效果中，如果满足了每个分支的触发条件，则触发此效果。",
}

--奇
General:new(extension, "m_shi__dengai", "wei", 4):addSkills { "m_shi__tuntian", "m_shi__zaoxian", "m_shi__jixi" }
Fk:loadTranslationTable{
  ["m_shi__dengai"] = "势邓艾",
  ["#m_shi__dengai"] = "勇气陵云",
  ["illustrator:m_shi__dengai"] = "",

  ["~m_shi__dengai"] = "忠心天日可表，奈何为乱贼所蔽。",
}

General:new(extension, "m_shi__yuji", "qun", 3):addSkills { "fujiy", "daozhuan" }
Fk:loadTranslationTable{
  ["m_shi__yuji"] = "势于吉",
  ["#m_shi__yuji"] = "夙仙望道",
  ["illustrator:m_shi__yuji"] = "铁杵",

  ["~m_shi__yuji"] = "子为愚者，尚迷不信道，堕卑贱苦岂不哀哉？",
  ["!m_shi__yuji"] = "夫寿命，天之重宝也，所以私有德，不可伪致。",
}

General:new(extension, "mobile__lougui", "wei", 3):addSkills { "guansha", "jiyul" }
Fk:loadTranslationTable{
  ["mobile__lougui"] = "娄圭",
  ["#mobile__lougui"] = "一日之寒",
  ["illustrator:mobile__lougui"] = "铁杵",

  ["~mobile__lougui"] = "丞相留步，老夫告辞。",
}

General:new(extension, "sunshaow", "wu", 4):addSkills { "ganjue", "zhujis" }
Fk:loadTranslationTable{
  ["sunshaow"] = "孙韶",
  ["#sunshaow"] = "明敌御疆",
  ["illustrator:sunshaow"] = "铁杵",

  ["~sunshaow"] = "至尊恩遇，臣恐不可报还。",
}

General:new(extension, "m_shi__xiahoushang", "wei", 4):addSkills { "tanfeng" }
Fk:loadTranslationTable{
  ["m_shi__xiahoushang"] = "势夏侯尚",
  ["#m_shi__xiahoushang"] = "魏胤前驱",
  ["illustrator:m_shi__xiahoushang"] = "云涯",

  ["~m_shi__xiahoushang"] = "陛下垂怜至此，臣纵死无憾……",
}

General:new(extension, "mobile__yanghong", "qun", 3):addSkills { "mobile__jianji", "mobile__yuanmo" }
Fk:loadTranslationTable{
  ["mobile__yanghong"] = "杨弘",
  ["#mobile__yanghong"] = "柔迩驭远",
  ["illustrator:mobile__yanghong"] = "铁杵",

  ["~mobile__yanghong"] = "今日固死，死有何惧。",
}

--正
General:new(extension, "m_shi__taishici", "wu", 4):addSkills { "mobile__hanzhan", "zhanlie", "mobile__zhenfeng" }
Fk:loadTranslationTable{
  ["m_shi__taishici"] = "势太史慈",
  ["#m_shi__taishici"] = "志踏天阶",
  ["illustrator:m_shi__taishici"] = "铁杵",

  ["~m_shi__taishici"] = "身证大义，魂念江东……",
  ["!m_shi__taishici"] = "幸遇伯符，吾之壮志成矣！",
}

General:new(extension, "m_shi__chendao", "shu", 4):addSkills { "mobile__wangliec", "hongyic" }
Fk:loadTranslationTable{
  ["m_shi__chendao"] = "势陈到",
  ["#m_shi__chendao"] = "白毦督",
  ["illustrator:m_shi__chendao"] = "铁杵",

  ["~m_shi__chendao"] = "先帝功业，终止于此乎？",
}

General:new(extension, "m_shi__tianfeng", "qun", 3):addSkills { "ganggeng", "m_shi__sijian" }
Fk:loadTranslationTable{
  ["m_shi__tianfeng"] = "势田丰",
  ["#m_shi__tianfeng"] = "河北瑰杰",
  ["illustrator:m_shi__tianfeng"] = "凝聚永恒",

  ["~m_shi__tianfeng"] = "用人不疑，疑人不用，主公岂不知此理？",
}

General:new(extension, "m_shi__guoyuan", "wei", 3):addSkills { "qingdao", "xiugeng", "chenshe" }
Fk:loadTranslationTable{
  ["m_shi__guoyuan"] = "势国渊",
  ["#m_shi__guoyuan"] = "清介有守",
  ["illustrator:m_shi__guoyuan"] = "铁杵",

  ["~m_shi__guoyuan"] = "吾一生清俭，死亦当薄葬。",
  ["!m_shi__guoyuan"] = "国无粮草之患，则已胜敌半数矣。",
}

General:new(extension, "m_shi__wangchang", "wei", 3):addSkills { "kaiji", "shepan" }
Fk:loadTranslationTable{
  ["m_shi__wangchang"] = "势王昶",
  ["#m_shi__wangchang"] = "识度良臣",
  ["illustrator:m_shi__wangchang"] = "鬼画府",

  ["~m_shi__wangchang"] = "朝华之草，夕而零落……",
}

--势
local mShiWeiyan = General:new(extension, "m_shi__weiyan", "shu", 4)
mShiWeiyan:addSkills { "zhuangshi", "yinzhan", "zhongao" }
mShiWeiyan:addRelatedSkills { "m_shi__kuanggu", "kunfen" }
Fk:loadTranslationTable{
  ["m_shi__weiyan"] = "势魏延",
  ["#m_shi__weiyan"] = "矜忠跨万山",
  ["illustrator:m_shi__weiyan"] = "凝聚永恒",

  ["$kunfen_m_shi__weiyan1"] = "身承主公深信，岂可为小挫所扰。",
  ["$kunfen_m_shi__weiyan2"] = "前路既艰，更须倍道而行！",

  ["~m_shi__weiyan"] = "志为大汉献身，纵死又有何恨？",
  ["!m_shi__weiyan"] = "延一腔赤血，终不负主公之恩。",
}

local mShiWeiyan2 = General:new(extension, "m_shi2__weiyan", "shu", 4)
mShiWeiyan2:addSkills { "zhuangshi", "yinzhan", "zhongao" }
mShiWeiyan2:addRelatedSkills { "m_shi__kuanggu" }
mShiWeiyan2.total_hidden = true
Fk:loadTranslationTable{
  ["m_shi2__weiyan"] = "势魏延",
  ["#m_shi2__weiyan"] = "矜忠跨万山",
  ["illustrator:m_shi2__weiyan"] = "凝聚永恒",

  ["m_shi2"] = "势",

  ["$zhuangshi_m_shi2__weiyan1"] = "丞相无需多虑，我定能轻身立功。",
  ["$zhuangshi_m_shi2__weiyan2"] = "夏侯楙怯而无谋，有何计议之需？",

  ["$yinzhan_m_shi2__weiyan1"] = "既遇我魏延，休再妄想生还。",
  ["$yinzhan_m_shi2__weiyan2"] = "敢阻我锋芒，自是要丢盔弃甲。",
  ["$yinzhan_m_shi2__weiyan3"] = "强敌我斩，坚甲我摧！",

  ["~m_shi2__weiyan"] = "战死沙场固为快事，且待来生看大汉兴复……",
  ["!m_shi2__weiyan"] = "陛下！丞相！奇谋功毕，主公之望已是垂成！",
}

local mShiWeiyan3 = General:new(extension, "m_shi3__weiyan", "shu", 4)
mShiWeiyan3:addSkills { "zhuangshi", "yinzhan", "zhongao" }
mShiWeiyan3:addRelatedSkills { "m_shi__kuanggu", "kunfen" }
mShiWeiyan3.total_hidden = true
Fk:loadTranslationTable{
  ["m_shi3__weiyan"] = "势魏延",
  ["#m_shi3__weiyan"] = "矜忠跨万山",
  ["illustrator:m_shi3__weiyan"] = "腥鱼仔",

  ["m_shi3"] = "势",

  ["$m_shi__kuanggu_m_shi3__weiyan1"] = "趁此番小胜，再图一雪前耻。",
  ["$m_shi__kuanggu_m_shi3__weiyan2"] = "我自当率军击贼，岂可为断后之将！",

  ["$yinzhan_m_shi3__weiyan1"] = "宁战死沙场，绝不弃甲而降！",
  ["$yinzhan_m_shi3__weiyan2"] = "纵士少兵疲，亦可杀出重围！",
  ["$yinzhan_m_shi3__weiyan3"] = "战事何计兵将多寡？但看心怀之气！",

  ["$kunfen_m_shi3__weiyan1"] = "身承主公深信，岂可为小挫所扰。",
  ["$kunfen_m_shi3__weiyan2"] = "前路既艰，更须倍道而行！",

  ["~m_shi3__weiyan"] = "无怨小人构陷，只恨主公雄志未成……",
  ["!m_shi3__weiyan"] = "主公、丞相虽殁，魏延尚在，又岂容魏贼猖獗。",
}

General:new(extension, "m_shi__dongzhao", "wei", 3):addSkills { "miaolue", "yingjia" }
Fk:loadTranslationTable{
  ["m_shi__dongzhao"] = "势董昭",
  ["#m_shi__dongzhao"] = "陈筹定势",

  ["~m_shi__dongzhao"] = "为曹公助书方略，实昭之幸也……",
}

General:new(extension, "pangxi", "shu", 3):addSkills { "xuye", "mobile__kuangxiang" }
Fk:loadTranslationTable{
  ["pangxi"] = "庞羲",
  ["#pangxi"] = "璧玉佐君",
  ["illustrator:pangxi"] = "铁杵",

  ["~pangxi"] = "吾救君诸子，广有匡襄，州牧安可疑我？",
}

General:new(extension, "m_shi__huangzu", "qun", 4):addSkills { "chizhang", "duanyang" }
Fk:loadTranslationTable{
  ["m_shi__huangzu"] = "势黄祖",
  ["#m_shi__huangzu"] = "守殁枭寒",
  ["illustrator:m_shi__huangzu"] = "铁杵",

  ["~m_shi__huangzu"] = "人骂汝父作锻锡公，奈何不杀？",
}

General:new(extension, "m_shi__zhangyan", "qun", 4):addSkills { "feijing", "xiaoge" }
Fk:loadTranslationTable{
  ["m_shi__zhangyan"] = "势张燕",
  ["#m_shi__zhangyan"] = "轻勇骇势",
  ["illustrator:m_shi__zhangyan"] = "zoo",

  ["~m_shi__zhangyan"] = "与其四向奔走，不如归降曹公。",
}

General:new(extension, "m_shi__chenzhis", "shu", 3):addSkills { "quanchong", "renxing" }
Fk:loadTranslationTable{
  ["m_shi__chenzhis"] = "势陈祗",
  ["#m_shi__chenzhis"] = "承指接竖",
  ["illustrator:m_shi__chenzhis"] = "凝聚永恒",

  ["~m_shi__chenzhis"] = "微臣寸功未建，有辱圣恩啊。",
}

General:new(extension, "m_shi__zhonghui", "wei", 4):addSkills { "sizi", "xiezhi", "yunan", "kechang" }
Fk:loadTranslationTable{
  ["m_shi__zhonghui"] = "势钟会",
  ["#m_shi__zhonghui"] = "荡蜚缴志",
  --["illustrator:m_shi__zhonghui"] = "",

  ["~m_shi__zhonghui"] = "此谋虽败，亦远胜屈膝他人。",
}

General:new(extension, "m_shi__sunjun", "wu", 3):addSkills { "xiongtus", "m_shi__xianshuai" }
Fk:loadTranslationTable{
  ["m_shi__sunjun"] = "势孙峻",
  ["#m_shi__sunjun"] = "横逆自固",

  ["~m_shi__sunjun"] = "啊啊，诸葛恪！汝生时吾尚且不惧，更况死乎？",
}

General:new(extension, "m_shi__sunchen", "wu", 4):addSkills { "nigu", "lulian" }
Fk:loadTranslationTable{
  ["m_shi__sunchen"] = "势孙綝",
  ["#m_shi__sunchen"] = "蝮影权倾",
  --["illustrator:m_shi__sunchen"] = "",

  ["!m_shi__sunchen"] = "孙氏江山，非我何以得安？哈哈哈哈哈哈！",
  ["~m_shi__sunchen"] = "臣无功劳亦有苦劳，望陛下饶命、饶命啊！",
}

--节
General:new(extension, "m_shi__xinxianying", "wei", 3, 3, General.Female):addSkills { "jiejie", "qingshix" }
Fk:loadTranslationTable{
  ["m_shi__xinxianying"] = "势辛宪英",
  ["#m_shi__xinxianying"] = "明鉴致节",
  ["illustrator:m_shi__xinxianying"] = "凝聚永恒",

  ["~m_shi__xinxianying"] = "汝若依言行之，必可全身而退。",
  ["!m_shi__xinxianying"] = "女子之智识，亦有男子不能及者。",
}

General:new(extension, "m_shi__luyusheng", "wu", 3, 3, General.Female):addSkills { "mobile__runwei", "shuanghuai" }
Fk:loadTranslationTable{
  ["m_shi__luyusheng"] = "势陆郁生",
  ["#m_shi__luyusheng"] = "义姑",
  ["illustrator:m_shi__luyusheng"] = "石蝉",

  ["!m_shi__luyusheng"] = "女子虽柔，亦可为刚。",
  ["~m_shi__luyusheng"] = "有辱家族之荣，亦负父亲之望……",
}

General:new(extension, "m_shi__lusu", "wu", 3):addSkills { "m_shi__haoshi", "m_shi__dimeng" }
Fk:loadTranslationTable{
  ["m_shi__lusu"] = "势鲁肃",
  ["#m_shi__lusu"] = "廓开大计",
  ["illustrator:m_shi__lusu"] = "铁杵",

  ["~m_shi__lusu"] = "但恐时移势易，联盟不再啊。",
}

local huanjie = General:new(extension, "m_shi__huanjie", "wei", 4)
huanjie:addSkills { "gongmou", "zhengshuo" }
huanjie:addRelatedSkills { "qice", "kanpo" }
Fk:loadTranslationTable{
  ["m_shi__huanjie"] = "势桓阶",
  ["#m_shi__huanjie"] = "才周托命",
  ["illustrator:m_shi__huanjie"] = "凝聚永恒",

  ["$qice_m_shi__huanjie1"] = "无有奇策，何以解之？",
  ["$qice_m_shi__huanjie2"] = "为今之计，唯效图纬故事。",
  ["!m_shi__huanjie"] = "殿下身承天命，无所与让也。",
  ["~m_shi__huanjie"] = "陛下厚遇，臣唯结草相报。",
}

General:new(extension, "m_shi__chenjiao", "wei", 3):addSkills { "m_shi__qingyan", "m_shi__ceduan" }
Fk:loadTranslationTable{
  ["m_shi__chenjiao"] = "势陈矫",
  --["#m_shi__chenjiao"] = "",

  ["~m_shi__chenjiao"] = "纵无申胥之效，敢忘弘演之义乎？",
}

General:new(extension, "m_shi__zanghong", "qun", 4):addSkills { "liezhiz", "juguz" }
Fk:loadTranslationTable{
  ["m_shi__zanghong"] = "势臧洪",
  --["#m_shi__zanghong"] = "",
  --["illustrator:m_shi__zanghong"] = "",

  ["!m_shi__zanghong"] = "势有盛衰，人有顺逆，天道常予忠义之辈也。",
  ["~m_shi__zanghong"] = "惜洪力劣，不能推刃为天下报仇，何谓服乎？",
}

General:new(extension, "m_shi__chengpu", "wu", 4):addSkills { "duzuo", "bihan" }
Fk:loadTranslationTable{
  ["m_shi__chengpu"] = "势程普",
  --["#m_shi__chengpu"] = "",
  --["illustrator:m_shi__chengpu"] = "",

  ["~m_shi__chengpu"] = "",
}

return extension
