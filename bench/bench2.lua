
local benchs = {
   { "calculator.lua", 1 },
   { "html.lua", 1000 },
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
      local fs = { loadfile(bench[1])() }
 
      for j, f in ipairs(fs) do
	 if not bench.times[j] then bench.times[j] = {} end
	 local t1 = os.clock()
	 for i = 1, bench[2] do
	    f(i)
	 end
	 local t2 = os.clock()
	 table.insert(bench.times[j], t2 - t1)
      end
   end
end

for _, bench in ipairs(benchs) do
   for i, times in ipairs(bench.times) do
      print(bench[1] .. " (" .. i .. ") " .. bench[2] .. " runs: " .. 
	    mean(times) .. " +- " .. sd(times))
   end
end
