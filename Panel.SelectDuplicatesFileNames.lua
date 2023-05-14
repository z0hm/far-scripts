-- Panel.SelectDuplicatesFileNames.lua
-- v1.3.3.0
-- Select Duplicates File Names in Branch panel with complex logic
-- For the correct result, set default sorting system settings:
--   [ ] Treat digits as numbers
--   [ ] Case sensitive
-- The Integrity Checker plugin is required to calculate Hashes
-- ![Panel.SelectDuplicatesFileNames](http://i.piccy.info/i9/7a5542e442b1ee61b39f6f9ad8dcae63/1585894944/7348/1370861/2020_04_03_091759.png)
-- Keys: launch from Macro Browser alt.
-- Tip: In the dialog all elements have prompts, press F1 for help

local guid = "FE9B8874-9651-434C-8182-72329F2371A5"
local uGuid = win.Uuid(guid)
local temp = win.GetEnv("Temp")
local repfile = "PSDFN-Report.txt"
repfile = temp.."\\"..repfile
local freport = repfile

local F = far.Flags
local ffi = require'ffi'
local C = ffi.C
local NULL = ffi.cast("void*",0)
local PANEL_ACTIVE = ffi.cast("HANDLE",-1)
local pBL0,pBL1 = ffi.cast("BOOL*",0),ffi.cast("BOOL*",1)
local PanelMode,Desc1,Indi1 = 100099,"Select duplicates","!?"
local BS,ts = string.byte("\\"),{nil,true,9999,true,false,2,2,2,true,false}
local Flags = C.SORT_STRINGSORT
local IntChecker = "E186306E-3B0D-48C1-9668-ED7CF64C0E65"

local function GetStartAndLenW(name)
  local ptr = C.wcsrchr(name,BS)
  name = ptr==nil and name or ptr+1
  local len = tonumber(C.wcslen(name))
  if ts[2] and ts[3]<0 and -ts[3]<len then
    local res=ffi.new("wchar_t[?]",len+1)
    ffi.copy(res,name+len+ts[3],-ts[3]*2)
    ffi.copy(res-ts[3],name,(len+ts[3])*2)
    return res,len
  else
    return name,len
  end
end

local function StartAndLenW(name)
  local ptr = C.wcsrchr(name,BS)
  name = ptr==nil and name or ptr+1
  local len = tonumber(C.wcslen(name))
  if ts[2] and ts[3]<0 and -ts[3]<len then
    return name+len+ts[3],-ts[3],name,len
  elseif ts[2] and ts[3]>0 and ts[3]<len then
    return name,ts[3],name,len
  else
    return name,len,name,len
  end
end

local function GetHash(path)
  if type(path)~="string" then path=win.Utf16ToUtf8(ffi.string(path,C.wcslen(path)*2)) end
  return Plugin.SyncCall(IntChecker,"gethash","SHA-256",path,true)
end

local Compare = function(p1,p2)
  local st1,ln1 = GetStartAndLenW(p1.FileName)
  local st2,ln2 = GetStartAndLenW(p2.FileName)
  local res = not ts[2] and 0 or (-2 + C.CompareStringW(C.LOCALE_USER_DEFAULT,Flags,st1,ln1,st2,ln2))
  local sz1,sz2,fa1,fa2,hs1,hs2
  if ts[6]~=2 then sz1,sz2 = tonumber(p1.FileSize),tonumber(p2.FileSize) end
  if ts[7]~=2 and sz1==sz2 then if sz1==0 then hs1,hs2 = "","" else hs1,hs2 = GetHash(p1.FileName),GetHash(p2.FileName) end end
  if ts[8]~=2 then fa1,fa2 = tonumber(p1.FileAttributes),tonumber(p2.FileAttributes) end
  if res==0 and sz1 then res=sz1-sz2 end
  if res==0 and hs1 and hs1~=hs2 then res=1 end
  if res==0 and fa1 then res=fa1-fa2 end
  return res<0 and -1 or res>0 and 1 or 0
end

local Items = {
 --[[01]] {F.DI_DOUBLEBOX,    3,1, 65,10, 0, 0,0, 0, "Select duplicates of FileName. Help: F1"},
 --[[02]] {F.DI_CHECKBOX,     5,2, 26,2, 0, 0,0, 0, "Num&ber of symbols"},
 --[[03]] {F.DI_EDIT,        27,2, 32,2, 0, 0,0, 0, ""},
 --[[04]] {F.DI_CHECKBOX,     5,3, 20,3, 0, 0,0, 0, "Ignore &case"},
 --[[05]] {F.DI_CHECKBOX,    38,3, 62,3, 0, 0,0, 0, "Ignore Full &Duplicates"},
 --[[06]] {F.DI_CHECKBOX,     5,4, 21,4, 0, 0,0, F.DIF_3STATE, "&Sizes of FD:"},
 --[[07]] {F.DI_CHECKBOX,     5,5, 22,5, 0, 0,0, F.DIF_3STATE, "&Hashes of FD:"},
 --[[08]] {F.DI_CHECKBOX,     5,6, 26,6, 0, 0,0, F.DIF_3STATE, "&Attributes of FD:"},
 --[[09]] {F.DI_CHECKBOX,     5,7, 35,7, 0, 0,0, 0, "Accuracy (&two-pass method)"},
 --[[10]] {F.DI_CHECKBOX,     5,9, 15,9, 0, 0,0, 0, "Re&port"},
 --[[11]] {F.DI_TEXT,        -1,8,  0,0, 0, 0,0, F.DIF_SEPARATOR,""},
 --[[12]] {F.DI_BUTTON,       0,9,  0,0, 0, 0,0, F.DIF_DEFAULTBUTTON+F.DIF_CENTERGROUP,"&Ok"},
 --[[13]] {F.DI_BUTTON,       0,9,  0,0, 0, 0,0, F.DIF_CENTERGROUP,"Ca&ncel"}
}

local tts={}

local function DlgProc(hDlg,Msg,Param1,Param2)
  if Msg==F.DN_INITDIALOG then
    for i=2,#Items-3 do tts[i]=ts[i] end
    hDlg:send(F.DM_SETTEXT,3,tts[3])
    hDlg:send(F.DM_SETCHECK,2,tts[2] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_SETCHECK,4,tts[4] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_SETCHECK,5,tts[5] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_SETCHECK,6,tts[6]==0 and F.BSTATE_UNCHECKED or tts[6]==1 and F.BSTATE_CHECKED or tts[6]==2 and F.BSTATE_3STATE)
    hDlg:send(F.DM_SETTEXT,6,"&Sizes of FD: "..(tts[6]==0 and "<>" or tts[6]==1 and "==" or "--"))
    hDlg:send(F.DM_SETCHECK,7,tts[7]==0 and F.BSTATE_UNCHECKED or tts[7]==1 and F.BSTATE_CHECKED or tts[7]==2 and F.BSTATE_3STATE)
    hDlg:send(F.DM_SETTEXT,7,"&Hashes of FD: "..(tts[7]==0 and "<>" or tts[7]==1 and "==" or "--"))
    hDlg:send(F.DM_SETCHECK,8,tts[8]==0 and F.BSTATE_UNCHECKED or tts[8]==1 and F.BSTATE_CHECKED or tts[8]==2 and F.BSTATE_3STATE)
    hDlg:send(F.DM_SETTEXT,8,"&Attributes of FD: "..(tts[8]==0 and "<>" or tts[8]==1 and "==" or "--"))
    hDlg:send(F.DM_SETCHECK,9,tts[9] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_SETCHECK,10,tts[10] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
  elseif Msg==F.DN_BTNCLICK and (Param1==2 or Param1==4 or Param1==5 or Param1==9 or Param1==10) then
    tts[Param1] = Param2~=0
  elseif Msg==F.DN_BTNCLICK and (Param1==6 or Param1==7 or Param1==8) then
    tts[Param1] = Param2
    hDlg:send(F.DM_SETTEXT,Param1,(Param1==6 and "&Sizes of FD: " or (Param1==7 and "&Hashes of FD: " or "&Attributes of FD: "))..(Param2==0 and "<>" or Param2==1 and "==" or "--"))
  elseif Msg==F.DN_EDITCHANGE and Param1==3 then -- Number symbols
    tts[3] = tonumber(hDlg:send(F.DM_GETTEXT,3)) or tts[3]
  else
    return
  end
  return true
end

Macro {
description="PSDFN: Select Duplicates FileName in Branch panel"; name="PSDFN"; area="Shell";
action=function()
  if far.Dialog(uGuid,-1,-1,69,#Items-1,nil,Items,nil,DlgProc)==#Items-1 then
    local t0=far.FarClock()
    for i=2,#Items-3 do ts[i]=tts[i] end
    Flags = ts[4] and bit.bor(Flags,C.NORM_IGNORECASE) or bit.band(Flags,bit.bnot(C.NORM_IGNORECASE))
    --local PInfo=panel.GetPanelInfo(nil,1)
    local PInfo=ffi.new("struct PanelInfo")
    PInfo.StructSize=ffi.sizeof(PInfo)
    local pc=ffi.cast("struct PluginStartupInfo*",far.CPluginStartupInfo()).PanelControl
    if pc(PANEL_ACTIVE,"FCTL_GETPANELINFO",0,PInfo)==1 then
      local pin,pif = tonumber(PInfo.ItemsNumber),tonumber(PInfo.Flags)
      if pin>1 then
        if bit.band(pif,F.PFLAGS_SELECTEDFIRST)>0 then Keys("ShiftF12") end
        if bit.band(pif,F.PFLAGS_REVERSESORTORDER)==0 then pc(PANEL_ACTIVE,"FCTL_SETSORTORDER",1,NULL) end
        Panel.LoadCustomSortMode(PanelMode,{Description=Desc1;Indicator=Indi1;Compare=Compare})
        Panel.SetCustomSortMode(PanelMode,0)
        local st0,ln0,st1,ln1,st2,ln2,st3,ln3,sz0,sz1,fa0,fa1,hs0,hs1
        local ppi = ffi.new("struct FarGetPluginPanelItem")
        ppi.StructSize = ffi.sizeof("struct FarGetPluginPanelItem")
        local function PGPI(i)
          ppi.Size = pc(PANEL_ACTIVE,"FCTL_GETPANELITEM",i,NULL)
          if ppi.Size~=0 then
            local buf = ffi.new("char[?]",ppi.Size)
            ppi.Item = ffi.cast("struct PluginPanelItem*",buf)
            pc(PANEL_ACTIVE,"FCTL_GETPANELITEM",i,ppi)
            st1,ln1,st3,ln3=StartAndLenW(ffi.cast("const unsigned short*",ppi.Item.FileName))
            if ts[6] then sz1=tonumber(ppi.Item.FileSize) end
            if ts[7]~=2 then hs1=GetHash(ppi.Item.FileName) end
            if ts[8] then fa1=tonumber(ppi.Item.FileAttributes) end
          end
        end
        PGPI(0)
        pc(PANEL_ACTIVE,"FCTL_BEGINSELECTION",0,NULL)
        for i=1,pin-1 do
          st0,ln0,st2,ln2,sz0,fa0,hs0 = st1,ln1,st3,ln3,sz1,fa1,hs1
          PGPI(i)
          if not ts[2] or ts[2] and C.CompareStringW(C.LOCALE_USER_DEFAULT,Flags,st0,ln0,st1,ln1)==2 then
            local y=(ts[6]==0 and sz0~=sz1 or ts[6]==1 and sz0==sz1 or ts[6]==2)
                and (ts[7]==0 and hs0~=hs1 or ts[7]==1 and hs0==hs1 or ts[7]==2)
                and (ts[8]==0 and fa0~=fa1 or ts[8]==1 and fa0==fa1 or ts[8]==2)
            if not ts[5] and y
               or ts[5] and (ts[6]==0 and sz0==sz1 or ts[6]==1 and sz0~=sz1)
                        and (ts[7]==0 and hs0==hs1 or ts[7]==1 and hs0~=hs1)
                        and (ts[8]==0 and fa0==fa1 or ts[8]==1 and fa0~=fa1)
            then
              pc(PANEL_ACTIVE,"FCTL_SETSELECTION",i-1,pBL1)
              pc(PANEL_ACTIVE,"FCTL_SETSELECTION",i,pBL1)
            end
          end
        end
        if ts[9] then
          st0,ln0,st1,ln1,st2,ln2,st3,ln3,sz0,sz1,fa0,fa1,hs0,hs1 = nil
          PGPI(0)
          for i=1,pin-1 do
            st0,ln0,st2,ln2,sz0,fa0 = st1,ln1,st3,ln3,sz1,fa1
            PGPI(i)
            if (((ts[5] and ts[6]==1 or not ts[5] and ts[6]==0) and sz0==sz1)
             or ((ts[5] and ts[7]==1 or not ts[5] and ts[7]==0) and hs0==hs1)
             or ((ts[5] and ts[8]==1 or not ts[5] and ts[8]==0) and fa0==fa1))
             and (not ts[2] or ts[2] and C.CompareStringW(C.LOCALE_USER_DEFAULT,Flags,st2,ln2,st3,ln3)==2)
            then
              pc(PANEL_ACTIVE,"FCTL_SETSELECTION",i-1,pBL0)
              pc(PANEL_ACTIVE,"FCTL_SETSELECTION",i,pBL0)
            end
          end
        end
        pc(PANEL_ACTIVE,"FCTL_ENDSELECTION",0,NULL)
        pc(PANEL_ACTIVE,"FCTL_REDRAWPANEL",0,NULL)
        if ts[10] then
          local pisel,pisin=""
          if pc(PANEL_ACTIVE,"FCTL_GETPANELINFO",0,PInfo)==1 then
            pisin=tonumber(PInfo.SelectedItemsNumber)
            pisel=tostring(pisin==1 and 0 or pisin).."/"..tostring(tonumber(PInfo.ItemsNumber))
          end
          local count=0
          while true do
            if win.GetFileAttr(freport)
            then count=count+1 freport=repfile:gsub("%.txt$","_"..count..".txt")
            else break
            end
          end
          local h = io.open(freport,"w+b")
          h:write("Items: "..pisel..
            "\nExecution time: "..(far.FarClock()-t0)..
            " mcs\nNumber of symbols: "..(ts[2] and ts[3] or "all")..
            "\nIgnore case: "..tostring(ts[4])..
            "\nIgnore Full Duplicates: "..tostring(ts[5])..
            "\nSizes of FD: "..(ts[6]==0 and "<>" or ts[6]==1 and "==" or "--")..
            "\nHashes of FD: "..(ts[7]==0 and "<>" or ts[7]==1 and "==" or "--")..
            "\nAttributes of FD: "..(ts[8]==0 and "<>" or ts[8]==1 and "==" or "--")..
            "\nAccuracy (two-pass method): "..tostring(ts[9])..
            "\n"..string.rep("-",40).."\nAttr\tSize\tHash\tPath\n"..string.rep("-",40).."\n")
          local function PGPSI(i)
            ppi.Size = pc(PANEL_ACTIVE,"FCTL_GETSELECTEDPANELITEM",i,NULL)
            if ppi.Size~=0 then
              local buf = ffi.new("char[?]",ppi.Size)
              ppi.Item = ffi.cast("struct PluginPanelItem*",buf)
              pc(PANEL_ACTIVE,"FCTL_GETSELECTEDPANELITEM",i,ppi)
              local path = win.Utf16ToUtf8(ffi.string(ppi.Item.FileName,C.wcslen(ppi.Item.FileName)*2))
              h:write(
                tostring(tonumber(ppi.Item.FileAttributes)).."\t"..
                tostring(tonumber(ppi.Item.FileSize)).."\t"..
                tostring(GetHash(path)).."\t"..
                path.."\n"
              )
            end
          end
          if pisin then for i=0,pisin-1 do PGPSI(i) end end
          io.close(h)
          far.Message("mcs: "..far.FarClock()-t0,"PSDFN")
        end
      end
    end
  end
end;
}

Macro {
  description = "PSDFN - Help"; area = "Dialog"; key = "F1";
  condition=function() return Area.Dialog and Dlg.Id==guid end;
  action=function()
    if Dlg.CurPos<=3 then far.Message("The number of first or last symbols to compare","Help: Number of symbols")
    elseif Dlg.CurPos==4 then far.Message("Case of letters in FileName will be ignored","Help: Ignore case")
    elseif Dlg.CurPos==5 then far.Message("Full duplicates of FileName will be ignored","Help: Ignore Full Duplicates")
    elseif Dlg.CurPos==6 then far.Message("-- ignore, == equal, <> is not equal","Help: Sizes of FD")
    elseif Dlg.CurPos==7 then far.Message("-- ignore, == equal, <> is not equal","Help: Hashes of FD")
    elseif Dlg.CurPos==8 then far.Message("-- ignore, == equal, <> is not equal","Help: Attributes of FD")
    elseif Dlg.CurPos==9 then far.Message("Two-pass method for\n<> (is not equal) options only","Help: Accuracy")
    elseif Dlg.CurPos==10 then far.Message("mcs  - total time of execution in mcs\nReport will be saved to:\n"..freport,"Help: Report",nil,"l")
    end
  end;
}
