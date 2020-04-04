-- lua
local function fread(f) local x,h = nil,io.open(f,"rb") if h then x=h:read("*all") io.close(h) end return x end
local function fwrite(f,s) local x,h = nil,io.open(f,"wb") if h then x=h:write(s or "") io.close(h) end return x end
local function fappend(f,s) local x,h = nil,io.open(f,"ab") if h then x=h:write(s or "") io.close(h) end return x end

local F = far.Flags

local dir,readme,mask,tf = "C:\\far-scripts","README.md",{"*.lua","*.moon"},{}
local gen=dir.."\\readme-gen.lua"
local git_readme=dir.."\\"..readme
local gist_readme=dir.."\\gist\\"..readme
local urlhost="https://github.com/z0hm/far-scripts"

for i=1,#mask do
  far.RecursiveSearch(dir,mask[i],function(item,fullpath) if not item.FileAttributes:find("d") then table.insert(tf,{fullpath:match("[^\\]+$"),fullpath,item.FileSize}) end end,7)
end
table.sort(tf,function(a,b) return a[1]<b[1] end)

-- [link text](url "title text")
local far_scripts='# [far-scripts]('..urlhost..' "far-scripts")\n\n\n'
far_scripts=far_scripts..
[[
lua and moon scripts repository for [Far Manager 3.0](https://farmanager.com/ "File Manager for Windows")

Far Manager is powerful files and archives manager and first choice Admins for Windows OSes.
Far Manager works in text mode and provides a simple and intuitive interface
for performing most of the necessary actions: viewing files and directories;
editing, copying and renaming files; and MANY other actions.

Far Manager has a built-in scripting languages: [lua](https://www.lua.org/ "Lua scripting language")
and [moon](https://moonscript.org/ "MoonScript language"), which allows you to solve
a very wide range of tasks using the Far and Windows API's.


## A brief summary of scripts in the repository:
]]

fwrite(git_readme,far_scripts)
for i=1,#tf do
  if tf[i][2]~=gen then
    fappend(git_readme,'\n\n## ['..tf[i][1]..']('..urlhost..'/blob/master/'..tf[i][1]..' "'..tf[i][1]..'")   *('..tf[i][3]..' bytes)*')
    local h=io.open(tf[i][2],"r")
    while true do
      local s=h:read("*l")
      if s:find("^%-%-$") then fappend(git_readme,"\n\n")
      elseif s:find("^%-%- ") or s:find("^\239\187\191%-%- ") then
        local l=s:match("%-%- (.+)$")
        if l and l~=tf[i][1] then
          local r=" <kbd>%1</kbd>"
          l=l:gsub(" (CtrlShiftF%d+)",r)
          l=l:gsub(" (CtrlShift[A-Z])",r)
          l=l:gsub(" (CtrlAltF%d+)",r)
          l=l:gsub(" (CtrlAlt[A-Z])",r)
          l=l:gsub(" (Alt[A-Z])",r)
          l=l:gsub(" (F%d+)",r)
          l=l:gsub("[]",function(s) if s=="" then s="&#9829;" elseif s=="" then s="&#9830;" elseif s=="" then s="&#9827;" elseif s=="" then s="&#9824;" end return s end)
          fappend(git_readme,"\n\n  "..l)
        end
      else
        fappend(git_readme,"\n\n\n")
        break
      end
    end
    h:close()
  end
end
-- far.MkLink(git_readme,gist_readme,F.LINK_HARDLINK,F.MLF_SHOWERRMSG)
-- git commit -a -m "update"
-- git push origin master
-- cd gist
-- git commit -a -m "update"
-- git push origin master
-- cd ..
