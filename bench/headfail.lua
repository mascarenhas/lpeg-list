
local m = require "listlpeg"

local s1 = "abcdefghijklmnopqrstuvwxyz"
local s2 = "zyxwvutsrqponmlkjihgfedcba"

local p = m.L(s1) + m.L(s2)

local assert = assert

return function ()
	 assert(p:match{ s1 } and p:match{ s2 })
       end
