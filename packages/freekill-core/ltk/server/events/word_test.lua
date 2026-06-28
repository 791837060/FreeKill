-- SPDX-License-Identifier: GPL-3.0-or-later
-- 单词测试（移植自 FK @ 3a24652）

if not wordListVar then wordListVar = {} end

if not insertWordListBack1 then
  dofile "ltk/server/events/word_banks.lua"
end

local WordTest = {}

WordTest.lastSoundPlayTime = 0
WordTest.currentWordSound = "October"
-- QTimer 用 int 毫秒，约 24.8 天是安全上限；背单词时不烧条
WordTest.PLAY_PHASE_TIMEOUT = 2147483
WordTest.WORDS_PER_TURN = 2
WordTest.turnWordCount = {}

function WordTest.beginTurn(player)
  WordTest.turnWordCount[player.id] = 0
end

function WordTest.canShowWord(player)
  return (WordTest.turnWordCount[player.id] or 0) < WordTest.WORDS_PER_TURN
end

function WordTest.markWordShown(player)
  WordTest.turnWordCount[player.id] = (WordTest.turnWordCount[player.id] or 0) + 1
end

local input_front_back = ""
local ownerRoom = ""

local WORD_TEST_DIALOG = "Fk/Pages/LunarLTK/WordTestDialog.qml"

local function buildDialogComponent(payload)
  return {
    url = WORD_TEST_DIALOG,
    prop = { dialogJson = json.encode(payload) },
  }
end

local DEFAULT_FRONT = "vi./vt.写字，写 皇冠(编码)+日(拼音)+特(拼音) 戴着皇冠的日本特务在写字"
local DEFAULT_BACK = "write 戴着皇冠的日本特务在写字 w皇冠(编码)+ri日(拼音)+te特(拼音)"

local function isWordTagMeta(key)
  return key == "wordTagInit"
end

local function ensureWordPair(front, back)
  if front == nil or back == nil or front == "" or back == "" then
    return DEFAULT_FRONT, DEFAULT_BACK
  end
  return front, back
end

local function splitFirstComma(input)
  input = tostring(input or "")
  local pos = string.find(input, ",", 1, true)
  if not pos then
    return input, nil
  end
  return string.sub(input, 1, pos - 1), string.sub(input, pos + 1)
end

local function split(input, delimiter)
  input = tostring(input)
  delimiter = tostring(delimiter)
  if delimiter == "" then return false end
  local pos, arr = 0, {}
  for st, sp in function() return string.find(input, delimiter, pos, true) end do
    table.insert(arr, string.sub(input, pos, st - 1))
    pos = sp + 1
  end
  table.insert(arr, string.sub(input, pos))
  return arr
end

local function parseFrontBack(front_and_back)
  if front_and_back == nil or front_and_back == "" or front_and_back == "nil"
      or front_and_back == "undefined" then
    return nil, nil, nil
  end
  local parts = split(front_and_back, "_=front_xxxxxxxxxx_back=_")
  if parts[2] == nil then
    return nil, nil, nil
  end
  local word = split(parts[2], " ")[1]
  return parts[1], parts[2], word
end

local function shuffleTable(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

local function containsComma(str)
  return string.find(str, "_=front_xxxxxxxxxx_back=_") ~= nil
end

local function getWordTagRandomKeyValue(tbl)
  local front, back
  local count = 0
  for key, value in pairs(tbl) do
    if not isWordTagMeta(key) then
      count = count + 1
      if count == 1 then
        front = key
        back = value
      elseif math.random(1, count) == 1 then
        front = key
        back = value
      end
    end
  end
  return front, back
end

local function getRandomKeyValue(tbl)
  local front, back
  local count = 0
  for key, value in pairs(tbl) do
    count = count + 1
    if count == 1 then
      front = key
      back = value
    else
      if math.random(1, count) == 1 then
        front = key
        back = value
      end
    end
  end
  return front, back
end

function WordTest.playSoundIfAllowed(room, wordSound)
  if wordSound == nil then return end
  local currentTime = os.time()
  if currentTime - WordTest.lastSoundPlayTime < 10 then return end
  if math.random() <= 0.5 then
    room:broadcastPlaySoundWav("./audio/word/" .. wordSound .. "_zh")
  else
    room:broadcastPlaySound("./audio/word/" .. wordSound)
  end
  WordTest.lastSoundPlayTime = currentTime
end

function WordTest.showWord(player, room)
  if player.id == room.room:getOwner():getId() then
    ownerRoom = "true"
  else
    ownerRoom = "false"
  end

  local wordList = room.wordList or ""
  if string.find(wordList, "_free") ~= nil then
    return WordTest.currentWordSound
  end

  if not WordTest.canShowWord(player) then
    return WordTest.currentWordSound
  end

  local wordTagInit = room:getWordTag("wordTagInit")
  if wordTagInit ~= "true" and string.find(wordList, "_gao") ~= nil then
    insertWordListBack3(room)
  end
  wordTagInit = room:getWordTag("wordTagInit")
  if wordTagInit ~= "true" and string.find(wordList, "_chu") ~= nil then
    insertWordListBack2(room)
  end
  wordTagInit = room:getWordTag("wordTagInit")
  if wordTagInit ~= "true" then
    insertWordListBack1(room)
  end

  local front, back = DEFAULT_FRONT, DEFAULT_BACK
  local word = "abc"
  local requestJava = "true"
  local wordSound

  if wordListVar == nil or next(wordListVar) == nil then
    if false and containsComma(input_front_back) then
      front = split(input_front_back, "_=front_xxxxxxxxxx_back=_")[2]
      back = split(input_front_back, "_=front_xxxxxxxxxx_back=_")[3]
    else
      front, back = getWordTagRandomKeyValue(room:getWordTagObj())
    end
  else
    if false and containsComma(input_front_back) then
      front = split(input_front_back, "_=front_xxxxxxxxxx_back=_")[2]
      back = split(input_front_back, "_=front_xxxxxxxxxx_back=_")[3]
    else
      front, back = getRandomKeyValue(wordListVar)
    end
  end
  front, back = ensureWordPair(front, back)
  word = split(back, " ")[1]

  if string.find(wordList, "_free") == nil then
    if player.id < 0 then
      return WordTest.currentWordSound
    end

    local screenName = player._splayer:getScreenName()
    local str_front_and_back = front .. "_=front_xxxxxxxxxx_back=_" .. back
    local payload = {
      front = front,
      back = back,
      requestJava = requestJava,
      str_front_and_back = str_front_and_back,
      ip = wordList,
      player = screenName,
      aa = "false",
      uiSource = "core",
    }

    local req = Request:new(player, "CustomDialog")
    req.focus_text = "simayi"
    req.receive_decode = false
    req.timeout = WordTest.PLAY_PHASE_TIMEOUT
    req:setData(player, {
      path = WORD_TEST_DIALOG,
      data = payload,
      component = buildDialogComponent(payload),
    })
    local input_front_back_result = req:getResult(player)
    WordTest.markWordShown(player)
    input_front_back = input_front_back_result
    local result, front_and_back = splitFirstComma(input_front_back_result)
    if front_and_back then
      local parsedFront, parsedBack, parsedWord = parseFrontBack(front_and_back)
      if parsedFront and parsedBack then
        wordSound = parsedWord
      end
    end
  end

  if wordSound then
    WordTest.currentWordSound = wordSound
  end
  return WordTest.currentWordSound
end

return WordTest
