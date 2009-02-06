m = require "lpeg"

p = m.L(m.I"one" * m.I"two" * m.I(m.L(m.I"foo" * m.I"bar")) * m.I"three")

assert(p:match{ "one", "two", { "foo", "bar" }, "three" })

p = m.L(m.I"one" * m.I"two" * (m.I(m.L(m.I"foo" * m.I"bar")) +
			     m.I(m.L(m.I"baz" * m.I"boo"))) * m.I"three")

assert(p:match{ "one", "two", { "foo", "bar" }, "three" })
assert(p:match{ "one", "two", { "baz", "boo" }, "three" })
assert(not p:match{ "one", "two", { "baz", "bar" }, "three" })

p = m.L(m.I"one" * m.I"two"^1 * m.I"three")

assert(p:match{ "one", "two", "three" })
assert(not p:match{ "one", "three" })
assert(p:match{ "one", "two", "two", "three" })
assert(p:match{ "one", "two", "two", "two", "three" })

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
								 return tonumber(x) + tonumber(y)
							       end })

assert(p:match{ "add", "2", "3" } == 5)
assert(p:match{ "add", "72", "3" } == 75)
assert(not p:match{ "sub", "72", "3" })

p = re.compile[[ {{ "foo", { "bar", (!"baz".)*, "baz" }, "boo" }} ]]

assert(p:match{ "foo", "bar", "one", "two", "three", "baz", "boo" }[4] == "three")
assert(#(p:match{ "foo", "bar", "one", "two", "three", "baz", "boo" }) == 5)
assert(p:match{ "foo", "bar", "one", "two", "three", "baz", "boo" }[5] == "baz")
assert(p:match{ "foo", "bar", "baz", "boo" }[2] == "baz")
assert(#(p:match{ "foo", "bar", "baz", "boo" }) == 2)

p = re.compile[[ {{ "foo", "bar", { (!"baz".)* }, "baz" , "boo" }} ]]

assert(#(p:match{ "foo", "bar", "one", "two", "three", "baz", "boo" }) == 3)
assert(p:match{ "foo", "bar", "one", "two", "three", "baz", "boo" }[3] == "three")
assert(#(p:match{ "foo", "bar", "baz", "boo" }) == 0)

