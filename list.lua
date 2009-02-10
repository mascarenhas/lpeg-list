m = require "lpeg"

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

p = m.L("one") * m.L("two") * m.L(m.L"foo" * m.L"bar") * m.L"three"

assert(p:match{ "one", "two", { "foo", "bar" }, "three" })

print("+")

p = m.L"one" * m.L"two" * (m.L(m.L"foo" * m.L"bar") +
			     m.L(m.L"baz" * m.L"boo")) * m.L"three"

assert(p:match{ "one", "two", { "foo", "bar" }, "three" })
assert(p:match{ "one", "two", { "baz", "boo" }, "three" })
assert(not p:match{ "one", "two", { "baz", "bar" }, "three" })
assert(not p:match{ "one", "tw", { "foo", "bar" }, "three" })
assert(not p:match{ "one", "two", { "baz", "boo" } })
assert(not p:match{ "one", "two", { "baz", "boo" }, "thr" })

print("+")

p = m.L"one" * (m.L"two")^1 * m.L"three"

assert(p:match{ "one", "two", "three" })
assert(not p:match{ "one", "three" })
assert(p:match{ "one", "two", "two", "three" })
assert(p:match{ "one", "two", "two", "two", "three" })

print("+")

p = m.L"one" * (m.L"two")^1 * m.L("thr" * m.P("e")^1)

assert(p:match{ "one", "two", "three" })
assert(not p:match{ "one", "three" })
assert(p:match{ "one", "two", "two", "three" })
assert(p:match{ "one", "two", "two", "two", "three" })
assert(p:match{ "one", "two", "threeeee" })
assert(not p:match{ "one", "two", "thr" })

print("+")

p = m.L"one" * m.C(m.L"two") * (m.L(m.L"foo" * m.L"bar") +
			     m.L(m.L"baz" * m.L"boo"))^0 * m.L"three"

assert(p:match{ "one", "two", "three" } == "two")
assert(p:match{ "one", "two", { "foo", "bar" }, "three" })
assert(p:match{ "one", "two", { "baz", "boo" }, "three" })
assert(not p:match{ "one", "two", { "baz", "bar" }, "three" })
assert(p:match{ "one", "two", { "foo", "bar" }, { "baz", "boo" }, "three" })

print("+")

p = m.L"one" * m.C(m.L"two" * (m.L(m.L"foo" * m.L"bar") +
				       m.L(m.L"baz" * m.L"boo"))^0)
      * m.L"three"

assert(p:match{ "one", "two", "three" } == "two")
assert(#p:match{ "one", "two", { "foo", "bar" }, { "baz", "boo" },
		   "three" } == 3)
assert(p:match{ "one", "two", { "foo", "bar" }, { "baz", "boo" },
		"three" }[3][1] == "baz")

print("+")

p = m.L"one" * m.C(m.L"two" * (m.L(m.L("foo" * m.P("bar")^0) * 
					       m.L"bar") +
				       m.L(m.L"baz" * m.L"boo"))^0)
      * m.L"three"

assert(p:match{ "one", "two", "three" } == "two")
assert(#p:match{ "one", "two", { "foo", "bar" }, { "baz", "boo" },
		   "three" } == 3)
local t = p:match{ "one", "two", { "foobarbarbar", "bar" }, { "baz", "boo" },
		"three" }
assert(t[2][1] == "foobarbarbar")
assert(#p:match{ "one", "two", { "foobarbar", "bar" }, { "baz", "boo" },
		   "three" } == 3)

print("+")


re = require "listre"

p = re.compile[[ { "one", <"two">, "three" } ]]

assert(p:match{ { "one" , "two" ,"three" } } == "two")

print("+")

p = re.compile[[
      { "one", < "two", ({ {'foo''bar'*}, "bar" } / { "baz", "boo" })* > ,
     "three" }
]]


assert(p:match{{ "one", "two", "three" }} == "two")
assert(#p:match{{ "one", "two", { "foo", "bar" }, { "baz", "boo" }, "three" }} == 3)
local t = p:match{{ "one", "two", { "foobarbarbar", "bar" }, { "baz", "boo" },
		   "three" }}
assert(t[2][1] == "foobarbarbar")
assert(#p:match{{ "one", "two", { "foobarbar", "bar" }, { "baz", "boo" },
		  "three" }} == 3)

print("+")

p = re.compile([[ { "add", <.>, <.> } -> add ]], { add = function (x, y)
								return x+y
							     end })

assert(p:match{{ "add", 2, 3 }})
assert(p:match{{ "add", 72, 3 }} == 75)
assert(p:match{{ "add", 72.5, 3 }} == 75.5)
assert(not p:match{{ "sub", 72, 3 }})
assert(not p:match{{ "add", 3 }})

print("+")

p = re.compile[[ { "foo", < "bar", (!"baz" .)*, "baz" >, "boo" } ]]

