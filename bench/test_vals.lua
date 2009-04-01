exps = loadfile("exps_vals.lua")()

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

for _, exp in ipairs(exps) do
  print(_)
  assert(math.floor(p4(exp.exp)) == exp.val)
end
  
