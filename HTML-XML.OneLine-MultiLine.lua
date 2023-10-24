-- HTML-XML.OneLine-MultiLine.lua
-- v1.0.1.1
-- Visual improvement of HTML-XML code (pretty print), creates a new file name~2.ext
-- Keys: launch from Macro Browser alt.

local string=string
local srep = string.rep
local table=table
local tinsert,tremove = table.insert,table.remove

Macro {
description="HTML-XML.OneLine->MultiLine"; area="Shell Editor";
action = function()
  local eol,tab,fin = "\n","\t",""
  if Area.Shell then fin=APanel.Path0.."\\"..APanel.Current
  elseif Area.Editor then fin=Editor.FileName
  end
  local fname,fext = fin:match("^(.*)(%.[^%.\\]*)$")
  local fout = fext and fname.."~2"..fext or fin.."~2"
  local w=io.open(fout,"wb") w:write("") w:close()
  local r=io.open(fin, "rb")
  local a=io.open(fout,"ab")

  -- <(/?).+?(/?)>
  local i,t,p,m10,m20,v0 = 0,{},-1,"",""
  for l in r:lines() do
    l=l:gsub("^[%s%c]+",""):gsub("[%s%c]+$","")
    if l=="" then a:write(eol) if v0 then v0="" end
    else
      local z=true
      for m0,m1,v,m2,s in l:gmatch("(<([/!%?%[]?)(%[?[%w_%-:]+)[^>]-([/!%?%-%]]?)>)([^<]*)") do
        if m1=="/" then for j=i,1,-1 do if t[j][1]==v then p=t[j][2] i=j-1 break end end
        else if m10=="" and m20=="" then p=p+1 end if m2~="/" then i=i+1 t[i]={v,p} end
        end
        if v0 and (v~=v0 or (m1==m10 or m1=="")) then a:write(eol..srep(tab,p)) end
        a:write(m0..s)
        v0,m10,m20,z = v,m1,m2,false
      end
      if z then a:write(eol..srep(tab,p)..l) if v0 then v0="" end end
    end
  end
  a:close()
  r:close()
end
}
