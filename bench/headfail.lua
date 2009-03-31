
local m = require "listlpeg"

local s1 = "abcdefghijklmnopqrstuvwxyz"
local s2 = "zyxwvutsrqdonmlkjihgfedcba"

local p = m.L(s1) + m.L(s2)

m.print(p)

local assert = assert

return function ()
	 assert(p:match{ s1 } and p:match{ s2 })
       end
