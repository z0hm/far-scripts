-- FarUpdate.lua
-- v1.7.9
-- Opening changelog and updating Far Manager to any version available on the site
-- ![changelog](http://i.piccy.info/i9/ff857187ff978fdbe845befda7fbfa4e/1592909758/25212/1384833/2020_06_23_134723.png)
-- Far: press **[ Reload Last ]** to reload the list with files
-- GitHub: press **[ More >> ]** to get more files
-- GitHub: press **[ Reload Last ]** to reload last page with files
-- GitHub: press **[ Reload All ]** to reload all pages
-- When you run the macro again, the build will be taken from the current position in Far.changelog
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
 --[[05]] {F.DI_COMBOBOX,     2,2, 29,2,{}, 0,0, F.DIF_DROPDOWNLIST, ""},
 --[[06]] {F.DI_TEXT,         0,3,  0,0, 0, 0,0, F.DIF_SEPARATOR,""},
 --[[07]] {F.DI_CHECKBOX,     8,3,  0,3, 0, 0,0, 0,"&Profile BackUp"},
 --[[08]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_DEFAULTBUTTON+F.DIF_CENTERGROUP,"&Update"},
 --[[09]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_CENTERGROUP,"&Yes"},
 --[[10]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_CENTERGROUP,"&No"}
}
local tmp=win.GetEnv("TEMP").."\\"
local farhome=win.GetEnv("FARHOME")
local farprofile=win.GetEnv("FARPROFILE")
local fp7z=farprofile..'.7z'
local x64=win.IsProcess64bit()
local pages,FileName = {}
local GitItemsPerPage,ListActions = 20,{"*  [ More >> ]","*  [ Reload Last ]","*  [ Reload All ]"}
local RealPos,FileList = 1,{}
local box={true,x64,true,false} -- [ Far ]   [ x64 ]   [ 7z  ]   [ ] Profile BackUp
local EGI,StringText,build
local WaitCloseFar='nircmd.exe waitprocess "'..farhome..'\\Far.exe"'
local ProfileBackUp='\n7z.exe a -aoa -xr!CrashLogs "'..fp7z..'" "'..farprofile..'" > '..tmp..'FarProfileBackUp.log'
local StartFar=function() return '\nstart "" "'..farhome..'\\ConEmu'..(box[2] and '64' or '')..'.exe"\nexit' end
local FarProfileBackUpBat=tmp..'FarProfileBackUp.bat'
local FarUpdateBat=tmp..'FarUpdate.bat'

-- Create FarUpdate.bat
local FarUpdate=function(FileName)
  local s=WaitCloseFar
  if box[4] then win.MoveFile(fp7z,fp7z..'_','r') s=s..ProfileBackUp end
  s=s..'\n7z.exe x -aoa -o"'..farhome..'" -x!PluginSDK -xr@"'..tmp..'FarUpdExc.txt" "'..tmp..FileName..'" > '..tmp..'FarUpdate.log'..StartFar()
  fwrite(FarUpdateBat,s)
  local l='*Spa.lng\n*Sky.lng\n*Sky.hlf\n*Ger.lng\n*Ger.hlf\n*Hun.lng\n*Hun.hlf\n*Ita.lng\n*Pol.lng\n*Pol.hlf\n*.pol.*\n*Cze.lng\n*Cze.hlf\n*Ukr.lng\n*Ukr.hlf\n*Bel.lng\n*Bel.hlf\n*.bel.*\n*Lit.lng'
  if not string.find(FileName,'%.pdb%.[^%.]+$') then l=l..'\n*.map\n*.pdb' end
  fwrite(tmp..'FarUpdExc.txt',l)
end

