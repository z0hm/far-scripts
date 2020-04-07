-- FarUpdate.lua
-- v1.7.1
-- Opening changelog and updating Far Manager to any version available on the site
-- ![changelog](http://i.piccy.info/i9/853d060868f60a97875406b017505b28/1586274980/29703/1371677/2020_04_07_182023.png)
-- ![update dialog](http://i.piccy.info/i9/2926dae366e86ea1eacadc3a55508f5d/1585846888/29457/1370793/2020_04_02_195019.png)
-- Far: press [ Reload Last ] to reload the list with files
-- GitHub: press [ More >> ] to get more files
-- GitHub: press [ Reload Last ] to reload last page with files
-- GitHub: press [ Reload All ] to reload all pages
-- When you run the macro again, the build will be taken from the current position in Far.changelog
-- Required: curl.exe, nircmd.exe, 7z.exe, requires tuning for local conditions
-- Keys: launch from Macro Browser alt.
-- Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=700#19

local function fwrite(s,f) local x,h = nil,io.open(f,"wb") if h then x=h:write(s or "") io.close(h) end return x end
local function GetPage(x) panel.GetUserScreen() local s="" if x then s=io.popen('curl.exe -k '..x,'rb'):read('*all') end panel.SetUserScreen() return s end

local F=far.Flags
local guid="0EEE33E2-1E95-4753-982C-B2BD1E63C3C4"
local uGuid=win.Uuid(guid)
-- 32 13 23 -- 44 19 35
local items={
 --[[01]] {F.DI_DOUBLEBOX,    0,0, 32,6, 0, 0,0, 0, "Download file?"},
 --[[02]] {F.DI_BUTTON,       3,1,  0,1, 0, 0,0, F.DIF_BTNNOCLOSE, "[ Far ]"},
 --[[03]] {F.DI_BUTTON,      13,1,  0,1, 0, 0,0, F.DIF_BTNNOCLOSE, "[ x86 ]"},
 --[[04]] {F.DI_BUTTON,      23,1,  0,1, 0, 0,0, F.DIF_BTNNOCLOSE, "[ 7z  ]"},
 --[[05]] {F.DI_COMBOBOX,     2,2, 29,2,{}, 0,0, F.DIF_DROPDOWNLIST, ""},
 --[[06]] {F.DI_TEXT,         0,3,  0,0, 0, 0,0, F.DIF_SEPARATOR,""},
 --[[07]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_DEFAULTBUTTON+F.DIF_CENTERGROUP,"&Update"},
 --[[08]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_CENTERGROUP,"&Yes"},
 --[[09]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_CENTERGROUP,"&No"}
}
local tmp=win.GetEnv("TEMP").."\\"
local farhome=win.GetEnv("FARHOME")
local x64=win.IsProcess64bit()
local FileList0,pages,FileName = 0,{}
local GitItemsPerPage,ListActions = 20,{"*  [ More >> ]","*  [ Reload Last ]","*  [ Reload All ]"}
local RealPos,FileList = 1,{}
local box={true,x64,true} -- [ Far ]   [ x64 ]   [ 7z  ]
local EGI,StringText,build

-- Create FarUpdate.bat
local FarUpdate=function(FileName)
  fwrite('*.map\n*spa.lng\n*sky.lng\n*Ger.lng\n*Hun.lng\n*Hun.hlf\n*Ita.lng\n*Pol.lng\n*Pol.hlf\n*.pol.*\n*Cze.lng\n*Ukr.lng\n*Ukr.hlf\n*Bel.lng\n*Bel.hlf\n*.bel.*',tmp..'FarUpdExc.txt')
  fwrite('nircmd.exe waitprocess "'..farhome..'\\Far.exe"\n7z.exe x -aoa -o"'..farhome..'" -x!PluginSDK -xr@"'..tmp..'FarUpdExc.txt" "'..tmp..FileName..'" > '..tmp..'FarUpdate.log'
  --..'\n7z.exe x -aoa -o"'..farhome..'\\Plugins\\NetBox" -x@"'..tmp..'FarUpdExc.txt" "H:\\Temp\\FarNetBox-2.4.5.531_Far3_x86.7z" > '..tmp..'FarUpdate.log'
  ..'\n7z.exe x -aoa -o"'..farhome..'\\Plugins\\FarColorer" -x@"'..tmp..'FarUpdExc.txt" "H:\\Temp\\FarColorer-1.2.9.1_Far3_x86.7z" > '..tmp..'FarUpdate.log'
  ..'\nstart "" "'..farhome..'\\ConEmu.exe"\nexit',tmp..'FarUpdate.bat')
end

local GetFileList=function(page,items)
  FileList0=#FileList
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
        -- 2019-12-10T18:59:06Z
        local date=txt:match('"updated_at" ?: ?"([^"]-)"') or txt:match('"created_at" ?: ?"([^"]-)"')
        date=date:gsub("T"," "):gsub("Z","")
        local fname,xx,build,ext = url:match('%/(Far%.(x%d%d)%.3%.0%.(%d-)%.%d-%.[0-9a-f]-%.([^%/]+))$')
        table.insert(FileList,{build..xx..' '..date..' '..ext,url,page,fname})
      end
      table.insert(pages,page)
    end
  end
end

ListT={}
local DlgProc=function(hDlg,Msg,Param1,Param2)
  local function BoxUpdate()
    hDlg:send(F.DM_SETTEXT,2,box[1] and '[ Far ]' or '[ Git ]')
    hDlg:send(F.DM_SETTEXT,3,box[2] and '[ x64 ]' or '[ x86 ]')
    hDlg:send(F.DM_SETTEXT,4,box[3] and '[ 7z  ]' or '[ msi ]')
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
        if ans then RealPos=i break end
      end
    end
    hDlg:send(F.DM_LISTSETCURPOS,5,{SelectPos=RealPos})
    FileName=tostring(hDlg:send(F.DM_GETTEXT,5))
    hDlg:send(F.DM_SETFOCUS,5,0)
  end
  local function RemoveListActions(pos)
    for i=pos,pos-#ListActions-1,-1 do
      local FarListItem=hDlg:send(F.DM_LISTGETITEM,5,i)
      if FarListItem.Text:sub(1,1)=="*" then
        hDlg:send(F.DM_LISTDELETE,5,{StartIndex=i,Count=1})
        table.remove(ListT,i)
      else break
      end
    end
  end
  if Msg==F.DN_INITDIALOG then
    BoxUpdate()
    RefreshList()
  elseif (Msg==F.DN_EDITCHANGE or Msg==F.DN_LISTCHANGE) and Param1==5 then
    local ListInfo=hDlg:send(F.DM_LISTINFO,5)
    RealPos=ListInfo.SelectPos==0 and RealPos or ListInfo.SelectPos
    local LastPos=ListInfo.ItemsNumber
    local str=tostring(hDlg:send(F.DM_GETTEXT,5))
    if Msg==F.DN_EDITCHANGE and str:sub(1,1)=="*"
    then
      if str==ListActions[1] then
        RemoveListActions(LastPos)
        GetFileList(FileList[#FileList][3]+1)
      elseif str==ListActions[2] then
        RemoveListActions(LastPos)
        local page=FileList[#FileList][3]
        table.remove(pages)
        for i=#FileList,1,-1 do if FileList[i][3]==page then table.remove(FileList,i) else break end end
        GetFileList(page)
        local p=ListT[#ListT][2]
        for i=#ListT,1,-1 do if ListT[i][2]==p then table.remove(ListT,i) else RealPos=i+1 break end end
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
    RemoveListActions(LastPos)
    if Param1==2 then GetFileList() end
    RealPos=1
    RefreshList()
  end
end

Macro {
area="Common"; flags=""; description="! FarUpdate";
action=function()
  local changelog="Far.changelog"
  local f=tmp..changelog
  if #FileList==0 then
    --fwrite(GetPage('-L https://github.com/FarGroup/FarManager/raw/master/far/changelog'),f)
    fwrite(GetPage('https://raw.githubusercontent.com/FarGroup/FarManager/master/far/changelog'),f)
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
      local function Download(tmp,FileName)
        if not win.GetFileInfo(tmp..FileName) or far.Message("Download it again?","WARNING! File exist",";YesNo","w")==1
        then panel.GetUserScreen() win.system('curl.exe -g -k -L --location-trusted "'..url..'" -o "'..tmp..FileName..'"') panel.SetUserScreen()
        end
      end
      if res==#items-1 then
        Download(tmp,FileName)
      elseif res==#items-2 then
        Download(tmp,FileName)
        FarUpdate(FileName)
        panel.GetUserScreen() win.system('start /MIN '..tmp..'FarUpdate.bat') panel.SetUserScreen()
      end
    end
  end
end;
}

-- FarProfileBackUp.lua 1.0
Macro {
area="Common"; flags=""; description="! FarProfileBackUp";
action=function()
  fwrite('nircmd.exe waitprocess Far.exe\n7z.exe a -aoa -xr!CrashLogs "'..farhome..'"\\Profile.7z "'..farhome..'\\Profile" > '..tmp..'FarProfileBackUp.log\nstart "" "'..farhome..'\\ConEmu.exe"\nexit',tmp..'FarProfileBackUp.bat')
  win.system('start /MIN '..tmp..'FarProfileBackUp.bat')
end;
}