
ometa tinyhtml <: Parser {
name = letterOrDigit+:ls -> ls.join(''),
tag = ('<' spaces name:n spaces attribute*:attrs '>'
         html:c
         '<' '/' token(n) spaces '>'
             -> [n.toLowerCase(), attrs, c]),
html = (text | tag)*,
text = (~('<') anything)+:t -> t.join(''),
attribute = spaces name:k token('=') quotedString:v -> [k, v],
quotedString = ('"' | '\''):q (~exactly(q) anything)*:xs exactly(q) -> xs.join('')
}

tree = tinyhtml.matchAll("<html><title>Yes</title><body><h1>Man, HTML is
 <i>great</i>.</h1><p>How could you even <b>think</b> 
otherwise?</p><img src='HIPPO.JPG'></img><a 
href='http://twistedmatrix.com'>A Good Website</a></body></html>", 'html')

function flatten(anArray) {
  var res = [];
  for(var i = 0; i < anArray.length; i++) {
    if(anArray[i].constructor == Array)
      res = res.concat(flatten(anArray[i]));
    else
      res.push(anArray[i]);
  }
  return res
}

ometa linkextract {
  contents = [ tag*:t ] -> flatten(t),
  tag =  [ #a href:h contents:t ] -> [ h ].concat(t)
       | [ #img src:s contents:t ] -> [ s ].concat(t)
       | [ :name :attrs contents:t ] -> t 
       | :text -> [],
  href = [ ([(~('href') anything) anything ])*
           [ 'href' :h ] ]
           ([(~('href') anything) anything ])* -> h,
  src = [ [(~#src anything) anything ]*
	  [ #src :s ]
          [(~#src anything) anything ]* ] -> s
}

links = linkextract.matchAll([tree], 'contents')

print(links)

d1 = new Date()
for(i = 0; i < 1000; i++)
  linkextract.matchAll([tree], 'contents');
d2 = new Date()
print((d2.getTime() - d1.getTime())/1000)

ometa linkextract2 {
  contents = [ tag* ],
  tag =  [ #a href contents ] 
       | [ #img src contents ]
       | [ anything anything contents ] 
       | anything,
  href = [ ([(~('href') anything) anything ])*
           [ 'href' anything ] ]
           ([(~('href') anything) anything ])*,
  src = [ [(~#src anything) anything ]*
	  [ #src anything ]
          [(~#src anything) anything ]* ]
}

d1 = new Date()
for(i = 0; i < 1000; i++)
  linkextract2.matchAll([tree], 'contents');
d2 = new Date()
print((d2.getTime() - d1.getTime())/1000)
