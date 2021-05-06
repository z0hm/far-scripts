-- FarExit.lua
-- v1.1.0.1
-- Extend Quit Far Dialog
-- ![changelog](http://i.piccy.info/i9/c30733a554949540a04b6ec94d7c20b8/1620285331/7939/1427986/FarExit.png)
-- Required: MessageX.lua in the modules folder
-- Keys: F10

local F = far.Flags
local uGuidEditAskSaveId = win.Uuid(far.Guids.EditAskSaveId)
local uGuidFarAskQuitId  = win.Uuid(far.Guids.FarAskQuitId)
local GuidFarExitId      = "FA70F0B0-AE94-4CB2-BB17-D9F8F6DEC66B"
local uGuidFarExitId     = win.Uuid(GuidFarExitId)
local bYES,bNO,bCANCEL,bSAVE,bEXIT = 4,5,6,1,2
local FarExitFlag,FarExitCode,hDlg = true
local key,desc = "0","Extend Quit Dialog"
local viewers,editors,edmod = 0,0,0

local function Title() return "Quit ["..(FarExitFlag and "x" or " ").."]" end

local function Message()
  local s,ss = "",""
  if viewers>0 or editors>0 then
    if viewers>0 then ss=ss.." Opened Viewer(s): "..viewers.."\n" end
    if editors>0 then ss=ss.." Opened Editor(s): "..editors.."\n"
      if edmod>0 then ss=ss.."<#ec>Unsaved Editor(s): "..edmod.."<#rr>\n" end
    end
    ss=ss.."\n"
  end
  if FarExitFlag then s,ss = "Exit",ss.."Do you want to quit FAR?" else s,ss = "Close",ss.."Do you want to close all viewers and editors?" end
  if viewers==0 and editors==0 then ss=ss.."\n" else ss=ss.."\n\n<#es>0<#rs> Quit or not" if edmod>0 then ss=ss.."                    " end end
  if edmod>0 then ss=ss.."\n<#es>1<#rs> <#sa>Save modified Editors and "..s.."<#sr>\n<#es>2<#rs> <#sc>"..(FarExitFlag and "Exit without saving Editors" or "Close Editors without saving").."   <#sr>\n<#es>3<#rs> Cancel                         " end
  return ss
end

local function Buttons()
  local b1,b2,b3
  if edmod==0 then b1,b2,b3 = "&Yes","&No"
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
        viewers,editors,edmod = 0,0,0
        for ii=1,windows do
          local info=far.AdvControl(F.ACTL_GETWINDOWINFO,ii,0)
          if info and F.WTYPE_VIEWER==info.Type then viewers=viewers+1 end
          if info and F.WTYPE_EDITOR==info.Type then editors=editors+1
            if bit64.band(info.Flags,F.WIF_MODIFIED)==F.WIF_MODIFIED then edmod=edmod+1 end
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
      elseif id==uGuidEditAskSaveId and (FarExitCode==bSAVE or FarExitCode==bEXIT) then far.SendDlgMessage(param.hDlg,F.DM_CLOSE,FarExitCode==bSAVE and bYES or (FarExitCode==bEXIT and bNO or bCANCEL),0)
      elseif id==uGuidFarExitId then hDlg=param.hDlg
      end
    elseif event==F.DE_DEFDLGPROCINIT and param.Msg==F.DN_CONTROLINPUT then
      if param.Param2.EventType==F.KEY_EVENT then
        local name=far.InputRecordToName(param.Param2)
        if Area.Dialog and Dlg.Id==GuidFarExitId and hDlg and (name==key or name=="Alt"..key) then 
          FarExitFlag=not FarExitFlag
          mf.postmacro(Keys,"F10 F10")
        end
      end
    end
    return false
  end
})
