package = "ListLPEG"
version = "scm-1"
source = {
   url = "http://www.lua.inf.puc-rio.br/~mascarenhas/listlpeg-scm.tar.gz",
}
description = {
   summary = "Parsing Expression Grammars For Lua with List Support",
   detailed = [[
      Support for matching lists with LPEG
      (http://www.inf.puc-rio.br/~roberto/lpeg), like 
      OMeta (http://tinlizzie.org/ometa-js/).
   ]],
   homepage = "http://github.com/mascarenhas/lpeg-list/tree/master",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "module",
   modules = {
      listlpeg = "lpeg.c",
      ["listlpeg.re"] = "re.lua",
      listre = "listre.lua"
   }
}