local GetFileList=function(page,items)
  local brk
  if not page then page=box[1] and 0 or 1 end
  for _,v in pairs(pages) do if page==v then brk=true break end end
  if not brk then
    if page==0 then
      local urlh='https://farmanager.com/nightly'
      local text=GetPage(urlh..'.php')
      -- nightly%/(Far30b%d-)%.x86%.(%d%d%d%d)(%d%d)(%d%d)%.7z
      for fname,build,xx,year,month,day,ext in text:gmatch('"nightly%/(Far30b(%d-)%.(x%d%d)%.(%d%d%d%d)(%d%d)(%d%d)%.([^"]-))"') do
        table.insert(FileList,{build..xx..' '..year..'-'..month..'-'..day..' '..ext,urlh..'/'..fname,0,fname})
      end
      table.insert(pages,0)
    else
      items=items or GitItemsPerPage
      local text=GetPage('--get "https://api.github.com/repos/FarGroup/FarManager/releases" --data "page='..page..'&per_page='..items..'"')
      -- /Far.x64.3.0.5523.1332.0e89356681209509d3db8c5dcfbe6a82194d14a4.pdb.7z
      local patt='%},(%c%c-[^%}%{]-"browser_download_url" ?: ?"(http[^"]-)"[^%}%{]-)%}'
      for txt,url in text:gmatch(patt) do
        local size=txt:match('"size" ?: ?(%d+)')
        if size then size=math.floor(tonumber(size)/100000+1)/10 size=' '..tostring(size)..'MB' else size='' end
        -- 2019-12-10T18:59:06Z
        local date=txt:match('"updated_at" ?: ?"([^"]-)"') or txt:match('"created_at" ?: ?"([^"]-)"')
        if date then date=' '..date:gsub("T"," "):gsub("Z","") else date='' end
        local fname,xx,build,ext = url:match('%/(Far%.(x%d%d)%.3%.0%.(%d-)%.%d-%.[0-9a-f]-%.([^%/]+))$')
        table.insert(FileList,{build..xx..date..' '..ext..size,url,page,fname})
      end
      table.insert(pages,page)
    end
  end
end

