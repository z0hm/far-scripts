-- HTML-XML.OneLine-MultiLine.lua
-- v1.0
-- Visual improvement of HTML-XML code, creates a new file name~2.ext
-- Keys: launch from Macro Browser alt.

local fread  = function(f)   local x,h = nil,io.open(f,"rb") if h then x=h:read("*all")   io.close(h) end return x end
local fwrite = function(s,f) local x,h = nil,io.open(f,"wb") if h then x=h:write(s or "") io.close(h) end return x end

Macro {
description="HTML-XML.OneLine->MultiLine"; area="Shell";
action = function()
  local tab="\t"
  local AP,AC,TMP = APanel.Path0,APanel.Current,win.GetEnv("Temp").."\\"
  local fname,fext = AC:match("^(.*)%.([^%.]*)$")
  local fin,fout = AP.."\\"..AC,AP.."\\"..fname.."~2."..fext
  fwrite("",fout)
  local r=io.open(fin, "rb")
  local a=io.open(fout,"ab")

  -- <(/?).+?(/?)>
  local i,j0,v0,m10 = -1,false,"",""
  for l in r:lines() do
    for m0,m1,v,m2,s in l:gmatch("(<([/!%?%[]?)(%[?[%w%-]+)[^>]-([/!%?%-%]]?)>)([^<]*)") do
      local j=m1=="/"
      if     m1~="" and m1~="/" then
      elseif j0 and j           then i=i-1
      elseif not j0 and not j   then i=i+1
      end
      if m2~=""            then j=true end
      if m1=="" or m1=="/" then j0=j   end
      s=s:gsub("[%s%c]+$","")
      a:write((v~=v0 or v==v0 and (m1=="" or m1==m10) and v0~="") and string.rep(tab,i)..m0..s.."\n" or m0..s)
      v0,m10 = v,m1
    end
  end
  a:close()
  r:close()
end
}
