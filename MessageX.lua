-- MessageX.lua
-- v0.6.7.8
-- Color **MessageX(Msg,Title,Buttons,Flags,HelpTopic,Guid,ExecDelay)** module with support default button assignments
-- ![MessageX Dialog](http://i.piccy.info/i9/f5defa4d150c234d882858e3a73978f5/1589987690/2336/1379306/2020_05_20_180740.png)
-- Support delay execution in seconds (**ExecDelay**:integer)
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
--   MessageX("aaa <#e2>bbb<#s1>\nccc<#bs> ddd\neee<#9s> fff <#sr> ggg <#ec>hhh","MessageX","&Ok;!Ca&ncel","wc","","",11)
-- ```

local F=far.Flags
local K=far.Colors

local band64,bor64 = bit64.band,bit64.bor
local string_find,string_gsub,string_lower,string_rep = string.find,string.gsub,string.lower,string.rep
local math_floor,math_log,math_max = math.floor,math.log,math.max
local far_AdvControl,far_CreateUserControl,far_Dialog,far_SendDlgMessage,far_Show,far_Timer = far.AdvControl,far.CreateUserControl,far.Dialog,far.SendDlgMessage,far.Show,far.Timer
local table_insert = table.insert
local regex_new = regex.new

local pat=regex_new"<#([0-9A-FRSa-frs])([0-9A-FRSa-frs])>"
local patlen=5
-- if available flag "c"
local function CreateColorTbl(tbl,width)
  local ct,line,smax,fg,bg = {},1,0
  while line<=#tbl do
    table_insert(ct,{})
    local len,to,from,_fg,_bg = 0,0
    repeat
      from,to,_fg,_bg = pat:find(tbl[line],to+1)
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
    tbl[line]=pat:gsub(tbl[line],"")
    local sz=tbl[line]:len()
    local w=width-4
    if sz>=w then smax=w elseif smax<sz then smax=sz end
    while sz>w do
      table_insert(ct,{})
      for k in pairs(ct[line]) do if k>w then ct[line+1][k-w]=ct[line][k] ct[line][k]=nil end end
      local s
      tbl[line],s = tbl[line]:sub(1,w),tbl[line]:sub(w+1,sz)
      line=line+1 table_insert(tbl,line,s) sz=sz-w
    end
    line=line+1
  end
  return tbl,ct,smax
end

-- if available flag "m" or w/o him
local function CreateMonoTbl(tbl,width,Flags)
  local line,ct,smax,mono = 1,{},0
  if string_find(Flags,"m") then mono=true end
  while line<=#tbl do
    table_insert(ct,{})
    if mono then tbl[line]=pat:gsub(tbl[line],"") end
    local sz=tbl[line]:len()
    local w=width-4
    if sz>=w then smax=w elseif smax<sz then smax=sz end
    while sz>w do
      table_insert(ct,{})
      local s
      tbl[line],s = tbl[line]:sub(1,w),tbl[line]:sub(w+1,sz)
      line=line+1 table_insert(tbl,line,s) sz=sz-w
    end
    line=line+1
  end
  return tbl,ct,smax
end

-- if available Buttons
local pat1 = "(!?)([^;]+)"
local function CreateButtons(line,Buttons)
  local butnum,butdef,butlen,tButtons = 0,0,0,{}
  if Buttons=="" then return butdef,butlen end
  local bFlags=F.DIF_CENTERGROUP
  for def,button in Buttons:gmatch(pat1) do
    butnum=butnum+1
    if def=="!" then butdef=butnum end
    table_insert(tButtons,{F.DI_BUTTON,0,line,0,0,0,0,0,bFlags,button})
    butlen=butlen+button:gsub("&&"," "):gsub("&",""):len()+4
  end
  if butdef==0 then butdef=1 end
  tButtons[butdef][9]=bFlags+F.DIF_DEFAULTBUTTON
  return butdef,butlen+butnum-1,tButtons
end

local function CreateItem(tbl,width,height,Flags,Buttons,Title,ExecDelay)
  local tbllen,smax,ct = #tbl,0
  if tbllen>0 then
    if string_find(Flags,"c")
    then tbl,ct,smax = CreateColorTbl(tbl,width)
    else tbl,ct,smax = CreateMonoTbl(tbl,width,Flags)
    end
    tbllen=#tbl
  end

  -- Buttons processing
  local line=tbllen+4>height and height-2 or (tbllen + (tbllen>0 and 2 or 1))
  local butdef,butlen,tButtons = CreateButtons(line,Buttons)

  local X2=math_max(smax+4,butlen+4,Title:len()+4+(ExecDelay and math_floor(math_log(ExecDelay,10)+3) or 0))
  local Y2=2+tbllen -- add box and Msg
  if tButtons then Y2=Y2+1 -- add Buttons
    if tbllen>0 then Y2=Y2+1 end -- add separator
  end
  if Y2>height then Y2,tbllen = height,(tButtons and height-4 or height-2) end
  if tbllen==0 then return tButtons,butdef,X2,Y2 end -- No Msg

  local buffer=far_CreateUserControl(X2-4,tbllen)
  local cFlags=bor64(F.FCF_FG_4BIT,F.FCF_BG_4BIT)
  local elem=string_find(Flags,"w") and K.COL_WARNDIALOGTEXT or K.COL_DIALOGTEXT
  local leftAlign=string_find(Flags,"l")
  local tFarColor=far_AdvControl(F.ACTL_GETCOLOR,elem)
  local fg_dlg=band64(tFarColor.ForegroundColor,0xF)
  local bg_dlg=band64(tFarColor.BackgroundColor,0xF)
  local fg,bg,ptr = fg_dlg,bg_dlg,1
  for y=1,tbllen do
    if not leftAlign then
      local half=math_floor((X2-4-tbl[y]:len())/2)
      if half>0 then
        tbl[y]=string_rep(" ",half)..tbl[y]
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

local pat2,pat3,pat4 = "([^\r\n]*)\r?\n",regex_new"[^\r\n]+$"," :%d+$"
local function MessageX(Msg,Title,Buttons,Flags,HelpTopic,Guid,ExecDelay)
  -- Protection against incorrect arguments
  if ExecDelay and type(ExecDelay)=="number" then
    if ExecDelay>=1 then ExecDelay=math_floor(ExecDelay) else return end
  else ExecDelay=nil
  end
  Title,Buttons,Flags,HelpTopic,Guid = Title or "MessageX",Buttons or "",Flags or "",HelpTopic or "",Guid or ""
  Flags=string_lower(Flags)

  -- Check window size
  local width,height
  local w=far_AdvControl(F.ACTL_GETFARRECT)
  if w then width,height = w.Right+1,w.Bottom+1 end

  local MsgType=type(Msg)
  if MsgType~="string" then
    if MsgType=="table" then far_Show(unpack(Msg)) else far_Show(Msg) end
    exit()
  end
  if Msg:find"^[%s%c]+$" then
    local spc="\194\183"
    local tab="\26"
    Msg=Msg:gsub(" ",spc)
    Msg=Msg:gsub("\t",tab)
    Msg="<#1s>"..Msg.."<#rs>"
    Flags=string_find(Flags,"c") and Flags or Flags..'c'
  end

  -- Line processing
  local tbl={}
  if Msg and Msg~="" then
    for line in Msg:gmatch(pat2) do table_insert(tbl,line) end
    table_insert(tbl,pat3:match(Msg))
  end

  -- Message Creation
  local tButtons,butdef,X2,Y2,item = CreateItem(tbl,width,height,Flags,Buttons,Title,ExecDelay)

  -- Frame Creation
  local Items={{F.DI_DOUBLEBOX,0,0,X2,Y2,0,0,0,0,Title or ""}}
  -- Message Insertion
  if item then table_insert(Items,item) end

  -- Seperator Insertion
  if item and tButtons then table_insert(Items,{F.DI_TEXT,0,Y2-3,0,0,0,0,0,F.DIF_SEPARATOR,""}) end

  -- Button Creation
  if tButtons then for i=1,#tButtons do table_insert(Items,tButtons[i]) end end

  -- Dialogue processing
  local timer
  local shft=item and 3 or 1
  local butdefid=butdef+shft
  local DlgProc=function(hDlg,Msg,Param1,Param2)
    local function OnTimer()
      ExecDelay=ExecDelay-1
      if ExecDelay>0
      then far_SendDlgMessage(hDlg,F.DM_SETTEXT,1,string_gsub(far_SendDlgMessage(hDlg,F.DM_GETTEXT,1),pat4," :"..ExecDelay))
      else far_SendDlgMessage(hDlg,F.DM_CLOSE,far_SendDlgMessage(hDlg,F.DM_GETFOCUS))
      end
    end
    if Msg==F.DN_INITDIALOG then
      if butdef~=0 then far_SendDlgMessage(hDlg,F.DM_SETFOCUS,butdefid) end
      if ExecDelay then
        far_SendDlgMessage(hDlg,F.DM_SETTEXT,1,far_SendDlgMessage(hDlg,F.DM_GETTEXT,1).." :"..ExecDelay)
        timer=far_Timer(1000,OnTimer)
      end
    elseif timer and Msg==F.DN_GOTFOCUS and far_SendDlgMessage(hDlg,F.DM_GETFOCUS)~=butdefid then -- Param1 1st time return wrong id
      timer:Close() timer=nil
      far_SendDlgMessage(hDlg,F.DM_SETTEXT,1,string_gsub(far_SendDlgMessage(hDlg,F.DM_GETTEXT,1),pat4,""))
    end
  end

  -- Flags processing
  local DlgFlags=F.FDLG_SMALLDIALOG
  if string_find(Flags,"w") then DlgFlags=DlgFlags+F.FMSG_WARNING end

  -- Show dialogue
  local result=far_Dialog(Guid,-1,-1,X2,Y2,HelpTopic,Items,DlgFlags,DlgProc)
  if timer then timer:Close() timer=nil end
  return result<0 and result or result-shft
end

return MessageX