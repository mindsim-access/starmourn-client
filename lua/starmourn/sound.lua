local dir = require"pl.dir"
local path = require "pl.path"
local stringx = require "pl.stringx"

SOUND_PATH = path.abspath("worlds/starmourn/sounds/")
SOUND_EXT = ".ogg"

function PlayGameSound(soundname)
  local sound = FindGameSound(soundname)
  if sound then
    return Sound(sound)
  end -- if
end -- function

function FindGameSound(soundname)
  local sound
  local soundpath = SOUND_PATH .. "/" .. soundname
  if path.isdir(soundpath) then
    local sounds = dir.getfiles(soundpath)
    sound = sounds[math.random(#sounds)]
  end -- if
  if not stringx.endswith(soundname, SOUND_EXT) then
    soundname = soundname .. SOUND_EXT
  end -- if
  local soundpath = SOUND_PATH .. "/" .. soundname
  if path.isfile(soundpath) then
    local sound = soundpath
  end -- if
  return sound
end -- function
