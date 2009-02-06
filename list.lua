m = require "lpeg"

p = m.L(m.I"one" * m.I"two" * m.I(m.L(m.I"foo" * m.I"bar")) * m.I"three")

assert(p:match{ "one", "two", { "foo", "bar" }, "three" })

p = m.L(m.I"one" * m.I"two" * (m.I(m.L(m.I"foo" * m.I"bar")) +
			     m.I(m.L(m.I"baz" * m.I"boo"))) * m.I"three")

assert(p:match{ "one", "two", { "foo", "bar" }, "three" })
assert(p:match{ "one", "two", { "baz", "boo" }, "three" })
assert(not p:match{ "one", "two", { "baz", "bar" }, "three" })
assert(not p:match{ "one", "tw", { "foo", "bar" }, "three" })
assert(not p:match{ "one", "two", { "baz", "boo" } })
assert(not p:match{ "one", "two", { "baz", "boo" }, "thr" })

p = m.L(m.I"one" * m.I"two"^1 * m.I"three")

assert(p:match{ "one", "two", "three" })
assert(not p:match{ "one", "three" })
assert(p:match{ "one", "two", "two", "three" })
assert(p:match{ "one", "two", "two", "two", "three" })

p = m.L(m.I"one" * m.I"two"^1 * m.I("thr" * m.P("e")^1))

assert(p:match{ "one", "two", "three" })
assert(not p:match{ "one", "three" })
assert(p:match{ "one", "two", "two", "three" })
assert(p:match{ "one", "two", "two", "two", "three" })
assert(p:match{ "one", "two", "threeeee" })
assert(not p:match{ "one", "two", "thr" })

p = m.L(m.I"one" * lpeg.C(lpeg.I"two") * (m.I(m.L(m.I"foo" * m.I"bar")) +
			     m.I(m.L(m.I"baz" * m.I"boo")))^0 * m.I"three")

assert(p:match{ "one", "two", "three" }[1] == "two")
assert(#(p:match{ "one", "two", "three" }) == 1)
assert(p:match{ "one", "two", { "foo", "bar" }, "three" })
assert(p:match{ "one", "two", { "baz", "boo" }, "three" })
assert(not p:match{ "one", "two", { "baz", "bar" }, "three" })
assert(p:match{ "one", "two", { "foo", "bar" }, { "baz", "boo" }, "three" })

p = m.L(m.I"one" * lpeg.C(lpeg.I"two" * (m.I(m.L(m.I"foo" * m.I"bar")) +
				       m.I(m.L(m.I"baz" * m.I"boo")))^0)
      * m.I"three")

assert(p:match{ "one", "two", "three" }[1] == "two")
assert(#(p:match{ "one", "two", "three" }) == 1)
assert(#(p:match{ "one", "two", { "foo", "bar" }, { "baz", "boo" },
		  "three" }) == 3)
assert(p:match{ "one", "two", { "foo", "bar" }, { "baz", "boo" },
		"three" }[3][1] == "baz")

p = m.L(m.I"one" * lpeg.C(lpeg.I"two" * (m.I(m.L(m.I("foo" * lpeg.P("bar")^0) * 
					       m.I"bar")) +
				       m.I(m.L(m.I"baz" * m.I"boo")))^0)
      * m.I"three")

assert(p:match{ "one", "two", "three" }[1] == "two")
assert(#(p:match{ "one", "two", "three" }) == 1)
assert(#(p:match{ "one", "two", { "foo", "bar" }, { "baz", "boo" },
		  "three" }) == 3)
assert(p:match{ "one", "two", { "foobarbarbar", "bar" }, { "baz", "boo" },
		"three" }[2][1] == "foobarbarbar")
assert(#(p:match{ "one", "two", { "foobarbar", "bar" }, { "baz", "boo" },
		  "three" }) == 3)

re = require "re"

p = re.compile[[ {{ "one", {"two"}, "three" }} ]]

assert(p:match{ "one" , "two" ,"three" })

p = re.compile[[
    {{ "one", { "two", ({{ ("foo""bar"*), "bar" }} / {{ "baz", "boo" }})* },
     "three" }}
]]

