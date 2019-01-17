require "json"
require 'tprint' -- useful in global namespace
require "math"
local dir = require"pl.dir"
local path = require "pl.path"
local seq = require 'pl.seq'
local stringx = require "pl.stringx"
local tablex = require "pl.tablex"

stringx.import()

SOUND_PATH = path.abspath("worlds/starmourn/sounds/")
SOUND_EXT = ".ogg"

Accelerator("alt+h", "$ TTSHealth()")
Accelerator("alt+l", "$ TTSLevel()")
Accelerator("alt+o", "$ TTSObjects()")
Accelerator("alt+p", "$ TTSPlayers()")
Accelerator("alt+m", "$ TTSMobs()")

room = {}
player = {}

function handle_communications(name, line, wc)
  local channel = wc[1]
  AddToHistory(channel, line)
  PlayGameSound('channels/' .. channel)
end

function handle_tells(name, line, wc)
  AddToHistory("Tells", line)
  PlayGameSound('channels/tell')
end

function handle_mindsim_messages(name, line, wc)
  AddToHistory("Mindsim", line)
  PlayGameSound('channels/mindsim')
end

function AddToHistory(source, message)
ExecuteNoStack("history_add " .. source .. "=" .. message)
end

function handle_GMCP(name, line, wc)
  local command = wc[1]
  local args = wc[2]
  local handler_func_name = "handle_" .. command:lower():gsub("%.", "_")
  local handler_func = _G[handler_func_name]
  if handler_func == nil then
    -- Note("No handler " .. handler_func_name .. " for " .. command .. " " .. args)
  else
    -- Note("Processing " .. command .. " with arguments " .. args)
    handler_func(json.decode(args))
  end -- if
end -- function

function handle_room_info(data)
  data.players = {}
  data.npcs = {}
  data.objects= {}
  tablex.copy(room, data)
end

function handle_char_vitals(data)
  local vitals = {}
  vitals.hp = data.hp
  vitals.max_hp = data.maxhp
  vitals.pt = data.pt
  vitals.max_pt = data.maxpt
  tablex.update(player, vitals)
end -- function

function handle_char_status (data)
  tablex.update(player, data)
end

function handle_ire_target_set(target)
  player.target = target
end -- function

function handle_char_items_list(data)
  mobs = {}
  objects = {}
  for index, item in ipairs(data.items) do
    if item.attrib == 'mx' then
      mobs[item.id] = item
    else
      objects[item.id] = item
    end -- if
  end -- for
  update = {
    mobs = mobs,
    players = players,
   objects = objects,
  }
  tablex.update(room, update)
end -- function

function ExecuteNoStack(cmd)
  local s = GetOption("enable_command_stack")
  SetOption("enable_command_stack", 0)
  Execute(cmd)
  SetOption("enable_command_stack", s)
end

function handle_mxp(variable, value)
end -- function

function PlayGameSound(soundname)
  local sound
  local soundpath = SOUND_PATH .. "/" .. soundname
  if path.isdir(soundpath) then
    local sounds = dir.getfiles(soundpath)
    sound = sounds[math.random(#sounds)]
  end -- if
  if not stringx.endswith(soundname, SOUND_EXT) then
    soundname = soundname .. ".ogg"
  end -- if
  local soundpath = SOUND_PATH .. "/" .. soundname
  if path.isfile(soundpath) then
    sound = soundpath
  end -- if
  if sound then
    return Sound(sound)
  end -- if
end -- function

function TTSHealth()
  Speak(player.hp or "unknown")
  end -- function

function TTSLevel()
  Speak(player.level or "unknown")
  end -- function

function TTSObjects()
  SpeakList(ItemNames(room.objects))
end -- function

function TTSMobs()
  SpeakList(ItemNames(room.mobs))
end -- function

function TTSPlayers()
  SpeakList(ItemNames(room.players))
end -- function

function ItemNames(tbl)
  if tbl == nil then
    tbl = {}
  end -- if
  local names = {}
  for id, item in pairs(tbl) do
    names[#names+1] = item.name
  end -- for
  return names
end -- function

function SpeakList(lst)
  if lst == nil then
    lst = {}
  end -- if
  Speak((', '):join(lst))
end -- function

function Speak(msg)
ExecuteNoStack("tts_interrupt " .. msg)
end -- function
