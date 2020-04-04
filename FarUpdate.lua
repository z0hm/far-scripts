-- FarUpdate.lua
-- v1.6
-- Opening changelog and updating Far Manager to any version available on the site
-- ![changelog](http://i.piccy.info/i9/2e704ed9a9c5f058da7ed1e08402453c/1585846769/24321/1370793/2020_04_02_195044.png)
-- ![update dialog](http://i.piccy.info/i9/2926dae366e86ea1eacadc3a55508f5d/1585846888/29457/1370793/2020_04_02_195019.png)
-- Required: nircmd.exe, 7z.exe, requires tuning for local conditions
-- Keys: launch from Macro Browser alt.
-- Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=700#19

local function fwrite(s,f) local x,h = nil,io.open(f,"wb") if h then x=h:write(s or "") io.close(h) end return x end
local F = far.Flags
local guid = "0EEE33E2-1E95-4753-982C-B2BD1E63C3C4"
local uGuid = win.Uuid(guid)
local items = {
 --[[01]] {F.DI_DOUBLEBOX,    0,0, 32,6, 0, 0,0, 0, "Download file?"},
 --[[02]] {F.DI_BUTTON,       7,1,  0,1, 0, 0,0, F.DIF_BTNNOCLOSE, "[ x86 ]"},
 --[[03]] {F.DI_BUTTON,      18,1,  0,1, 0, 0,0, F.DIF_BTNNOCLOSE, "[ 7z  ]"},
 --[[04]] {F.DI_COMBOBOX,     2,2, 29,2,{}, 0,0, F.DIF_DROPDOWNLIST, ""},
 --[[05]] {F.DI_TEXT,         0,3,  0,0, 0, 0,0, F.DIF_SEPARATOR,""},
 --[[06]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_DEFAULTBUTTON+F.DIF_CENTERGROUP,"&Update"},
 --[[07]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_CENTERGROUP,"&Yes"},
 --[[08]] {F.DI_BUTTON,       0,4,  0,0, 0, 0,0, F.DIF_CENTERGROUP,"&No"}
}
local tmp=win.GetEnv("TEMP").."\\"
local farhome=win.GetEnv("FARHOME")
local x64,FileList,RealPos,FileName = win.IsProcess64bit(),{},1
local box={x64,true} -- [ x64 ]   [ 7z  ]
-- Create FarUpdate.bat
local FarUpdate=function(fname)
  fwrite('*.map\n*spa.lng\n*sky.lng\n*Ger.lng\n*Hun.lng\n*Hun.hlf\n*Ita.lng\n*Pol.lng\n*Pol.hlf\n*.pol.*\n*Cze.lng\n*Ukr.lng\n*Ukr.hlf\n*Bel.lng\n*Bel.hlf\n*.bel.*',tmp..'FarUpdExc.txt')
  fwrite('nircmd.exe waitprocess "'..farhome..'\\Far.exe"\n7z.exe x -aoa -o"'..farhome..'" -x!PluginSDK -xr@"'..tmp..'FarUpdExc.txt" "'..tmp..fname..'" > '..tmp..'FarUpdate.log'
  --..'\n7z.exe x -aoa -o"'..farhome..'\\Plugins\\NetBox" -x@"'..tmp..'FarUpdExc.txt" "H:\\Temp\\FarNetBox-2.4.5.531_Far3_x86.7z" > '..tmp..'FarUpdate.log'
  ..'\n7z.exe x -aoa -o"'..farhome..'\\Plugins\\FarColorer" -x@"'..tmp..'FarUpdExc.txt" "H:\\Temp\\FarColorer-1.2.9.1_Far3_x86.7z" > '..tmp..'FarUpdate.log'
  ..'\nstart "" "'..farhome..'\\ConEmu.exe"\nexit',tmp..'FarUpdate.bat')
end
local DlgProc=function(hDlg,Msg,Param1,Param2)
  local function BoxUpdate()
      hDlg:send(F.DM_SETTEXT,2,box[1] and '[ x64 ]' or '[ x86 ]')
      hDlg:send(F.DM_SETTEXT,3,box[2] and '[ 7z  ]' or '[ msi ]')
  end
  if Msg==F.DN_INITDIALOG then
    BoxUpdate()
    for i=1,#FileList do hDlg:send(F.DM_LISTADD,4,{{Text=FileList[i]}}) end
    RealPos=hDlg:send(F.DM_LISTSETCURPOS,4,{SelectPos=RealPos})
    FileName=tostring(hDlg:send(F.DM_GETTEXT,4))
    hDlg:send(F.DM_SETFOCUS,4,0)
  elseif (Msg==F.DN_EDITCHANGE or Msg==F.DN_LISTCHANGE) and Param1==4 then
    local ListInfo=hDlg:send(F.DM_LISTINFO,4)
    RealPos=ListInfo.SelectPos
    FileName=tostring(hDlg:send(F.DM_GETTEXT,4))
  elseif Msg==F.DN_BTNCLICK and Param1>=2 and Param1<=3 then   -- [ x86 ]   [ 7z  ]
    box[Param1-1]=not box[Param1-1]
    BoxUpdate()
  end
end

Macro {
area="Common"; flags=""; description="! FarUpdate";
action=function()
  local f=tmp.."Far.changelog"
  if #FileList==0 then
    --fwrite(GetPage('-L https://github.com/FarGroup/FarManager/raw/master/far/changelog'),f)
    fwrite(GetPage('https://raw.githubusercontent.com/FarGroup/FarManager/master/far/changelog'),f)
    local text=GetPage('https://farmanager.com/nightly.php')
    for build,year,month,day in string.gmatch(text,'nightly%/(Far30b%d-)%.x86%.(%d%d%d%d)(%d%d)(%d%d)%.7z') do table.insert(FileList,build.."  "..day.."-"..month.."-"..year) end
  end
  editor.Editor(f,nil,0,0,-1,-1,bit64.bor(F.EF_NONMODAL,F.EF_IMMEDIATERETURN,F.EF_OPENMODE_USEEXISTING),1,1,nil)
  local w=far.AdvControl(F.ACTL_GETFARRECT)
  local res=far.Dialog(uGuid,w.Right-34,w.Bottom-w.Top-7,w.Right-2,w.Bottom-w.Top-2,nil,items,F.FDLG_SMALLDIALOG,DlgProc)
  if res==#items-2 or res==#items-1 then
    if FileName then
      local build,day,month,year = string.match(FileName,'^(Far30b%d-)  (%d%d)%-(%d%d)%-(%d%d%d%d)$')
      if build and day and month and year then
        local function Download(tmp,FileName)
          if not win.GetFileInfo(tmp..FileName) or far.Message("Download it again?","WARNING! File exist",";YesNo","w")==1
          then panel.GetUserScreen() win.system('curl.exe -k "https://farmanager.com/nightly/'..FileName..'" -o "'..tmp..FileName..'"') panel.SetUserScreen()
          end
        end
        if res==#items-1 then
          local FileName=build..(box[1] and '.x64.' or '.x86.')..year..month..day..(box[2] and '.7z' or '.msi')
          Download(tmp,FileName)
        elseif res==#items-2 then
          local FileName=build..(x64 and '.x64.' or '.x86.')..year..month..day..'.7z'
          Download(tmp,FileName)
          FarUpdate(FileName)
          panel.GetUserScreen() win.system('start /MIN '..tmp..'FarUpdate.bat') panel.SetUserScreen()
        end
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