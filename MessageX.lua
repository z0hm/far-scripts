-- MessageX.lua
-- v0.6.1
-- Color **MessageX(Msg,Title,Buttons,Flags,HelpTopic,Guid)** module with support default button assignments
-- ![MessageX Dialog](http://i.piccy.info/i9/f32e76a419bc6d8296d2b97fb581a87e/1587382829/2331/1373917/2020_04_20_143539.png)
-- Support flags: **"wlcm"**
-- **w** - warning dialog, **l** - left align (default center align), **c** - color mode, **m** - monochrome mode
-- without **cm** will be used raw mode 
-- Tags format: **<#xy>**, **x** - foreground color **0..f**, **y** - background color **0..f**
-- **r** - restore default color for foreground/background, **s** - skip, don't change foreground/background color
-- Example message string: "aaa<#e1>bbb<#s2>\nccc<#bs>ddd\neee<#rs>fff<#sr>ggg"
--
-- Usage: put **MessageX.lua** to modules folder
-- Call in scripts (example):
-- ``` lua
--   local MessageX = require'MessageX'
--   MessageX("aaa <#e2>bbb<#s1>\nccc<#bs> ddd\neee<#9s> fff <#sr> ggg <#ec>hhh","MessageX","&Ok;!Ca&ncel","wc")
-- ```

local F=far.Flags
local K=far.Colors

local pat="<#([0-9A-FRSa-frs])([0-9A-FRSa-frs])>"
local patlen=5

local function CreateColorTbl(tbl,width)
  local ct={}
  local line,smax,fg,bg = 1,0
  while line<=#tbl do
    table.insert(ct,{})
    local len,to,from,_fg,_bg = 0,0
    repeat
      from,to,_fg,_bg = tbl[line]:find(pat,to+1)
      if from then
        _fg=_fg:lower() _bg=_bg:lower()
        if _fg=="r" then fg=nil
        elseif _fg~="s" then fg=tonumber(_fg,16)
        end
        if _bg=="r" then bg=nil
        elseif _bg~="s" then bg=tonumber(_bg,16)
        end
        ct[line][from-len]={fg=fg,bg=bg}
        len=len+patlen
      end
    until not from
    tbl[line]=tbl[line]:gsub(pat,"")
    local sz=tbl[line]:len()
    local w=width-4
    if sz>=w then smax=w elseif smax<sz then smax=sz end
    while sz>w do
      table.insert(ct,{})
      for k in pairs(ct[line]) do if k>w then ct[line+1][k-w]=ct[line][k] ct[line][k]=nil end end
      local s
      tbl[line],s = tbl[line]:sub(1,w),tbl[line]:sub(w+1,sz)
      line=line+1 table.insert(tbl,line,s) sz=sz-w
    end
    line=line+1
  end
  return tbl,ct,smax
end

local function CreateMonoTbl(tbl,width,Flags)
  local line,ct,smax,mono = 1,{},0
  if Flags:find("m") then mono=true end
  while line<=#tbl do
    table.insert(ct,{})
    if mono then tbl[line]=tbl[line]:gsub(pat,"") end
    local sz=tbl[line]:len()
    local w=width-4
    if sz>=w then smax=w elseif smax<sz then smax=sz end
    while sz>w do
      table.insert(ct,{})
      local s
      tbl[line],s = tbl[line]:sub(1,w),tbl[line]:sub(w+1,sz)
      line=line+1 table.insert(tbl,line,s) sz=sz-w
    end
    line=line+1
  end
  return tbl,ct,smax
end

local function CreateButtons(line,Buttons)
  local butnum,butdef,butlen,tButtons = 0,0,0,{}
  if Buttons=="" then return butdef,butlen end
  local bFlags=F.DIF_CENTERGROUP
  for def,button in Buttons:gmatch("(!?)([^;]+)") do
    butnum=butnum+1
    if def=="!" then butdef=butnum end
    table.insert(tButtons,{F.DI_BUTTON,0,line,0,0,0,0,0,bFlags,button})
    butlen=butlen+button:gsub("&",""):len()+4
  end
  if butdef==0 then butdef=1 end
  tButtons[butdef][9]=bFlags+F.DIF_DEFAULTBUTTON
  return butdef,butlen+butnum-1,tButtons
end

local function CreateItem(tbl,width,height,Flags,Buttons)
  local ct,smax
  if Flags:find("c")
  then tbl,ct,smax = CreateColorTbl(tbl,width)
  else tbl,ct,smax = CreateMonoTbl(tbl,width,Flags)
  end
  local tbllen=#tbl

  -- Buttons processing
  local line=tbllen+4>height and height-2 or tbllen+2
  local butdef,butlen,tButtons = CreateButtons(line,Buttons)

  local X2=smax>butlen and smax+4 or butlen+4
  local Y2=tbllen+(tButtons and 4 or 2)
  if Y2>height then Y2,tbllen = height,(tButtons and height-4 or height-2) end

  local buffer=far.CreateUserControl(X2-4,tbllen)
  local cFlags=bit64.bor(F.FCF_FG_4BIT,F.FCF_BG_4BIT)
  local elem=Flags:find("w") and K.COL_WARNDIALOGTEXT or K.COL_DIALOGTEXT
  local leftAlign=Flags:find("l")
  local tFarColor=far.AdvControl(F.ACTL_GETCOLOR,elem)
  local fg_dlg=bit64.band(tFarColor.ForegroundColor,0xF)
  local bg_dlg=bit64.band(tFarColor.BackgroundColor,0xF)
  local fg,bg,ptr = fg_dlg,bg_dlg,1
  for y=1,tbllen do
    local half
    if not leftAlign then
      half=math.floor((X2-4-tbl[y]:len())/2)
      if half>0 then
        tbl[y]=(" "):rep(half)..tbl[y]
        for x=X2-4,1,-1 do if ct[y][x] then ct[y][x+half]=ct[y][x] ct[y][x]=nil end end
      end
    end
    for x=1,X2-4 do
      local char=tbl[y]:sub(x,x) or " "
      fg = ct[y][x] and (ct[y][x].fg and ct[y][x].fg or fg_dlg) or fg
      bg = ct[y][x] and (ct[y][x].bg and ct[y][x].bg or bg_dlg) or bg
      buffer[ptr]={Char=char,Attributes={Flags=cFlags,ForegroundColor=fg,BackgroundColor=bg}}
      ptr=ptr+1
    end
  end
  return tButtons,butdef,X2,Y2,{F.DI_USERCONTROL,2,1,X2-3,tbllen,buffer,0,0,F.DIF_NOFOCUS,""}
end

local function MessageX(Msg,Title,Buttons,Flags,HelpTopic,Guid)
  -- Protection against incorrect arguments
  if not Msg or Msg==""
  then return
  else Title,Buttons,Flags,HelpTopic,Guid = Title or "",Buttons or "",Flags or "",HelpTopic or "",Guid or ""
  end

  -- Window size
  local width,height
  local w=far.AdvControl(F.ACTL_GETFARRECT)
  if w then width,height = w.Right+1,w.Bottom+1 end

  -- Line processing
  local tbl={}
  for line in Msg:gmatch("([^\r\n]*)\r?\n") do table.insert(tbl,line) end
  table.insert(tbl,Msg:match("[^\r\n]+$"))

  -- Message Creation
  local tButtons,butdef,X2,Y2,item = CreateItem(tbl,width,height,Flags,Buttons)

  -- Frame Creation
  local Items={{F.DI_DOUBLEBOX,0,0,X2,Y2,0,0,0,0,Title or ""}}
  -- Message Insertion
  table.insert(Items,item)
  -- Button Creation
  if tButtons then
    table.insert(Items,{F.DI_TEXT,0,Y2-3,0,0,0,0,0,F.DIF_SEPARATOR,""})
    for i=1,#tButtons do table.insert(Items,tButtons[i]) end
  end

  -- Dialogue processing
  local DlgProc=function(hDlg,Msg,Param1,Param2)
    if Msg==F.DN_INITDIALOG then if butdef~=0 then hDlg:send(F.DM_SETFOCUS,butdef+3,0) end end
  end

  -- Flags processing
  local DlgFlags=F.FDLG_SMALLDIALOG
  if Flags:find("w") then DlgFlags=DlgFlags+F.FMSG_WARNING end

  -- Show dialogue
  local result=far.Dialog(Guid,-1,-1,X2,Y2,HelpTopic,Items,DlgFlags,DlgProc)
  return result<0 and result or result-3
end

return MessageX