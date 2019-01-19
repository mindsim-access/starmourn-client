function SpeakList(lst, default)
  local msg
  if lst == {} then
    msg = default
  else
    msg = (', '):join(lst)
  end -- if
  Speak(msg)
end -- function

function Speak(msg)
ExecuteNoStack("tts_interrupt " .. msg)
end -- function
