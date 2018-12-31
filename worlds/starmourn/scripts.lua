require "json"

room = {}

player = {}


function handle_communications(name, line, wc)
  AddToHistory(wc[1], line)
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
    Note("No handler " .. handler_func_name .. " for " .. command .. " " .. args)
  else
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
end
