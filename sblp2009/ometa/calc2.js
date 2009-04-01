// parser and simple interpreter combo

ometa CalcInterpreter2 {
  interp = ['num' anything]        
         | ['add' interp interp] 
         | ['sub' interp interp] 
         | ['mul' interp interp] 
         | ['div' interp interp] 
}

d1 = new Date()
for(i = 0; i < 1000; i++)
  CalcInterpreter2.match(exps[i], 'interp');
d2 = new Date()
print((d2.getTime() - d1.getTime())/1000)
