require "json"
require "math"
local dir = require"pl.dir"
local path = require "pl.path"

room = {}
player = {}

function handle_communications(name, line, wc)
  local channel = wc[1]
  AddToHistory(channel, line)
  PlayGameSound(channel)
end

function handle_tells(name, line, wc)
  AddToHistory("Tells", line)
end

function handle_mindsim_messages(name, line, wc)
  AddToHistory("Mindsim", line)
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
    -- Note("Processed " .. command .. " with arguments " .. args)
    handler_func(json.decode(args))
  end -- if
end -- function

function handle_room_info(data)
  room = data
end

function handle_char_vitals(data)
  player.hp = data.hp
  player.max_hp = data.maxhp
end -- function

function handle_char_status (data)
  player.name = data.first_name
  player.race = data.race
  player.gender = data.gender
  player.marks = data.marks
  player.target = data.target
end

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
  local soundpath = "worlds/starmourn/sounds/" .. soundname
  if path.isdir(soundpath) then
    local sounds = dir.getfiles(soundpath)
    sound = sounds[math.random(#sounds)]
  elseif path.isfile(soundpath) then
    local sound = soundpath
  end -- if
  return Sound(sound)
end -- function

function handle_taser_shock(name, line, wc)
PlayGameSound("taser")
end -- function

function BuildArray(...)
  local arr = {}
  for v in ... do
    arr[#arr + 1] = v
  end
  return arr
end