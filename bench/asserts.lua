require "versium.sync.serialize"

local function p4(exp)
  if exp[1] == "add" then
    return p4(exp[2]) + p4(exp[3])
  elseif exp[1] == "sub" then
    return p4(exp[2]) - p4(exp[3])
  elseif exp[1] == "mul" then
    return p4(exp[2]) * p4(exp[3])
  elseif exp[1] == "div" then
    return p4(exp[2]) / p4(exp[3])
  elseif exp[1] == "num" then
    return exp[2]
  else
    return false
  end
end

local exps = loadfile("exps.lua")()

local new_exps = {}

for i = 1, 1000 do
  if p4(exps[i]) < 10000000000 and p4(exps[i]) > -10000000000 then
    table.insert(new_exps, { exp = exps[i], val = math.floor(p4(exps[i])) })
  end
end

print(serialize(new_exps))
