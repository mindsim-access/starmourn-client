function handle_communications(name, line, wc)
ExecuteNoStack("history_add " .. wc[1] .. "=" .. line)
end

function ExecuteNoStack(cmd)
  local s = GetOption("enable_command_stack")
  SetOption("enable_command_stack", 0)
  Execute(cmd)
  SetOption("enable_command_stack", s)
end