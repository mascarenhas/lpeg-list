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

local add = function (x, y) return x + y end 
local sub = function (x, y) return x - y end
local mul = function (x, y) return x * y end
local div = function (x, y) return x / y end

local p = re.compile([[
			 exp <- { "add", <exp>, <exp> } -> add
				/ { "sub", <exp>, <exp> } -> sub
			        / { "mul", <exp>, <exp> } -> mul
			        / { "div", <exp>, <exp> }  -> div
			        / { "num", <.> }
    ]], { add = add, sub = sub, mul = mul, div = div })

local p2 = re.compile([[ exp <- { "add", <exp>, <exp> } /
				{ "sub", <exp>, <exp> } /
			        { "mul", <exp>, <exp> } /
			        { "div", <exp>, <exp> } /
			        { "num", . } ]])

local function p3(exp)
  if #exp == 3 and exp[1] == "add" then
     return add(p3(exp[2]), p3(exp[3]))
  elseif #exp == 3 and exp[1] == "sub" then 
     return sub(p3(exp[2]), p3(exp[3]))
  elseif #exp == 3 and exp[1] == "mul" then
     return mul(p3(exp[2]), p3(exp[3]))
  elseif #exp == 3 and exp[1] == "div" then
     return div(p3(exp[2]), p3(exp[3]))
  elseif #exp == 2 and exp[1] == "num" then
     return exp[2]
  else
     return nil
  end
end

local function p4(exp)
  if #exp == 3 and exp[1] == "add" then
     return p3(exp[2]) and p3(exp[3])
  elseif #exp == 3 and exp[1] == "sub" then 
     return p3(exp[2]) and p3(exp[3])
  elseif #exp == 3 and exp[1] == "mul" then
     return p3(exp[2]) and p3(exp[3])
  elseif #exp == 3 and exp[1] == "div" then
     return p3(exp[2]) and p3(exp[3])
  elseif #exp == 2 and exp[1] == "num" then
     return true
  else
     return false
  end
end

local exps = loadfile("exps.lua")()

local exps_vals = loadfile("exps_vals.lua")()

for _, exp in ipairs(exps_vals) do
  assert(math.floor(p:match{ exp.exp }) == exp.val)
  assert(math.floor(p3( exp.exp )) == exp.val)
end

local function f1()
   for i = 1, 1000 do
      assert(p:match{exps[i]})
   end
end

local function f2()
   for i = 1, 1000 do
      assert(p2:match{exps[i]})
   end
end

local function f3()
   for i = 1, 1000 do
      assert(p3(exps[i]))
   end
end

local function f4()
   for i = 1, 1000 do
      assert(p4(exps[i]))
   end
end

return f1, f2, f3, f4

