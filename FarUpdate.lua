-- FarUpdate.lua
-- v1.9.2
-- Opening changelog and updating Far Manager to any version available on the site
-- ![changelog](http://i.piccy.info/i9/ff857187ff978fdbe845befda7fbfa4e/1592909758/25212/1384833/2020_06_23_134723.png)
-- Far: press **[ Reload last ]** to reload the list with files
-- GitHub: press **[ More >> ]** to get more files
-- GitHub: press **[ Reload last ]** to reload last page with files
-- GitHub: press **[ Reload all ]** to reload all pages
-- GitHub: press **[ Goto build ]** to go to enter build number
-- When you run the macro again, the build will be taken from the current line in Far.changelog
-- Required: curl.exe, nircmd.exe, 7z.exe, requires tuning for local conditions
-- Keys: launch from Macro Browser alt.
-- Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=700#19

local function fwrite(f,s) local x,h = nil,io.open(f,"wb") if h then x=h:write(s or "") io.close(h) end return x end
local function GetPage(x) panel.GetUserScreen() local s="" if x then s=io.popen('curl.exe '..x,'rb'):read('*all') end panel.SetUserScreen() return s end

local F=far.Flags
local guid="0EEE33E2-1E95-4753-982C-B2BD1E63C3C4"
local uGuid=win.Uuid(guid)
-- 32 13 23 -- 44 19 35
local items={
 --[[01]] {F.DI_DOUBLEBOX,    0,0, 32,6, 0, 0,0, 0, "Download file?"},
 --[[02]] {F.DI_BUTTON,       2,1,  0,1, 0, 0,0, F.DIF_BTNNOCLOSE, "[ &1 Far ]"},
 --[[03]] {F.DI_BUTTON,      12,1,  0,1, 0, 0,0, F.DIF_BTNNOCLOSE, "[ &2 x86 ]"},
 --[[04]] {F.DI_BUTTON,      22,1,  0,1, 0, 0,0, F.DIF_BTNNOCLOSE, "[ &3 7z  ]"},
 --[[05]] {F.DI_TEXT,         1,2,  1,2, 0, 0,0, 0, " "},
 --[[06]] {F.DI_COMBOBOX,     2,2, 30,2,{}, 0,0, F.DIF_DROPDOWNLIST, ""},
 --[[07]] {F.DI_TEXT,         0,3,  0,0, 0, 0,0, F.DIF_SEPARATOR, ""},
 --[[08]] {F.DI_CHECKBOX,     8,3,  0,3, 0, 0,0, 0,"&Profile BackUp"},
 --[[09]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_DEFAULTBUTTON+F.DIF_CENTERGROUP, "&Update"},
 --[[10]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_CENTERGROUP, "&Yes"},
 --[[11]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_CENTERGROUP, "&No"}
}
local mark=string.char(24) -- 
local tmp=win.GetEnv("TEMP").."\\"
local farhome=win.GetEnv("FARHOME")
local farprofile=win.GetEnv("FARPROFILE")
local fp7z=farprofile..'.7z'
local x64=win.IsProcess64bit()
local pages,FileName = {}
local GitItemsPerPage,ListActions = 100,{"*  [ More >> ]","*  [ Reload last ]","*  [ Reload all ]","*  [ Goto build ]"}
local RealPos,FileList = 1,{}
local box={true,x64,1,false} -- [ Far ]   [ x64 ]   [ 1=7z 2=msi 3=pdb.7z ]   [ ] Profile BackUp
local EGI,StringText,build,xbuild,XD,YD
local WaitCloseFar='nircmd.exe waitprocess "'..farhome..'\\Far.exe"'
local ProfileBackUp='\n7z.exe a -aoa -xr!CrashLogs "'..fp7z..'" "'..farprofile..'" > '..tmp..'FarProfileBackUp.log'
local ConEmu=farhome..'\\ConEmu'..(box[2] and '64' or '')..'.exe'
local FarLnk=farhome..'\\Far.lnk'
local FarExe=farhome..'\\Far.exe'
local StartFar=function() return '\nstart "" "'..(win.GetFileAttr(ConEmu) and  ConEmu or (win.GetFileAttr(FarLnk) and FarLnk or FarExe))..'"' end
local FarProfileBackUpBat=tmp..'FarProfileBackUp.bat'
local FarUpdateBat=tmp..'FarUpdate.bat'

XItems={
         {F.DI_DOUBLEBOX, 0,0,17,2,0,       0,0,       0,  "Goto"},
         {F.DI_TEXT,      2,1, 7,1,0,       0,0,       0,"build:"},
         {F.DI_EDIT,      9,1,15,1,0,       0,0,       0,      ""}
       }

local function XDlgProc(hDlg,Msg,Param1,Param2)
  if Msg==F.DN_INITDIALOG then hDlg:send(F.DM_SETTEXT,3,tostring(build or ""))
  elseif Msg==F.DN_CLOSE and Param1==3 then xbuild=tonumber(tostring(hDlg:send(F.DM_GETTEXT,Param1)):match("%d+"))
  end
end

-- Create FarUpdate.bat
local function FarUpdate(FileName)
  local s,u = '',not string.find(FileName,'%.pdb%.[^%.]+$')
  if u then
    s=s..WaitCloseFar
    if box[4] then win.MoveFile(fp7z,fp7z..'_','r') s=s..ProfileBackUp end
  end
  s=s..'\n7z.exe x -aoa -o"'..farhome..'" -x!PluginSDK -xr@"'..tmp..'FarUpdExc.txt" "'..tmp..FileName..'" > '..tmp..'FarUpdate.log'
  if u then s=s..StartFar() end
  fwrite(FarUpdateBat,s..'\nexit')
  s='*Spa.lng\n*Sky.lng\n*Sky.hlf\n*Ger.lng\n*Ger.hlf\n*Hun.lng\n*Hun.hlf\n*Ita.lng\n*Pol.lng\n*Pol.hlf\n*.pol.*\n*Cze.lng\n*Cze.hlf\n*Ukr.lng\n*Ukr.hlf\n*Bel.lng\n*Bel.hlf\n*.bel.*\n*Lit.lng'
  if u then s=s..'\n*.map\n*.pdb' end
  fwrite(tmp..'FarUpdExc.txt',s)
end

local function FLFAR()
  local urlh='https://farmanager.com/nightly'
  local text=GetPage(urlh..'.php')
  -- fwrite(tmp..'nightly.php',text)
  -- nightly%/(Far30b%d-)%.x86%.(%d%d%d%d)(%d%d)(%d%d)%.7z
  for fname,build,xx,year,month,day,ext in text:gmatch('"nightly%/(Far30b(%d-)%.(x%d%d)%.(%d%d%d%d)(%d%d)(%d%d)%.(%w+)[^"]-)"') do
    if ext then table.insert(FileList,{build..xx..' '..year..'-'..month..'-'..day..' '..ext,urlh..'/'..fname,0,fname}) end
  end
end

local function FLGIT(page,items)
  items=items or GitItemsPerPage
  local text=GetPage('--get "https://api.github.com/repos/FarGroup/FarManager/releases" --data "page='..page..'&per_page='..items..'"')
  --fwrite(tmp..'nightly.php',text)
  -- /Far.x64.3.0.5523.1332.0e89356681209509d3db8c5dcfbe6a82194d14a4.pdb.7z
  local patt='%},(%c%c-[^%}%{]-"browser_download_url" ?: ?"(http[^"]-)"[^%}%{]-)%}'
  for txt,url in text:gmatch(patt) do
    local size=txt:match('"size" ?: ?(%d+)')
    if size then size=math.floor(tonumber(size)/100000+1)/10 size=' '..tostring(size)..'MB' else size='' end
    -- 2019-12-10T18:59:06Z
    local date=txt:match('"updated_at" ?: ?"([^"]-)"') or txt:match('"created_at" ?: ?"([^"]-)"')
    if date then date=' '..date:gsub("T"," "):gsub("Z","") else date='' end
    local fname,xx,build,ext = url:match('%/(Far%.(x%d%d)%.3%.0%.(%d-)%.%d-%.[0-9a-f]-%.(%w+).-)$')
    if ext then table.insert(FileList,{build..xx..date..' '..ext..size,url,page,fname}) end
  end
end

local function GetFileList(page,items)
  local brk
  if not page then page=box[1] and 0 or 1 end
  for _,v in pairs(pages) do if page==v then brk=true break end end
  if not brk then
    if page==0
    then FLFAR() if #FileList==0 then page=1 FLGIT(page,items) end
    else FLGIT(page,items) if #FileList==0 then page=0 FLFAR() end
    end
    table.insert(pages,page)
  end
end

local ListT,PosProtect = {}
local function DlgProc(hDlg,Msg,Param1,Param2)
  local function BoxUpdate()
    hDlg:send(F.DM_SETTEXT,2,box[1] and '[ &1 Far ]' or '[ &1 Git ]')
    hDlg:send(F.DM_SETTEXT,3,box[2] and '[ &2 x64 ]' or '[ &2 x86 ]')
    hDlg:send(F.DM_SETTEXT,4,box[3]==1 and '[ &3 7z  ]' or (box[3]==2 and '[ &3 msi ]' or '[ &3 pdb ]'))
  end
  local function RefreshList()
    local ListInfo=hDlg:send(F.DM_LISTINFO,6)
    local LastPos=ListInfo.ItemsNumber
    hDlg:send(F.DM_LISTDELETE,6,{StartIndex=1,Count=LastPos}) ListT={}
    for i=1,#FileList do
      if FileList[i][4]:find('^Far'..(box[1] and '30b%d-%.' or '%.')..(box[2] and 'x64' or 'x86')..'%..+'..(box[3]==1 and '[^%.]...%.7z' or (box[3]==2 and '%.msi' or '%.pdb%.7z')))
      then hDlg:send(F.DM_LISTADD,6,{{Text=FileList[i][1]}}) table.insert(ListT,{FileList[i][1],FileList[i][3]})
      end
    end
    if box[1]
    then hDlg:send(F.DM_LISTADD,6,{{Text=ListActions[2]}}) table.insert(ListT,ListActions[2])
    else
      for i=1,#ListActions do
        hDlg:send(F.DM_LISTADD,6,{{Text=ListActions[i]}}) table.insert(ListT,ListActions[i])
      end
    end
    if build then
      local ans
      for i=1,#ListT do
        if type(ListT[i])=="table" then ans=ListT[i][1]:find("^"..build) end
        if ans then RealPos=PosProtect and RealPos or i PosProtect=false break end
      end
    end
    hDlg:send(F.DM_LISTSETCURPOS,6,{SelectPos=RealPos})
    FileName=tostring(hDlg:send(F.DM_GETTEXT,6))
    hDlg:send(F.DM_SETFOCUS,6)
  end
  local function RemoveListActions(pos)
    for i=pos,pos-#ListActions-1,-1 do
      local FarListItem=hDlg:send(F.DM_LISTGETITEM,6,i)
      if FarListItem and FarListItem.Text:sub(1,1)=="*" then
        hDlg:send(F.DM_LISTDELETE,6,{StartIndex=i,Count=1})
        table.remove(ListT,i)
      else break
      end
    end
  end
  if Msg==F.DN_INITDIALOG then
    BoxUpdate()
    RefreshList()
    hDlg:send(F.DM_SETTEXT,5,RealPos>1 and mark or ' ')
    hDlg:send(F.DM_SETCHECK,8,box[4] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
  elseif (Msg==F.DN_EDITCHANGE or Msg==F.DN_LISTCHANGE) and Param1==6 then
    local ListInfo=hDlg:send(F.DM_LISTINFO,6)
    local LastPos=ListInfo.ItemsNumber
    local SelectPos=ListInfo.SelectPos
    local str=tostring(hDlg:send(F.DM_GETTEXT,6))
    RealPos=SelectPos==0 and RealPos or SelectPos
    if Msg==F.DN_EDITCHANGE and str and str:sub(1,1)=="*"
    then
      if str==ListActions[1] and FileList[#FileList] then
        RemoveListActions(LastPos)
        GetFileList(FileList[#FileList][3]+1)
        PosProtect=true
      elseif str==ListActions[2] and FileList[#FileList] then
        RemoveListActions(LastPos)
        if #ListT>0 then
          local page=FileList[#FileList][3]
          table.remove(pages)
          for i=#FileList,1,-1 do if FileList[i][3]==page then table.remove(FileList,i) else break end end
          GetFileList(page)
          local p=ListT[#ListT][2]
          for i=#ListT,1,-1 do if ListT[i][2]==p then table.remove(ListT,i) else RealPos=i+1 PosProtect=true break end end
        end
      elseif str==ListActions[3] then
        RemoveListActions(LastPos)
        local p={} for i=1,#pages do p[i]=pages[i] end
        pages={} FileList={}
        for i=1,#p do GetFileList(p[i]) end
        RealPos=1
      elseif str==ListActions[4] and FileList[#FileList] then
        RemoveListActions(LastPos)
        far.Dialog("",XD+7,YD+1,XD+7+XItems[1][4],YD+3,nil,XItems,F.FDLG_SMALLDIALOG+F.FDLG_WARNING,XDlgProc)
        build=xbuild or build
        if build and #FileList>0 and build<=tonumber(FileList[1][1]:match("^(%d+)")) then
          while build<tonumber(FileList[#FileList][1]:match("^(%d+)")) do GetFileList(FileList[#FileList][3]+1) end
          PosProtect=false
        end
      end
      RefreshList()
    else FileName=str
    end
    hDlg:send(F.DM_SETTEXT,5,RealPos>1 and mark or ' ')
  elseif Msg==F.DN_BTNCLICK and Param1>=2 and Param1<=4 then   -- [ Far ]  [ x86 ]  [ 7z  ]
    local p=Param1-1
    box[p]=p==3 and (box[p]==3 and 1 or box[p]+1) or not box[p]
    BoxUpdate()
    local ListInfo=hDlg:send(F.DM_LISTINFO,6)
    local LastPos=ListInfo.ItemsNumber
    local str=tostring(hDlg:send(F.DM_GETTEXT,6))
    build=tonumber(str:match("^%d+"))
    RemoveListActions(LastPos)
    if Param1==2 then GetFileList() end
    RealPos=1
    RefreshList()
  elseif Msg==F.DN_BTNCLICK and Param1==8 then   -- [ ] Profile BackUp
    box[4]=not box[4]
  end
end

Macro {
area="Common"; flags=""; description="! FarUpdate";
action=function()
  local changelog="Far.changelog"
  local f=tmp..changelog
  --fwrite(f,GetPage('-L https://github.com/FarGroup/FarManager/raw/master/far/changelog'))
  fwrite(f,GetPage('https://raw.githubusercontent.com/FarGroup/FarManager/master/far/changelog'))
  repeat
    GetFileList()
    if #FileList>0 then break end
  until far.Message("Servers don't answer\n\nTry again?","WARNING!",";YesNo","w")~=1
  if #FileList==0 then return end
  editor.Editor(f,nil,0,0,-1,-1,bit64.bor(F.EF_NONMODAL,F.EF_IMMEDIATERETURN,F.EF_OPENMODE_USEEXISTING),1,1,nil)
  EGI=editor.GetInfo()
  if EGI then
    local FileName=EGI.FileName
    if FileName then
      FileName=FileName:match("[^%\\]+$")
      if FileName==changelog then
        for CurLine=EGI.CurLine,1,-1 do
          StringText=editor.GetString(EGI.EditorID,CurLine).StringText
          if StringText then build=tonumber(StringText:match(' build (%d+)%s*$')) end
          if build then break end
        end
      end
    end
  end
  local w=far.AdvControl(F.ACTL_GETFARRECT)
  XD,YD = w.Right-items[1][4]-2,w.Bottom-w.Top-7
  local res=far.Dialog(uGuid,XD,YD,w.Right-2,w.Bottom-w.Top-2,nil,items,F.FDLG_SMALLDIALOG,DlgProc)
  if res==#items-2 or res==#items-1 then
    if FileName and #FileList>0 then
      local url
      for _,v in pairs(FileList) do if v[1]==FileName then url,FileName = v[2],v[4] break end end
      if url and (not win.GetFileInfo(tmp..FileName) or far.Message("Download it again?","WARNING! File exist",";YesNo","w")==1)
      then panel.GetUserScreen() win.system('curl.exe -g -L --location-trusted "'..url..'" -o "'..tmp..FileName..'"') panel.SetUserScreen()
      end
      if res==#items-2 then
        FarUpdate(FileName)
        panel.GetUserScreen() win.system('start /MIN '..FarUpdateBat) panel.SetUserScreen()
      end
    end
  end
end;
}

-- FarProfileBackUp.lua 1.0.2
Macro {
area="Common"; flags=""; description="! FarProfileBackUp";
action=function()
  win.MoveFile(fp7z,fp7z..'_','r')
  fwrite(FarProfileBackUpBat,WaitCloseFar..ProfileBackUp..StartFar())
  panel.GetUserScreen() win.system('start /MIN '..FarProfileBackUpBat) panel.SetUserScreen()
end;
}