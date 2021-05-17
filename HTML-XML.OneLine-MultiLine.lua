-- HTML-XML.OneLine-MultiLine.lua
-- v1.0
-- Visual improvement of HTML-XML code, creates a new file name~2.ext
-- Keys: launch from Macro Browser alt.

local fread   = function(f)   local x,h = nil,io.open(f,"rb") if h then x=h:read("*all")   io.close(h) end return x end
local fwrite  = function(s,f) local x,h = nil,io.open(f,"wb") if h then x=h:write(s or "") io.close(h) end return x end
local fappend = function(s,f) local x,h = nil,io.open(f,"ab") if h then x=h:write(s or "") io.close(h) end return x end

Macro {
description="HTML-XML.OneLine->MultiLine"; area="Shell";
action = function()
  local AP,AC,TMP = APanel.Path0,APanel.Current,win.GetEnv("Temp").."\\"
  local fname,fext = AC:match("^(.*)%.([^%.]*)$")
  local fout = AP.."\\"..fname.."~2."..fext
  local s0 = fread(AP.."\\"..AC)
  fwrite("",fout)

  -- <(/?).+?(/?)>
  local j0,i0,v0,m10 = false,-1,"",""
  for m0,m1,v,m2,s in s0:gmatch("(<([/!%?%[]?)(%[?[%w%-]+)[^>]-([/!%?%-%]]?)>)([^<]*)") do
    local j=m1=="/"
    if     m1~="" and m1~="/" then
    elseif j0 and j           then i0=i0-1
    elseif not j0 and not j   then i0=i0+1
    end
    if m2~=""            then j=true end
    if m1=="" or m1=="/" then j0=j   end
    s=s:gsub("[%s%c]+$","")
    fappend((v~=v0 or v==v0 and (m1=="" or m1==m10) and v0~="") and ("\n"..string.rep(" ",i0)..m0..s) or m0..s,fout)
    v0,m10 = v,m1
  end
end
}
