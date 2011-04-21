
local benchs = {
--   { "string.lua", 150000 },
--   { "headfail.lua", 15000 },
--   { "partial.lua", 10000 },
--[[   { "transform.lua", 1, 40000 },
   { "transform.lua", 2, 40000 },
   { "transform.lua", 3, 40000 },
   { "transform.lua", 4, 40000 },
   { "transform.lua", 5, 40000 },
   { "transform.lua", 6, 40000 },
   { "transform.lua", 7, 40000 },
   { "transform.lua", 8, 40000 },
   { "transform.lua", 9, 40000 },]]
   { "transform.lua", 10, 1, 40000 },
}

local function mean(t)
   local sum = 0
   for i = 1, #t do sum = sum + t[i] end
   return sum/#t
end

local function sd(t)
   local rms = 0
   for i = 1, #t do
      rms = rms + (t[i]-mean(t))^2
   end
   return math.sqrt(rms/#t)
end

for i = 1, 10 do
  for j = 1, 10 do
    local times = {}
    for k = 1, 10 do
      local f = loadfile("transform.lua")(i, j)
      local t1 = os.clock()
      for i = 1, 10000 do
        f()
      end
      local t2 = os.clock()
      times[k] = t2 - t1
    end
    io.write(mean(times) .. ",")
  end
  io.write("\n")
end

--[[
for _, bench in ipairs(benchs) do
   bench.times = {}
   for i = 1, 10 do
      local f = loadfile(bench[1])(bench[2], bench[3])

      local t1 = os.clock()
      for i = 1, bench[4] do
        f()
      end
      local t2 = os.clock()
      bench.times[i] = t2 - t1
   end
end

for _, bench in ipairs(benchs) do
  print(bench[1] .. "(" .. bench[2]..") " .. bench[4] .. " runs: " ..
         mean(bench.times) .. " +- " .. sd(bench.times))
end
]]
