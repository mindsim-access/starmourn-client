
function SpeakList(lst)
  if lst == nil then
    lst = {}
  end -- if
  Speak((', '):join(lst))
end -- function

function Speak(msg)
ExecuteNoStack("tts_interrupt " .. msg)
end -- function
