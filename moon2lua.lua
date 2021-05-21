-- moon2lua.lua
-- v1.0
-- author Shmuel, 28.05.2020
-- copy to folder included Moonscript files and run it: lua:@moon2lua.lua
-- all Moonscript files will be deleted after convert!

local to_lua = (require"moonscript.base").to_lua
far.RecursiveSearch(far.GetCurrentDirectory(),"*.moon",
  function(item,fullpath)
    local fp = assert(io.open(fullpath))
    local str = fp:read("*all")
    fp:close()
    local newpath = fullpath:sub(1,-5).."lua"
    fp = assert(io.open(newpath,"w"))
    str = assert(to_lua(str))
    fp:write(str,"\n")
    fp:close()
    --win.DeleteFile(fullpath)
  end,
  "FRS_RECUR"
)
