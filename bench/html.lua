
local m = require "listlpeg"
local re = require "listre"

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

local S = m.S(" \n\t")^0

local tinyhtmlp = re.compile([[
  html <- (<tag> / <text>)* -> {}
  name <- <[0-9a-zA-Z_-]+>
  tag <- (`< <name>:n %s (<attribute>*->{}):attrs `> 
    <html>:c %s '</' %s =n %s '>') -> {n, attrs, c}
  text <- <(!'<' .)+>
  attribute <- (%s <name>:k `= <quotedString>:v %s) -> {k, v}
  quotedString <- ('"' / '\''):q <(!=q .)*> =q
]], { s = S })

local tree = tinyhtmlp:match([[
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

local tinyhtmld = re.compile([[
  html <- { <tag>* } -> {} -> concat   
  tag <- {  <.>, . -> formatattrs, <html> } -> ptag / <.>
]], { concat = table.concat, 
      ptag = function(tag, attrs, body)
	       return  string.format("<%s %s>%s</%s>", tag, 
				     attrs, body, tag)
	     end,
      formatattrs = function(attrs) 
		       local t = {}
		       for i = 1, #attrs do
			  t[i] = string.format("%s = '%s'", attrs[i][1], attrs[i][2])
		       end
		       return table.concat(t, " ")
		    end})

local dump = [[<html ><title >Yes</title><body ><h1 >Man, HTML is
 <i >great</i>.</h1><p >How could you even <b >think</b> 
 otherwise?</p><img src = 'HIPPO.JPG' width = '20'></img><a href = 'http://twistedmatrix.com'>A Good Website</a>
 </body>
 </html>
]]

assert(tinyhtmld:match{tree} == dump)

local linkextract = re.compile([[
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

local function test()
   assert(#linkextract:match{tree} == 2)
   assert(linkextract:match{tree}[1] == "HIPPO.JPG")
   assert(linkextract:match{tree}[2] == "http://twistedmatrix.com")
end

local function linkextract2(tree)
   local links = {}
   for _, tag in ipairs(tree) do
      if #tag == 3 and tag[1] == "a" then
	 local href
	 for _, attr in ipairs(tag[2]) do
	    if #attr == 2 and attr[1] == "href" then
	       if href then
		  href = nil
		  break
	       end
	       href = attr[2]
	    elseif #attr ~= 2 then
	       href = nil
	       break
	    end
	 end
	 links[#links+1] = href
	 for _, link in ipairs(linkextract2(tag[3])) do links[#links+1] = link end
      elseif #tag == 3 and tag[1] == "img" then
	 local src
	 for _, attr in ipairs(tag[2]) do
	    if #attr == 2 and attr[1] == "src" then
	       if src then
		  src = nil
		  break
	       end
	       src = attr[2]
	    elseif #attr ~= 2 then
	       src = nil
	       break
	    end
	 end
	 links[#links+1] = src
	 for _, link in ipairs(linkextract2(tag[3])) do links[#links+1] = link end
      elseif #tag == 3 and tag[3] then
	 for _, link in ipairs(linkextract2(tag[3])) do links[#links+1] = link end
      end
   end
   return links
end

local function test2()
   assert(#linkextract2(tree) == 2)
   assert(linkextract2(tree)[1] == "HIPPO.JPG")
   assert(linkextract2(tree)[2] == "http://twistedmatrix.com")
end

test()
test2()

local linkextract_matchonly = re.compile([[
  html <- <contents> 
  contents <- { <tag>* }
  tag <- { "a", <href>, <contents> }
         / { "img", <src>, <contents> }
         / { ., ., <contents> } 
         / .
  href <- { { (!"href" .), . }*,
	    { "href", . },
            { (!"href" .), . }* }
  src <- { { (!"src" .), . }*,
	   { "src", (.) },
           { (!"src" .), . }* }
]])

local function linkextract2_matchonly(tree)
   for _, tag in ipairs(tree) do
      if #tag == 3 and tag[1] == "a" then
	 local href
	 for _, attr in ipairs(tag[2]) do
	    if #attr == 2 and attr[1] == "href" then
	       if href then
		  return false
	       end
	       href = true
	    elseif #attr ~= 2 then
	       return false
	    end
	 end
	 return linkextract2_matchonly(tag[3])
      elseif #tag == 3 and tag[1] == "img" then
	 local src
	 for _, attr in ipairs(tag[2]) do
	    if #attr == 2 and attr[1] == "src" then
	       if src then
		  return false
	       end
	       src = true
	    elseif #attr ~= 2 then
	       return false
	    end
	 end
	 return linkextract2_matchonly(tag[3])
      elseif #tag == 3 and tag[3] then
	 return linkextract2_matchonly(tag[3])
      end
   end
   return true
end

local function test3()
   assert(linkextract_matchonly:match{ tree } == 2)
end
local function test4()
   assert(linkextract2_matchonly(tree))
end

test3()
test4()

return test, test2, test3, test4

