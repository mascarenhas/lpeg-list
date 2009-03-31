
local script, times = ...

times = times or 1000000

local f = loadfile(script)()

local t1 = os.clock()
for i = 1, times do
  f(i)
end
local t2 = os.clock()

print(script .. " x " .. times .. ": " .. (t2-t1))
