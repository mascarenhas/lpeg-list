
local m = require "listlpeg"

local s1 = "abcdefghijklmnopqrstuvwxyz"
local s2 = "zyxwvutsrqdonmlkjihgfedcba"
local s3 = s1 .. s2

local p = m.L(s1) + m.L(s2) + m.L(s3)

local assert = assert

return function ()
	 assert(p:match{ s1 } and p:match{ s2 } and p:match{ s3 })
       end
