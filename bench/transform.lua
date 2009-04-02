
local m = require "listlpeg"

local function rands(size)
  local digits = {}
  for i = 1, size do digits[i] = string.byte("a") + math.random(26) - 1 end
  return string.char(unpack(digits))
end

local s = {}

for i = 1, 5 do
   s[i] = {}
   for j = 1, 5 do
      s[i][j] = rands(5) 
   end 
end

local ps = {}

for i = 1, 5 do
   ps[i] = m.L(m.L(s[i][1]) * m.L(s[i][2]) * m.L(s[i][3]) * m.L(s[i][4]) * m.L(s[i][5]))
end

local p = ps[1] + ps[2] + ps[3] + ps[4] + ps[5]

local assert = assert

m.print(p)

local subject = {}

for i = 1, 5 do subject[i] = { s[i][1], s[i][2], s[i][3], s[i][4], s[i][5] } end

return function ()
	  for i = 1, 5 do
	     assert(p:match{subject[i]})
	  end 
       end
