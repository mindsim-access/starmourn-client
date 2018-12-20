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

function ExecuteNoStack(cmd)
  local s = GetOption("enable_command_stack")
  SetOption("enable_command_stack", 0)
  Execute(cmd)
  SetOption("enable_command_stack", s)
end