m = require "listlpeg"

p1 = m.L(m.L"foo" * m.L"bar") + m.L(m.L"baz" * m.L"boo")

m.print(p1)

p2 = m.L(m.L"foobar" * m.L"bazboo")

m.print(p2)

m.print(p1 + p2)

p3 = ((m.L"foo" * m.L"bar") + (m.L"baz" * m.L"boo"))  
p4 = m.L"foobar" * m.L"bazboo"

m.print(p3)
m.print(p4)
m.print(m.L(p3 + p4))
