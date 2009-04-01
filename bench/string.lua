
local m = require "listlpeg"

local function rands(size)
  local digits = {}
  for i = 1, size do digits[i] = string.byte("a") + math.random(26) - 1 end
  return string.char(unpack(digits))
end

local subjects = { rands(20) }

local p = m.L(subjects[1])

for i = 2, 20 do 
  subjects[i] = rands(20) 
  p = p * m.L(subjects[i])
end

m.print(p)

local assert = assert

return function ()
	 assert(p:match(subjects))
       end
