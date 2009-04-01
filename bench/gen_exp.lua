require "versium.sync.serialize"

local function gen_exp(size)
  local kinds = { "add", "sub", "mul", "div" }
  if size == 1 then return { "num", math.random(10) } end
  local t = math.random(5)
  if t == 5 then
    return { "num", math.random(10) }
  else
    return { kinds[t], gen_exp(size - 1), gen_exp(size - 1) }
  end
end

exps = {}
for i = 1, 1000 do
  exps[i] = gen_exp(10)
end
print(serialize(exps))

