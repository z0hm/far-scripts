-- Panel.SelectBOM.lua
-- v1.3
-- Selection files with BOM
-- Keys: launch from Macro Browser alt.
-- Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2280#12

local F = far.Flags
--local ffi = require'ffi'
--local NULL = ffi.cast("void*",0)
--local PANEL_ACTIVE = ffi.cast("HANDLE",-1)
--local pBL0,pBL1 = ffi.cast("BOOL*",0),ffi.cast("BOOL*",1)
local ReportPath=win.GetEnv('TEMP')..'\\boom.txt'
local boom,Report = {},false
local function process(f,t)
  -- utf32le,utf32be,utf16le,utf16be,utf8
  local res,bom = 0,{'\255\254\0\0','\0\0\254\255','\255\254','\254\255','\239\187\191'}
  local h=io.open(f,"rb")
  if h then
    local s=h:read(4) or '' h:close()
    for i=#bom,2,-1 do
      if string.sub(s,1,#bom[i])==bom[i] then
        if i==3 and s==bom[1] then i=1 end
        if t[i] then res=i end
        if Report then table.insert(boom[i],f) end
        break
      end
    end
  end
  return res
end

local guid = win.Uuid("2180A62D-04B5-44D9-999E-3A3328D51B84")
local edtFlags = F.DIF_HISTORY+F.DIF_USELASTHISTORY
local Items = {
--[[01]] {F.DI_DOUBLEBOX, 3,1, 27,11,0, 0,0, 0, "Select BOOM!"},
--[[02]] {F.DI_CHECKBOX,  5,2, 25,0, 0, 0,0, 0, "UTF-32 LE"},
--[[03]] {F.DI_CHECKBOX,  5,3, 25,0, 0, 0,0, 0, "UTF-32 BE"},
--[[04]] {F.DI_CHECKBOX,  5,4, 25,0, 0, 0,0, 0, "UTF-16 &LE"},
--[[05]] {F.DI_CHECKBOX,  5,5, 25,0, 0, 0,0, 0, "UTF-16 &BE"},
--[[06]] {F.DI_CHECKBOX,  5,6, 25,0, 0, 0,0, 0, "&UTF-8"},
--[[07]] {F.DI_CHECKBOX,  5,7, 12,0, 0, 0,0, 0, "&All"},
--[[08]] {F.DI_CHECKBOX, 15,7, 25,0, 0, 0,0, 0, "&Report"},
--[[09]] {F.DI_EDIT,      5,8, 24,2, 0, "BOOM!ReportPath",0, edtFlags,""},
--[[10]] {F.DI_TEXT,     -1,9,  0,0, 0, 0,0, F.DIF_SEPARATOR,""},
--[[11]] {F.DI_BUTTON,    0,10, 0,0, 0, 0,0, F.DIF_DEFAULTBUTTON+F.DIF_CENTERGROUP,"&Ok"},
--[[12]] {F.DI_BUTTON,    0,10, 0,0, 0, 0,0, F.DIF_CENTERGROUP,"Ca&ncel"}
}

local GFocus,ChkBOX,tReportPath = 6,{false,false,false,false,true,false},ReportPath
local function DlgProc(hDlg,Msg,Param1,Param2)
  if Msg==F.DN_INITDIALOG then
    for i=1,#ChkBOX do hDlg:send(F.DM_SETCHECK,i+1,ChkBOX[i] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED) end
    hDlg:send(F.DM_SETTEXT,9,ReportPath)
    hDlg:send(F.DM_SETFOCUS,GFocus,0)
  elseif Msg==F.DN_BTNCLICK and Param1>1 and Param1<7 then
    ChkBOX[Param1-1]=Param2~=0
  elseif Msg==F.DN_BTNCLICK and Param1==7 then
    for i=1,#ChkBOX do
      ChkBOX[i]=Param2~=0
      hDlg:send(F.DM_SETCHECK,i+1,ChkBOX[i] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    end
  elseif Msg==F.DN_BTNCLICK and Param1==8 then
    Report=Param2~=0
  elseif (Msg==F.DN_EDITCHANGE or Msg==F.DN_LISTCHANGE) and Param1==9 then -- ReportPath changed
    local s=tostring(hDlg:send(F.DM_GETTEXT,9))
    tReportPath = s and s~='' and s or tReportPath
  elseif Msg==F.DN_GOTFOCUS then
    if Param1>1 and Param1<#Items-2 then GFocus=Param1 end
  else
    return
  end
  return true
end

Macro {
description="BOM Files select"; name="BOOM"; area="Shell"; key="";
action=function()
  if far.Dialog(guid,-1,-1,31,#Items+1,nil,Items,nil,DlgProc)==#Items-1 then
    --local s='' for i=1,#ChkBOX do s=s..(ChkBOX[i] and 1 or 0) end far.Message(s,'BOX')
    local ttime=far.FarClock()
    ReportPath = tReportPath=='' and ReportPath or tReportPath
    local head,itm0,itm1 = {},{},{}
    for i=2,6 do local s=Items[i][10]:gsub("&","") table.insert(head,s) end
    boom={} for i=1,#head do boom[i]={} end
    local ItemsNumber=panel.GetPanelInfo(nil,1).ItemsNumber
    --local pc=ffi.cast("struct PluginStartupInfo*",far.CPluginStartupInfo()).PanelControl
    --pc(PANEL_ACTIVE,"FCTL_BEGINSELECTION",0,NULL)
    for Item=1,ItemsNumber do
      local GPItem=panel.GetPanelItem(nil,1,Item)
      table.insert((GPItem.FileAttributes:find("d") or process(GPItem.FileName,ChkBOX)==0) and itm0 or itm1,Item)
      --pc(PANEL_ACTIVE,"FCTL_SETSELECTION",Item-1,(GPItem.FileAttributes:find("d") or process(GPItem.FileName,ChkBOX)==0) and pBL0 or pBL1)
    end
    panel.BeginSelection(nil,1)
    panel.SetSelection(nil,1,itm0,false)
    panel.SetSelection(nil,1,itm1,true)
    panel.EndSelection(nil,1)
    panel.RedrawPanel(nil,1)
    --pc(PANEL_ACTIVE,"FCTL_ENDSELECTION",0,NULL)
    --pc(PANEL_ACTIVE,"FCTL_REDRAWPANEL",0,NULL)
    if Report then
      ttime = far.FarClock()-ttime
      local ans=1
      if win.GetFileInfo(ReportPath) then ans=far.Message(ReportPath.."\nexist - overwrite?","BOOM! WARNING",";YesNo","w") end
      if ans==1 then
        local h=io.open(ReportPath,'wb')
        if h then
          local function _RootDir()
            local ItemInfo=panel.GetPanelInfo(0)
            local iItem,iTop = ItemInfo.CurrentItem,ItemInfo.TopPanelItem
            Panel.SetPosIdx(0,1)
            local APP0=APanel.Path0
            panel.RedrawPanel(nil,1,{CurrentItem=iItem; TopPanelItem=iTop})
            return APP0
          end
          h:write('Scan:\t'..ItemsNumber..' objects\n')
          h:write('Time:\t'..ttime..' mcs\n')
          h:write('Path:\t'.._RootDir()..'\nFind:')
          local s=''
          for i=#head,1,-1 do s=s..(#boom[i]>0 and '\t'..head[i]..'  '..#boom[i] or '') end
          s=s=='' and '\t0 files' or s
          h:write(s)
          for i=#head,1,-1 do
            if #boom[i]>0 then
              table.sort(boom[i],function(a,b) return win.CompareString(a,b,"u","c")==-1 end)
              h:write('\n')
              for j=1,#boom[i] do h:write('\n'..head[i]..'\t'..boom[i][j]) end
            end
          end
        end
        h:close()
      end
    end
  end
end
}
