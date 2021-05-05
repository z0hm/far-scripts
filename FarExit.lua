-- FarExit.lua
-- v1.0
-- Extend Quit Far Dialog
-- ![changelog](http://i.piccy.info/i9/896aa3267322510366b180e6094fc9ad/1620198573/7251/1427832/2021_05_05_100733.png)
-- Required: MessageX.lua in the modules folder
-- Keys: F10

local F = far.Flags
local uGuidEditAskSaveId = win.Uuid(far.Guids.EditAskSaveId)
local uGuidFarAskQuitId  = win.Uuid(far.Guids.FarAskQuitId)
local bYES,bNO,bCANCEL,bSAVE,bEXIT = 4,5,6,1,2

return Event({
  group = "DialogEvent",
  description = "Extend Quit Dialog",
  action = function(event, param)
    _G.FarExitCode=nil
    if event==F.DE_DLGPROCINIT and param.Msg==F.DN_INITDIALOG then
      local id=far.SendDlgMessage(param.hDlg,F.DM_GETDIALOGINFO)
      id = id and id.Id or ""
      if id==uGuidFarAskQuitId then
        local windows=far.AdvControl(F.ACTL_GETWINDOWCOUNT,0,0)
        local viewers,editors,edmod,ss = 0,0,0,""
        for ii=1,windows do
          local info=far.AdvControl(F.ACTL_GETWINDOWINFO,ii,0)
          if info and F.WTYPE_VIEWER==info.Type then viewers=viewers+1 end
          if info and F.WTYPE_EDITOR==info.Type then editors=editors+1
            if bit64.band(info.Flags,F.WIF_MODIFIED)==F.WIF_MODIFIED then edmod=edmod+1 end
          end
        end
        if viewers>0 or editors>0 then
          if viewers>0 then ss=ss.." Opened Viewer(s): "..viewers.."\n" end
          if editors>0 then ss=ss.." Opened Editor(s): "..editors.."\n"
            if edmod>0 then ss=ss.."<#ec>Unsaved Editor(s): "..edmod.."<#rr>\n" end
          end
          ss=ss.."\n"
        end
        ss=ss.."Do you want to quit FAR?"
        if edmod>0 then ss=ss.."\n\n<#es>1<#rs> <#sa>Save modified Editors and Exit<#sr>\n<#es>2<#rs> <#sc>Exit without saving Editors   <#sr>\n<#es>3<#rs> Do not Exit                   " end
        _G.FarExitCode=MessageX(ss,"Quit",edmod>0 and "!&1 Save && Exit;&2 Exit;&3 Cancel" or "!&Yes;&No","c","","")
        if edmod==0 then _G.FarExitCode=_G.FarExitCode+1 end
        if _G.FarExitCode==bSAVE or _G.FarExitCode==bEXIT then
          for ii=1,windows do
            local info=far.AdvControl(F.ACTL_GETWINDOWINFO,ii,0)
            if info then
              if info.Type==F.WTYPE_EDITOR then
                if _G.FarExitCode==bSAVE and bit64.band(info.Flags,F.WIF_MODIFIED)==F.WIF_MODIFIED then editor.SaveFile(info.EditorID) end
                editor.Quit(info.EditorID)
              elseif info.Type==F.WTYPE_VIEWER then viewer.Quit(info.ViewerID)
              end
            end
          end
        end
        far.SendDlgMessage(param.hDlg,F.DM_CLOSE,(_G.FarExitCode==bSAVE or _G.FarExitCode==bEXIT) and bYES or bNO)
      elseif id==uGuidEditAskSaveId and (_G.FarExitCode==bSAVE or _G.FarExitCode==bEXIT) then far.SendDlgMessage(param.hDlg,F.DM_CLOSE,_G.FarExitCode==bSAVE and bYES or (_G.FarExitCode==bEXIT and bNO or bCANCEL))
      end
    end
    return false
  end
})
