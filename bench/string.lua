
local m = require "listlpeg"

local s = "abcdefghijklmnopqrstuvwxyz"

local p = m.L(s)

local assert = assert

return function ()
	 assert(p:match{ s })
       end