assert(p:match{ "one", "two", "three" }[1] == "two")
assert(#(p:match{ "one", "two", "three" }) == 1)
assert(#(p:match{ "one", "two", { "foo", "bar" }, { "baz", "boo" }, "three" }) == 3)
assert(p:match{ "one", "two", { "foobarbarbar", "bar" }, { "baz", "boo" },
		"three" }[2][1] == "foobarbarbar")
assert(#(p:match{ "one", "two", { "foobarbar", "bar" }, { "baz", "boo" },
		  "three" }) == 3)


p = re.compile([[ {{ "add", ({.+}), ({.+}) }} -> add ]], { add = function (x, y)
								    return x+y
								 end })

assert(p:match{ "add", 2, 3 })
assert(p:match{ "add", 72, 3 } == 75)
assert(p:match{ "add", 72.5, 3 } == 75.5)
assert(not p:match{ "sub", 72, 3 })
assert(not p:match{ "add", 3 })

p = re.compile[[ {{ "foo", { "bar", (!"baz" .+)*, "baz" }, "boo" }} ]]

assert(p:match{ "foo", "bar", "one", "two", "three", "baz", "boo" }[4] == "three")
assert(#(p:match{ "foo", "bar", "one", "two", "three", "baz", "boo" }) == 5)
assert(p:match{ "foo", "bar", "one", "two", "three", "baz", "boo" }[5] == "baz")
assert(p:match{ "foo", "bar", "baz", "boo" }[2] == "baz")
assert(#(p:match{ "foo", "bar", "baz", "boo" }) == 2)

p = re.compile[[ {{ "foo", "bar", { (!"baz" .+)* }, "baz" , "boo" }} ]]

assert(#(p:match{ "foo", "bar", "one", "two", "three", "baz", "boo" }) == 3)
assert(p:match{ "foo", "bar", "one", "two", "three", "baz", "boo" }[3] == "three")
assert(#(p:match{ "foo", "bar", "baz", "boo" }) == 0)

p = re.compile([[
	       exp <- {{ "add", <exp>, <exp> }} -> add
                    / {{ "sub", <exp>, <exp> }} -> sub
		    / {{ "mul", <exp>, <exp> }} -> mul
		    / {{ "div", <exp>, <exp> }} -> div
		    / {.}
    ]], { add = function (x, y) return x + y end, 
          sub = function (x, y) return x - y end,
          mul = function (x, y) return x * y end,
          div = function (x, y) return x / y end, })

assert(p:match{ "add", { "div", 8, 2 }, 3 } == 7)
assert(p:match{ "sub", { "div", 8, { "add", 2, 2 } }, 3 } == -1)

p = re.compile([[ exp <- {{ (.+ -> ops), <exp>, <exp> }} -> eval / {.} ]], 
	       { ops = { add = function (x, y) return x + y end, 
                         sub = function (x, y) return x - y end,
                         mul = function (x, y) return x * y end,
                         div = function (x, y) return x / y end, },
                 eval = function (op, x, y) return op(x, y) end })

assert(p:match{ "add", { "div", 8, 2 }, 3 } == 7)
assert(p:match{ "sub", { "div", 8, { "add", 2, 2 } }, 3 } == -1)

parser = re.compile([[
  exp <- <add>
  add <- (<mul> <aop> <add>) -> ast / <mul>
  mul <- (<prim> <mop> <mul>) -> ast / <prim>
  prim <- (%s "(" %s <exp> %s ")" %s) / (%s %num %s) -> tonumber
  aop <- (%s "+" -> "add" %s) / (%s "-" -> "sub" %s)
  mop <- (%s "*" -> "mul" %s) / (%s "/" -> "div" %s)
]], { s = m.S(" \n\t")^0, num = m.C(lpeg.P"-"^-1 * lpeg.R("09")^1), tonumber = tonumber,
      ast = function (op1, op, op2) return { op, op1, op2 } end })

assert(p:match(parser:match("8/2+3")) == 7)
assert(p:match(parser:match("8 / (2 + 2) - 3")) == -1)
