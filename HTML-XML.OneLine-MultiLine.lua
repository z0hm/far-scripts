-- HTML-XML.OneLine-MultiLine.lua
-- v1.0.0.1
-- Visual improvement of HTML-XML code, creates a new file name~2.ext
-- Keys: launch from Macro Browser alt.

Macro {
description="HTML-XML.OneLine->MultiLine"; area="Shell";
action = function()
  local tab="\t"
  local AP,AC = APanel.Path0,APanel.Current
  local fname,fext = AC:match("^(.*)%.([^%.]*)$")
  local fin,fout = AP.."\\"..AC,AP.."\\"..fname.."~2."..fext
  local w=io.open(fout,"wb") w:write("") w:close()
  local r=io.open(fin, "rb")
  local a=io.open(fout,"ab")

  -- <(/?).+?(/?)>
  local i,j0,v0,m10 = -1,false,"",""
  for l in r:lines() do
    for m0,m1,v,m2,s in l:gmatch("(<([/!%?%[]?)(%[?[%w%-]+)[^>]-([/!%?%-%]]?)>)([^<]*)") do
      local j=m1=="/"
      local k=j or m1==""
      if k then if j0 and j then i=i-1 elseif not (j0 or j) then i=i+1 end end
      if m2~="" then j=true end
      if k then j0=j end
      s=s:gsub("[%s%c]+$","")
      if v0~="" and (v0~=v or (m1==m10 or m1=="")) then a:write("\n"..string.rep(tab,i)) end
      a:write(m0..s)
      v0,m10 = v,m1
    end
  end
  a:close()
  r:close()
end
}