local ListT,PosProtect = {}
local DlgProc=function(hDlg,Msg,Param1,Param2)
  local function BoxUpdate()
    hDlg:send(F.DM_SETTEXT,2,box[1] and '[ &1 Far ]' or '[ &1 Git ]')
    hDlg:send(F.DM_SETTEXT,3,box[2] and '[ &2 x64 ]' or '[ &2 x86 ]')
    hDlg:send(F.DM_SETTEXT,4,box[3] and '[ &3 7z  ]' or '[ &3 msi ]')
  end
  local function RefreshList()
    local ListInfo=hDlg:send(F.DM_LISTINFO,5)
    local LastPos=ListInfo.ItemsNumber
    hDlg:send(F.DM_LISTDELETE,5,{StartIndex=1,Count=LastPos}) ListT={}
    for i=1,#FileList do
      if FileList[i][4]:find('^Far'..(box[1] and '30b%d-%.' or '%.')..(box[2] and 'x64' or 'x86')..'%..+%.'..(box[3] and '7z' or 'msi'))
      then hDlg:send(F.DM_LISTADD,5,{{Text=FileList[i][1]}}) table.insert(ListT,{FileList[i][1],FileList[i][3]})
      end
    end
    if box[1]
    then hDlg:send(F.DM_LISTADD,5,{{Text=ListActions[2]}}) table.insert(ListT,ListActions[2])
    else
      for i=1,#ListActions do
        hDlg:send(F.DM_LISTADD,5,{{Text=ListActions[i]}}) table.insert(ListT,ListActions[i])
      end
    end
    if build then
      local ans
      for i=1,#ListT do
        if type(ListT[i])=="table" then ans=ListT[i][1]:find("^"..build) end
        if ans then RealPos=PosProtect and RealPos or i PosProtect=false break end
      end
    end
    hDlg:send(F.DM_LISTSETCURPOS,5,{SelectPos=RealPos})
    FileName=tostring(hDlg:send(F.DM_GETTEXT,5))
    hDlg:send(F.DM_SETFOCUS,5)
  end
  local function RemoveListActions(pos)
    for i=pos,pos-#ListActions-1,-1 do
      local FarListItem=hDlg:send(F.DM_LISTGETITEM,5,i)
      if FarListItem and FarListItem.Text:sub(1,1)=="*" then
        hDlg:send(F.DM_LISTDELETE,5,{StartIndex=i,Count=1})
        table.remove(ListT,i)
      else break
      end
    end
  end
  if Msg==F.DN_INITDIALOG then
    BoxUpdate()
    RefreshList()
    hDlg:send(F.DM_SETCHECK,7,box[4] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
  elseif (Msg==F.DN_EDITCHANGE or Msg==F.DN_LISTCHANGE) and Param1==5 then
    local ListInfo=hDlg:send(F.DM_LISTINFO,5)
    local LastPos=ListInfo.ItemsNumber
    local SelectPos=ListInfo.SelectPos
    local str=tostring(hDlg:send(F.DM_GETTEXT,5))
    RealPos=SelectPos==0 and RealPos or SelectPos
    if Msg==F.DN_EDITCHANGE and str and str:sub(1,1)=="*"
    then
      if str==ListActions[1] then
        RemoveListActions(LastPos)
        GetFileList(FileList[#FileList][3]+1)
        PosProtect=true
      elseif str==ListActions[2] then
        RemoveListActions(LastPos)
        local page=FileList[#FileList][3]
        table.remove(pages)
        for i=#FileList,1,-1 do if FileList[i][3]==page then table.remove(FileList,i) else break end end
        GetFileList(page)
        local p=ListT[#ListT][2]
        for i=#ListT,1,-1 do if ListT[i][2]==p then table.remove(ListT,i) else RealPos=i+1 PosProtect=true break end end
      elseif str==ListActions[3] then
        RemoveListActions(LastPos)
        local p={} for i=1,#pages do p[i]=pages[i] end
        pages={} FileList={}
        for i=1,#p do GetFileList(p[i]) end
        RealPos=1
      end
      RefreshList()
    else FileName=str
    end
  elseif Msg==F.DN_BTNCLICK and Param1>=2 and Param1<=4 then   -- [ Far ]  [ x86 ]  [ 7z  ]
    box[Param1-1]=not box[Param1-1]
    BoxUpdate()
    local ListInfo=hDlg:send(F.DM_LISTINFO,5)
    local LastPos=ListInfo.ItemsNumber
    local str=tostring(hDlg:send(F.DM_GETTEXT,5))
    build=str:match("^%d+")
    RemoveListActions(LastPos)
    if Param1==2 then GetFileList() end
    RealPos=1
    RefreshList()
  elseif Msg==F.DN_BTNCLICK and Param1==7 then   -- [ ] Profile BackUp
    box[4]=not box[4]
  end
end

Macro {
area="Common"; flags=""; description="! FarUpdate";
action=function()
  local changelog="Far.changelog"
  local f=tmp..changelog
  if #FileList==0 then
    --fwrite(f,GetPage('-L https://github.com/FarGroup/FarManager/raw/master/far/changelog'))
    fwrite(f,GetPage('https://raw.githubusercontent.com/FarGroup/FarManager/master/far/changelog'))
    GetFileList(0)
  end
  editor.Editor(f,nil,0,0,-1,-1,bit64.bor(F.EF_NONMODAL,F.EF_IMMEDIATERETURN,F.EF_OPENMODE_USEEXISTING),1,1,nil)
  EGI=editor.GetInfo()
  if EGI then
    local FileName=EGI.FileName
    if FileName then
      FileName=FileName:match("[^%\\]+$")
      if FileName==changelog then
        for CurLine=EGI.CurLine,1,-1 do
          StringText=editor.GetString(EGI.EditorID,CurLine).StringText
          if StringText then build=StringText:match(' build (%d+)%s*$') end
          if build then break end
        end
      end
    end
  end
  local w=far.AdvControl(F.ACTL_GETFARRECT)
  local res=far.Dialog(uGuid,w.Right-items[1][4]-2,w.Bottom-w.Top-7,w.Right-2,w.Bottom-w.Top-2,nil,items,F.FDLG_SMALLDIALOG,DlgProc)
  if res==#items-2 or res==#items-1 then
    if FileName then
      local url
      for _,v in pairs(FileList) do if v[1]==FileName then url,FileName = v[2],v[4] break end end
      if not win.GetFileInfo(tmp..FileName) or far.Message("Download it again?","WARNING! File exist",";YesNo","w")==1
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