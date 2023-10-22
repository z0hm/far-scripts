-- HTML-XML.OneLine-MultiLine.lua
-- v1.0.0.3
-- Visual improvement of HTML-XML code (pretty print), creates a new file name~2.ext
-- Keys: launch from Macro Browser alt.

local string=string
local srep = string.rep

Macro {
description="HTML-XML.OneLine->MultiLine"; area="Shell Editor";
action = function()
  local tab,fin = "\t",""
  if Area.Shell then fin=APanel.Path0.."\\"..APanel.Current
  elseif Area.Editor then fin=Editor.FileName
  end
  local fname,fext = fin:match("^(.*)(%.[^%.\\]*)$")
  local fout = fext and fname.."~2"..fext or fin.."~2"
  local w=io.open(fout,"wb") w:write("") w:close()
  local r=io.open(fin, "rb")
  local a=io.open(fout,"ab")

  -- <(/?).+?(/?)>
  local i,j0,v0,m10 = -1,false,"",""
  for l in r:lines() do
    for m0,m1,v,m2,s in l:gmatch("(<([/!%?%[]?)(%[?[%w%-]+)[^>]-([/!%?%-%]]?)>)([^<]*)") do
      local j=m1=="/"
      local k=j or m1==""
      if k then if j0 and j then if i>0 then i=i-1 end elseif not (j0 or j) then i=i+1 end end
      if m2~="" then j=true end
      if k then j0=j end
      s=s:gsub("[%s%c]+$","")
      if v0~="" and (v0~=v or (m1==m10 or m1=="")) then a:write("\n"..srep(tab,i)) end
      a:write(m0..s)
      v0,m10 = v,m1
    end
  end
  a:close()
  r:close()
end
}
