
local m = require "listlpeg"

local function rands(size)
  local digits = {}
  for i = 1, size do digits[i] = string.byte("a") + math.random(26) - 1 end
  return string.char(unpack(digits))
end

local s = {}

for i = 1, 5 do s[i] = rands(5) end 

local p = m.L(m.L(s[1]) * m.L(s[2]) * m.L(s[3]) * m.L(s[4]) * m.L(s[5]))^0

local assert = assert

m.print(p)

local subject = {}

for i = 1, 100 do subject[i] = s end

return function ()
	  assert(p:match(subject)) 
       end
