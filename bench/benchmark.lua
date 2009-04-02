
local benchs = {
   { "string.lua", 150000 },
   { "headfail.lua", 15000 },
   { "partial.lua", 10000 },
   { "transform.lua", 40000 },
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

for _, bench in ipairs(benchs) do
   bench.times = {}
   for i = 1, 10 do
      local f = loadfile(bench[1])()
 
      local t1 = os.clock()
      for i = 1, bench[2] do
	 f(i)
      end
      local t2 = os.clock()
      bench.times[i] = t2 - t1
   end
end

for _, bench in ipairs(benchs) do
   print(bench[1] .. " " .. bench[2] .. " runs: " .. 
	 mean(bench.times) .. " +- " .. sd(bench.times))
end
