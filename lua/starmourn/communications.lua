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