assert(select(4, p:match{{ "foo", "bar", "one", "two", "three", "baz", "boo" }}) == "three")
assert(#p:match{{ "foo", "bar", "one", "two", "three", "baz", "boo" }} == 5)
assert(select(5, p:match{{ "foo", "bar", "one", "two", "three", "baz", "boo" }}) == "baz")
assert(select(2, p:match{{ "foo", "bar", "baz", "boo" }}) == "baz")
assert(#p:match{{ "foo", "bar", "baz", "boo" }} == 2)

print("+")

p = re.compile[[ { "foo", "bar", < (!"baz" .)* >, "baz" , "boo" } ]]

assert(#p:match{{ "foo", "bar", "one", "two", "three", "baz", "boo" }} == 3)
assert(select(3, p:match{{ "foo", "bar", "one", "two", "three", "baz", "boo" }}) == "three")
assert(#p:match{{ "foo", "bar", "baz", "boo" }} == 0)

print("+")

p = re.compile([[
	       exp <- { "add", <exp>, <exp> } -> add
                    / { "sub", <exp>, <exp> } -> sub
		    / { "mul", <exp>, <exp> } -> mul
		    / { "div", <exp>, <exp> } -> div
		    / <.>
    ]], { add = function (x, y) return x + y end, 
          sub = function (x, y) return x - y end,
          mul = function (x, y) return x * y end,
          div = function (x, y) return x / y end, })

assert(p:match{{ "add", { "div", 8, 2 }, 3 }} == 7)
assert(p:match{{ "sub", { "div", 8, { "add", 2, 2 } }, 3 }} == -1)

print("+")

p = re.compile([[ exp <- { . -> ops, <exp>, <exp> } -> eval / { "num", <.> } ]], 
	       { ops = { add = function (x, y) return x + y end, 
                         sub = function (x, y) return x - y end,
                         mul = function (x, y) return x * y end,
                         div = function (x, y) return x / y end, },
                 eval = function (op, x, y) return op(x, y) end })

assert(p:match{{ "add", { "div", { "num", 8 }, { "num", 2 } }, { "num", 3 } }} == 7)
assert(p:match{{ "sub", { "div", { "num", 8 }, { "add", { "num", 2 }, { "num", 2 } } }, 
		{ "num", 3  } }} == -1)

print("+")

local S = m.S(" \n\t")^0

parser = re.compile([[
  exp <- (<mul>:x <aop>:op <exp>:y) -> { op, x, y } / <mul>
  mul <- (<prim>:x <mop>:op <mul>:y) -> { op, x, y } / <prim>
  prim <- ( `( <exp> `) ) / <num>:n -> { 'num', n }
  aop <- (`+ -> 'add') / (`- -> 'sub')
  mop <- (`* -> 'mul') / (`/ -> 'div')
]], { num = S * (m.C(m.P"-"^-1 * m.R("09")^1) / tonumber) * S,
      id = function (x) return x end })

assert(p:match{parser:match("8/2+3")} == 7)
assert(p:match{parser:match("8 / (2 + 2) - 3")} == -1)

print("+")

tinyhtmlp = re.compile([[
  html <- (<tag> / <text>)* -> {}
  name <- <[0-9a-zA-Z_-]+>
  tag <- (`< <name>:n %s (<attribute>*->{}):attrs `> 
    <html>:c %s '</' %s =n %s '>') -> {n, attrs, c}
  text <- <(!'<' .)+>
  attribute <- (%s <name>:k `= <quotedString>:v %s) -> {k, v}
  quotedString <- ('"' / '\''):q <(!=q .)*> =q
]], { s = S })

tree = tinyhtmlp:match([[
 <html>
 <title>Yes</title>
 <body>
 <h1>Man, HTML is
 <i>great</i>.</h1><p>How could you even <b>think</b> 
 otherwise?</p><img src='HIPPO.JPG' width='20'></img><a 
 href='http://twistedmatrix.com'>A Good Website</a>
 </body>
 </html>
]])

assert(tree)

print("+")

tinyhtmld = re.compile([[
  html <- { <tag>* } -> {} -> concat
  tag <- { <.>, . -> formatattrs, <html> } -> ptag / <.>
]], { concat = table.concat, 
      ptag = function(n, attrs, c)
		return  string.format("<%s %s>%s</%s>", n, 
				      attrs, c, n)
	     end,
      formatattrs = function(attrs) 
		       local t = {}
		       for i = 1, #attrs do
			  t[i] = string.format("%s = '%s'", attrs[i][1], attrs[i][2])
		       end
		       return table.concat(t, " ")
		    end})

dump = [[<html ><title >Yes</title><body ><h1 >Man, HTML is
 <i >great</i>.</h1><p >How could you even <b >think</b> 
 otherwise?</p><img src = 'HIPPO.JPG' width = '20'></img><a href = 'http://twistedmatrix.com'>A Good Website</a>
 </body>
 </html>
]]

assert(tinyhtmld:match{tree} == dump)

print("+")

local function flatten(t)
   local o = {}
   for i = 1, #t do
      if type(t[i]) == "table" then
	 local f = flatten(t[i])
	 for j = 1, #f do table.insert(o, f[j]) end
      else
	 table.insert(o, t[i])
      end
   end
   return o
end

linkextract = re.compile([[
  html <- <contents> -> {}
  contents <- { <tag>* }
  tag <- { "a", <href>, <contents> }
         / { "img", <src>, <contents> }
         / { ., ., <contents> } 
         / .
  href <- { { (!"href" .), . }*,
	    { "href", <.> },
            { (!"href" .), . }* }
  src <- { { (!"src" .), . }*,
	   { "src", (<.>) },
           { (!"src" .), . }* }
]])

assert(#linkextract:match{tree} == 2)
assert(linkextract:match{tree}[1] == "HIPPO.JPG")
assert(linkextract:match{tree}[2] == "http://twistedmatrix.com")

print("+")

boringfier = re.compile([[
  html <- <contents> -> {}
  contents <- { <tag>* }
  tag <-  { "b", ., <contents> }
          / { "i", ., <contents> }
          / { .:n, .:a, <html>:c } -> {n, a, c} 
          / <.>
 ]])

boringfied = [[<html ><title >Yes</title><body ><h1 >Man, HTML is
 great.</h1><p >How could you even think 
 otherwise?</p><img src = 'HIPPO.JPG' width = '20'></img><a href = 'http://twistedmatrix.com'>A Good Website</a>
 </body>
 </html>
]]

assert(tinyhtmld:match{boringfier:match{tree}} == boringfied)

print("+")

print("OK")
