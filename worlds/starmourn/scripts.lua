require "json"
require 'tprint' -- useful in global namespace
require "math"
require "speech"
require "starmourn"

local seq = require 'pl.seq'
local stringx = require "pl.stringx"
local tablex = require "pl.tablex"

stringx.import()


Accelerator("alt+h", "$ TTSHealth()")
Accelerator("alt+l", "$ TTSLevel()")
Accelerator("alt+x", "$ TTSxp()")
Accelerator("alt+o", "$ TTSObjects()")
Accelerator("alt+p", "$ TTSPlayers()")
Accelerator("alt+m", "$ TTSMobs()")


room = {
  mobs = {},
  objects = {},
  players = {},
}

player = {}


function handle_GMCP(name, line, wc)
  local command = wc[1]
  local args = wc[2]
  local handler_func_name = "handle_" .. command:lower():gsub("%.", "_")
  local handler_func = _G[handler_func_name]
  if handler_func == nil then
  --  Note("No handler " .. handler_func_name .. " for " .. command .. " " .. args)
  else
    Note("Processing " .. command .. " with arguments " .. args)
    handler_func(json.decode(args))
  end -- if
end -- function

function handle_room_info(data)
  tablex.update(room, data)
end

function handle_char_vitals(data)
  local vitals = {}
  vitals.hp = data.hp
  vitals.max_hp = data.maxhp
  vitals.pt = data.pt
  vitals.max_pt = data.maxpt
  vitals.combat = data.combat
  vitals.xp = data.xp
  tablex.update(player, vitals)
end -- function

function handle_room_players(data)
  local update = {}
  for index, player in pairs(data) do
    update[player.name] = player
  end -- for
  room.players = update
end --function

function handle_room_addplayer (data)
  room.players[data.name] = data
end -- function

function handle_room_removeplayer(data)
  room.players[data] = nil
end -- function
 
function handle_char_items_add (data)
  update = {}
  update[data.item.id] = data.item
  if data.location == 'room' then
    if IsMob(data.item) then
      tablex.update(room.mobs, update)
    else
      tablex.update(room.objects, update)
    end -- if
      end -- if
end -- function

function handle_char_items_remove (data)
  if data.location == 'room' then
    if IsMob(data.item) then
      room.mobs[data.item.id] = nil
    else
      room.objects[data.item.id] = nil
    end -- if
  end -- if
end -- function

function handle_char_status (data)
  tablex.update(player, data)
end -- function

function handle_ire_target_set(target)
  player.target = target
end -- function

function handle_char_items_list(data)
  mobs = {}
  objects = {}
  for index, item in ipairs(data.items) do
    if IsMob(item) then
      mobs[item.id] = item
    else
      objects[item.id] = item
    end -- if
  end -- for
  update = {
    mobs = mobs,
    objects = objects,
  }
  room.objects = {}
  room.mobs = {}
  tablex.update(room, update)
end -- function

function handle_comm_channel_text(data)
  if data.channel == 'say' then
    AddToHistory("Conversation", StripANSI(data.text))
  end -- if
end -- function

function IsMob(obj)
  return obj.attrib and obj.attrib:startswith('m')
end -- function

function ExecuteNoStack(cmd)
  local s = GetOption("enable_command_stack")
  SetOption("enable_command_stack", 0)
  Execute(cmd)
  SetOption("enable_command_stack", s)
end

function handle_mxp(variable, value)
end -- function


function TTSHealth()
  Speak(player.hp or "unknown")
  end -- function

function TTSLevel()
  Speak(player.level or "unknown")
  end -- function

function TTSxp()
  Speak(player.xp or "unknown")
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

