-- FarExit.lua
-- v1.1.0.4
-- Extend Quit Far Dialog
-- ![changelog](http://i.piccy.info/i9/c30733a554949540a04b6ec94d7c20b8/1620285331/7939/1427986/FarExit.png)
-- Required: MessageX.lua in the modules folder
-- Keys: F10

local F = far.Flags
local GuidEditAskSaveId = far.Guids.EditAskSaveId
local uGuidEditAskSaveId = win.Uuid(GuidEditAskSaveId)
local uGuidFarAskQuitId  = win.Uuid(far.Guids.FarAskQuitId)
local GuidScreensSwitchId  = far.Guids.ScreensSwitchId
local uGuidScreensSwitchId  = win.Uuid(GuidScreensSwitchId)
local GuidFarExitId      = "FA70F0B0-AE94-4CB2-BB17-D9F8F6DEC66B"
local uGuidFarExitId     = win.Uuid(GuidFarExitId)
local bYES,bNO,bCANCEL,bSAVE,bEXIT = 4,5,6,1,2
local FarExitFlag,FarExitCode,hDlg = true
local key,desc = "0","Extend Quit Dialog"
local dialogs,viewers,editors,edmod = 0,0,0,0

local MessageX=require'MessageX'

local function Title() return viewers==0 and editors==0 and "Quit" or "Quit ["..(FarExitFlag and "x" or " ").."]" end

local function Message()
  local ss,s = ""
  if dialogs>0 then ss=ss.." Opened Dialog(s): "..dialogs.."\n" end
  if viewers>0 then ss=ss.." Opened Viewer(s): "..viewers.."\n" end
  if editors>0 then ss=ss.." Opened Editor(s): "..editors.."\n"
    if edmod>0 then ss=ss.."<#ec>Unsaved Editor(s): "..edmod.."<#rr>\n" end
  end
  if #ss>0 then ss=ss.."\n" end
  if FarExitFlag then s,ss = "Exit",ss.."Do you want to quit FAR?" else s,ss = "Close",ss.."Do you want to close all viewers and editors?" end
  if viewers==0 and editors==0 then ss=ss.."\n" else ss=ss.."\n\n<#es>0<#rs> Quit or not" if edmod>0 then ss=ss.."                    " end end
  if edmod>0 then ss=ss.."\n<#es>1<#rs> <#sa>Save modified Editors and "..s.."<#sr>\n<#es>2<#rs> <#sc>"..(FarExitFlag and "Exit without saving Editors" or "Close Editors without saving").."   <#sr>\n<#es>3<#rs> Cancel                         " end
  return ss
end

local function Buttons()
  local b1,b2,b3
  if edmod==0 then b1,b2 = "&Yes","&No"
  else
    local s=FarExitFlag and "Exit" or "Close"
    b1,b2,b3 = "&1 Save and "..s,"&2 "..s,"&3 Cancel"
  end
  return "!"..b1..";"..b2..(b3 and ";"..b3 or "")
end

return Event({
  group = "DialogEvent",
  description = desc.." Event",
  action = function(event, param)
    if event==F.DE_DLGPROCINIT and param.Msg==F.DN_INITDIALOG then
      local id=far.SendDlgMessage(param.hDlg,F.DM_GETDIALOGINFO)
      id = id and id.Id or ""
      if id==uGuidFarAskQuitId then
        local windows=far.AdvControl(F.ACTL_GETWINDOWCOUNT,0,0)
        dialogs,viewers,editors,edmod,FarExitCode = 0,0,0,0,nil
        for ii=1,windows do
          local info=far.AdvControl(F.ACTL_GETWINDOWINFO,ii,0)
          if info then
            if     F.WTYPE_DIALOG==info.Type then dialogs=dialogs+1
            elseif F.WTYPE_VIEWER==info.Type then viewers=viewers+1
            elseif F.WTYPE_EDITOR==info.Type then editors=editors+1
              if bit64.band(info.Flags,F.WIF_MODIFIED)==F.WIF_MODIFIED then edmod=edmod+1 end
            end
          end
        end
        if viewers==0 and editors==0 then FarExitFlag=true end
        FarExitCode=MessageX(Message(),Title(),Buttons(),"c","",uGuidFarExitId)
        if edmod==0 and (FarExitCode==bSAVE or FarExitCode==bEXIT) then FarExitCode=FarExitCode+1 end
        if FarExitCode==bSAVE or FarExitCode==bEXIT then
          for ii=windows,1,-1 do
            local info=far.AdvControl(F.ACTL_GETWINDOWINFO,ii)
            if info then
              if info.Type==F.WTYPE_EDITOR then
                far.AdvControl(F.ACTL_SETCURRENTWINDOW,ii)
                far.AdvControl(F.ACTL_COMMIT)
                local EGI=editor.GetInfo()
                if FarExitCode==bSAVE and bit64.band(info.Flags,F.WIF_MODIFIED)==F.WIF_MODIFIED then editor.SaveFile(EGI.EditorID) end
                editor.Quit(EGI.EditorID)
              elseif info.Type==F.WTYPE_VIEWER then
                far.AdvControl(F.ACTL_SETCURRENTWINDOW,ii)
                far.AdvControl(F.ACTL_COMMIT)
                local VGI=viewer.GetInfo()
                viewer.Quit(VGI.ViewerID)
              end
            end
          end
        end
        far.SendDlgMessage(param.hDlg,F.DM_CLOSE,FarExitFlag and (FarExitCode==bSAVE or FarExitCode==bEXIT) and bYES or bNO)
      elseif id==uGuidEditAskSaveId and (FarExitCode==bSAVE or FarExitCode==bEXIT) then
        hDlg=param.hDlg
        far.SendDlgMessage(hDlg,F.DM_CLOSE,FarExitCode==bSAVE and bYES or (FarExitCode==bEXIT and bNO or bCANCEL),0)
      elseif id==uGuidFarExitId or id==uGuidScreensSwitchId then hDlg=param.hDlg
      end
    elseif hDlg and (viewers>0 or editors>0) and Area.Dialog and Dlg.Id==GuidFarExitId and event==F.DE_DEFDLGPROCINIT and param.Msg==F.DN_CONTROLINPUT then
      if param.Param2.EventType==F.KEY_EVENT then
        local name=far.InputRecordToName(param.Param2)
        if name==key or name=="Alt"..key then
          FarExitFlag=not FarExitFlag
          mf.postmacro(Keys,"F10 F10")
        end
      end
    elseif hDlg and Area.Dialog and Dlg.Id==GuidEditAskSaveId and FarExitCode==nil then
      local EdExitCode=MessageX("File has been modified. Save?","Editor","!&Yes;&No;&Cancel","","",uGuidEditAskSaveId)
      far.SendDlgMessage(param.hDlg,F.DM_CLOSE,EdExitCode==bSAVE and bYES or (EdExitCode==bEXIT and bNO or bCANCEL),0)
    elseif hDlg and Area.Menu and Menu.Id==GuidScreensSwitchId and event==F.DE_DEFDLGPROCINIT and param.Msg==F.DN_CONTROLINPUT then
      if param.Param2.EventType==F.KEY_EVENT then
        local name=far.InputRecordToName(param.Param2)
        if name=="Del" then mf.postmacro(Keys,"Enter F10 F12 End") end
      end
    end
    return false
  end
})
