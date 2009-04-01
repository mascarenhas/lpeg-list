// parser and simple interpreter combo

ometa CalcInterpreter {
  interp = ['num' anything:x]        -> x
         | ['add' interp:x interp:y] -> (x + y)
         | ['sub' interp:x interp:y] -> (x - y)
         | ['mul' interp:x interp:y] -> (x * y)
         | ['div' interp:x interp:y] -> (x / y)
}

d1 = new Date()
for(i = 0; i < 1000; i++)
  CalcInterpreter.match(exps[i], 'interp');
d2 = new Date()
print((d2.getTime() - d1.getTime())/1000)
