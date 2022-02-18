-- Editor.TagGoto.lua
-- v1.1.2
-- Tag navigation in files opened in the editor: [dgmsx]?html?, xslt?, [xy]ml
-- Required: plugin LFSearch (LuaFAR Search) by Shmuel
-- Keys: <kbd>Alt[JKLP]</kbd>

local SelectFound=true -- Select Found true=yes, false=no

local Code=[[
local nFound,direction

local XCursor=function(x)
  local EGI=editor.GetInfo()
  editor.SetPosition(EGI.EditorID,{CurPos=EGI.CurPos+x})
end

local patt="(<\\/?(?:\\w+?|xsl:\\w+?-?\\w+?))[ >]|(\\/>)"
local SearchTag=function(direction,pattern)
  local Data={
    sSearchPat=pattern or patt,
    sRegexLib="oniguruma", --"far" (default), "oniguruma", "pcre" or "pcre2"
    bRegExpr=true,
    bSearchBack=direction=="left"
  }
  local nFound=lfsearch.EditorAction("test:search",Data)
  if not Data.bSearchBack then XCursor(-1) end
  return nFound
end

local CaptureTag=function()
  _G.LFST=nil
  local patt=regex.new(patt,"ix")
  local s=editor.GetStringW()
  if not s then return end
  local EGI=editor.GetInfo()
  local pos,pEnd = EGI.CurPos,s.StringLength+1
  _G.Y1 = EGI.CurLine
  if pos>=pEnd then return end
  local text,start = s.StringText.."\0",1
  while true do
    local b,e = patt:findW(text,start)
    if b==nil or b>pos then break
    elseif e>=pos then
      _G.LFST={}
      if e-b==1
      then
        _G.LFST.Rev=true
        _G.LFST.Num=1
        _G.LFST.Cnt=1
      else
        _G.LFST.Txt=win.Utf16ToUtf8(win.subW(text,b,e-1))
        _G.LFST.Rev=_G.LFST.Txt:sub(2,2)=='/'
        _G.LFST.Num=b==pos and not _G.LFST.Rev and 0 or 1
        _G.LFST.Cnt=b==pos and 2 or 1
        _G.LFST.Tag=_G.LFST.Rev and '<'.._G.LFST.Txt:sub(3,-1) or _G.LFST.Txt
      end
      _G.X1=_G.LFST.Rev and e or b
      break
    end
    start=e+1
  end
end

local ProcessingTag=function()
  local Data={
    sSearchPat=patt,
    sReplacePat=[=[
      if T[1] and T[1]==_G.LFST.Txt then _G.LFST.Num=_G.LFST.Num+1
      elseif T[1] and (T[1]:sub(2,2)=='/' and '<'..T[1]:sub(3,-1) or T[1])==_G.LFST.Tag then _G.LFST.Num=LFST.Num-1
      elseif _G.LFST.Rev and T[1] and T[1]:sub(2,2)~='/' and M==_G.LFST.Cnt and not _G.LFST.Tag then _G.LFST.Num=0
      elseif not _G.LFST.Rev and T[2] and T[2]=='/>' and M==_G.LFST.Cnt and _G.LFST.Num==1 then _G.LFST.Num=0
      end
      if _G.LFST.Num==0 then return true,true end
    ]=],
    sRegexLib="oniguruma", --"far" (default), "oniguruma", "pcre" or "pcre2"
    bRegExpr=true,
    bSearchBack=_G.LFST.Rev,
    bRepIsFunc=true,
    bConfirmReplace=true,
    fUserChoiceFunc=function() return "cancel" end
  }
  local nFound,nReps = lfsearch.EditorAction("test:replace",Data)
  if not _G.LFST.Rev then XCursor(-1) end
  return nFound,nReps
end
]]

