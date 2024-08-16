-- RESearch.Grep.lua
-- v1.4.2.3
-- Comfortable Grep text from files by search pattern to editor
-- ![RESearch Grep](http://i.piccy.info/i9/23f14ef428e4f1d2f1fc1937da2a549c/1442294013/13901/950058/1.png)
-- Press AltG, MacroBrowserAlt.lua file will be opened in the editor and the cursor will be set to this position on hDlg.
-- Actions:
-- 1. Grep:  Goto this line in this file
-- 2. Grep:  Save this line in this file
-- 3. Grep:  Save all lines in this file
-- 4. Grep:  Save all lines in all files
-- Required: plugin RESearch or LFSearch
-- Keys: AltG
-- Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2600#19

local MacroKey = "AltG"

local F = far.Flags
local EFlags = bit64.bor(F.EF_NONMODAL, F.EF_IMMEDIATERETURN, F.EF_OPENMODE_USEEXISTING)
local LinePattern = "^(%d-)[-:](.+)$"
local FileMask = "/\\w+\\.tmp$/i"

local e=editor
local GetInfo,GetString,Editor,SetPosition,SetString,SaveFile,Quit = e.GetInfo,e.GetString,e.Editor,e.SetPosition,e.SetString,e.SaveFile,e.Quit

local function GetFileName(l) return regex.match(l,[[^(?:\[\d+?\] )?([A-Z]:.+?)(?: :|:|$)]]) end
local function GInfo()
  local ei=GetInfo(-1)
  local y,x,p = ei.CurLine,ei.CurPos,ei.LeftPos
  local l,i,f = GetString(-1,y).StringText,y
  local n,s = l:match(LinePattern)
  repeat
    i,f = i-1,GetFileName(GetString(-1,i).StringText)
  until f or i==-1
  return f,l,y,x,p,n,s,i
end

local function FileSave(t)
  Editor(t[1][1],_,_,_,_,_,EFlags)
  for j=2,#t do local StringEOL=GetString(-1,t[j][1]).StringEOL SetString(-1,t[j][1],t[j][2],StringEOL) end
  if not SaveFile(-1) then far.Message(t[1][1],"Warning! File is not saved - blocked?") else Quit(-1) end
end

Macro {
area="Editor"; key=MacroKey; flags=""; description="Grep:  Goto this line in this file"; filemask=FileMask;
action=function()
  local f,l,y,x,p,n,s = GInfo()
  if f then
    if n then
      Editor(f,_,_,_,_,_,EFlags,tonumber(n),x-#n-1)
      SetPosition(-1,tonumber(n),x-#n-1,_,_,p-#n)
    else
      Editor(f,_,_,_,_,_,EFlags,1,1)
      SetPosition(-1,1,1)
    end
  end
end;
}

Macro {
area="Editor"; key=MacroKey; flags=""; description="Grep:  Save this line in this file"; filemask=FileMask;
action=function()
  local f,l,y,x,p,n,s = GInfo()
  if n then
    SetPosition(-1,y,x,_,_,p)
    if f then
      Editor(f,_,_,_,_,_,EFlags,tonumber(n),x-#n-1)
      SetString(-1,n,s)
      if not SaveFile(-1) then far.Message(f,"Warning! File is not saved - blocked?") else Quit(-1) end
    end
  end
end;
}

Macro {
area="Editor"; key=MacroKey; flags=""; description="Grep:  Save all lines in this file"; filemask=FileMask;
action=function()
  local t,_,_,_,_,_,_,_,i = {},GInfo()
  for j=i,GetInfo(-1).TotalLines do
    local l=GetString(-1,j).StringText
    local y,s = l:match(LinePattern)
    if y and s and #t>=1
    then table.insert(t,{y,s})
    else
      local f=GetFileName(l)
      if f then
        if #t>1 then FileSave(t) t={} break end
        t[1]={f,nil}
      end
    end
  end
  if #t>1 then FileSave(t) end
end;
}

Macro {
area="Editor"; key=MacroKey; flags=""; description="Grep:  Save all lines in all files"; filemask=FileMask;
action=function()
  local t={}
  for j=1,GetInfo(-1).TotalLines do
    local l=GetString(-1,j).StringText
    local y,s = l:match(LinePattern)
    if y and s and #t>=1
    then table.insert(t,{y,s})
    else
      local f=GetFileName(l)
      if f then
        if #t>1 then FileSave(t) t={} end
        t[1]={f,nil}
      end
    end
  end
  if #t>1 then FileSave(t) end
end;
}
