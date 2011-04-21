
local m = require "listlpeg"

local function rands(size)
  local digits = {}
  for i = 1, size do digits[i] = string.byte("a") + math.random(26) - 1 end
  return string.char(unpack(digits))
end

local nchoices, natoms = ...

local assert = assert

local s = {}
for i = 1, nchoices do
  s[i] = {}
  for j = 1, natoms do
    s[i][j] = rands(5)
  end
end

local ps = {}
for i = 1, nchoices do
  ps[i] = m.L(s[i][1])
  for j = 2, natoms do
    ps[i] = ps[i] * m.L(s[i][j])
  end
  ps[i] = m.L(ps[i])
end
p = ps[1]
for i = 2, nchoices do
  p = p + ps[i]
end
m.print(p)

local subject = {}
for i = 1, nchoices do
  subject[i] = {}
  for j = 1, natoms do
    subject[i][j] = s[i][j]
  end
end

return function ()
         assert(p:match{subject[nchoices]})
--[[         for i = 1, nchoices do
           assert(p:match{subject[i]})
         end]]
       end