local Algo=[[
CaptureTag()
if not _G.LFST then
  local ans=far.Message("<=  1st  =>\n=>  2nd  <=","Seek priority","Left;Right")
  if ans==1 then nFound=SearchTag("left") if nFound==0 then nFound=SearchTag("right") end
  elseif ans==2 then nFound=SearchTag("right") if nFound==0 then nFound=SearchTag("left") end
  end
  if nFound==1 then CaptureTag() else return end
end
repeat
  if _G.LFST then
    nFound=ProcessingTag()
    if _G.LFST.Num==0 then
      local EGI=editor.GetInfo()
      local eid,X2,Y2 = EGI.EditorID,EGI.CurPos,EGI.CurLine
      if direction then editor.SetPosition(EGI.EditorID,{CurPos=_G.X1,CurLine=_G.Y1}) end
      return eid,_G.X1,_G.Y1,X2,Y2
    elseif _G.LFST.Num>0 then
      if not direction and _G.LFST.Rev or direction and direction=="left"
      then nFound=SearchTag("left") if nFound==0 then nFound=SearchTag("right") end
      else nFound=SearchTag("right") if nFound==0 then nFound=SearchTag("left") end
      end
    end
  end
  if nFound==1 then CaptureTag() else return end
until nFound==0
]]

local TagLeft=[[
direction="left"
nFound=SearchTag(direction)
if nFound==0 then return end
]]

local TagRight=[[
direction="right"
XCursor(1)
nFound=SearchTag(direction)
if nFound==0 then return end
]]

local TagParent=[[
direction,pattern,pos = "left",...
nFound=SearchTag(direction,pattern)
if nFound==0 then return end
XCursor(pos)
]]

local Proc=function(eid,X1,Y1,X2,Y2)
  if SelectFound and X1 and Y1 and X2 and Y2 then
    local F=far.Flags
    local SelectData={
      BlockType=F.BTYPE_STREAM,
      BlockStartLine=math.min(Y2,Y1),
      BlockStartPos=Y1<Y2 and X1 or (Y1==Y2 and math.min(X1,X2) or X2)
    }
    if X1==X2 then SelectData.BlockStartPos=SelectData.BlockStartPos+(Y1<Y2 and 1 or -1) end
    SelectData.BlockHeight=math.max(Y1,Y2)-math.min(Y1,Y2)+1
    if Y1<Y2 then SelectData.BlockWidth=X2-X1+1
    elseif Y1==Y2 then SelectData.BlockWidth=math.abs(X2-X1)+1
    else SelectData.BlockWidth=X1-X2+1
    end
    if X1==X2 then
      if Y1<Y2
      then SelectData.BlockStartPos=SelectData.BlockStartPos-1
      else SelectData.BlockStartPos=SelectData.BlockStartPos+1
      end
    end
    editor.Select(eid,SelectData)
  end
end

local LFS_Guid="8E11EA75-0303-4374-AC60-D1E38F865449"
local cond=function() return regex.new"/\\.([dgmsx]?html?|xslt?|[xy]ml)$/i":find(Editor.FileName) end

Macro {
  description="TagGoto: <=> Begin/End";
  area="Editor"; key="AltJ";
  condition=cond;
  action=function()
    local eid,X1,Y1,X2,Y2 = Plugin.SyncCall(LFS_Guid,"code",Code..Algo)
    Proc(eid,X1,Y1,X2,Y2)
  end
}

Macro {
  description="TagGoto:  <= Parent";
  area="Editor"; key="AltP";
  --condition=cond;
  action=function()
    local _,pos = editor.GetString(nil,Editor.CurLine,3):find('^(\t+)[^\t]')
    if pos then Plugin.SyncCall(LFS_Guid,"code",Code..TagParent,"^\\t{"..(pos-2).."}[^\\t]",pos-1) end
  end
}

Macro {
  description="TagGoto:  <= Left";
  area="Editor"; key="AltK";
  condition=cond;
  action=function()
    local eid,X1,Y1,X2,Y2 = Plugin.SyncCall(LFS_Guid,"code",Code..TagLeft..Algo)
    Proc(eid,X1,Y1,X2,Y2)
  end
}

Macro {
  description="TagGoto:  => Right";
  area="Editor"; key="AltL";
  condition=cond;
  action=function()
    local eid,X1,Y1,X2,Y2 = Plugin.SyncCall(LFS_Guid,"code",Code..TagRight..Algo)
    Proc(eid,X1,Y1,X2,Y2)
  end
}
