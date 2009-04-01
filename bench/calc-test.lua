m = require "listlpeg"

local function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "{\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

local function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        tostring(tbl)
    end
end

local function select(n, t) return t[n] end

re = require "listre"

local p = re.compile([[
			 exp <- { ("add", <exp>, <exp>) -> add
				/ ("sub", <exp>, <exp>) -> sub
			        / ("mul", <exp>, <exp>) -> mul
			        / ("div", <exp>, <exp>)  -> div
			        / ("num", <.>) }
    ]], { add = function (x, y) return x + y end, 
          sub = function (x, y) return x - y end,
          mul = function (x, y) return x * y end,
          div = function (x, y) return x / y end, })

local p2 = re.compile([[
			  exp <- { "add", <exp>, <exp> } /
				 { "sub", <exp>, <exp> } /
			         { "mul", <exp>, <exp> } /
			         { "div", <exp>, <exp> } /
			         { "num", . }
    ]])

m.print(p2)

local exp_ops = { add = true, mul = true, div = true, sub = true }

local function p3(exp)
  if exp_ops[exp[1]] then
    return #exp == 3 and p3(exp[2]) and p3(exp[3])
  elseif exp[1] == "num" then
    return #exp == 2
  else
    return false
  end
end

local function p4(exp)
  if exp[1] == "add" or exp[1] == "sub" or 
     exp[1] == "mul" or exp[1] == "div" then
    return #exp == 3 and p4(exp[2]) and p4(exp[3])
  elseif exp[1] == "num" then
    return #exp == 2
  else
    return false
  end
end

local exps = loadfile("exps.lua")()

local exps_vals = loadfile("exps_vals.lua")()

for _, exp in ipairs(exps_vals) do
  assert(math.floor(p:match{ exp.exp }) == exp.val)
end

local t1 = os.clock()
for i = 1, 1000 do
  p:match{ exps[i] }
end
local t2 = os.clock()
print(t2 - t1)

local t1 = os.clock()
for i = 1, 1000 do
  p2:match{ exps[i] }
end
local t2 = os.clock()
print(t2 - t1)

local t1 = os.clock()
for i = 1, 1000 do
  p3(exps[i])
end
local t2 = os.clock()
print(t2 - t1)

local t1 = os.clock()
for i = 1, 1000 do
  p4(exps[i])
end
local t2 = os.clock()
print(t2 - t1)
