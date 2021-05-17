-- Panel.SelectFolders.lua
-- v1.0.0.1
-- Extend Select Folders/Files Dialog
-- ![changelog](http://i.piccy.info/i9/9de5c58f6ba15652d9ef22cb7ea4e945/1620055603/2539/1427619/2021_05_03_182332.png)
-- Keys: Grey+ Grey- CtrlF

local F = far.Flags
local Grey = {plus="29C03C36-9C50-4F78-AB99-F5DC1A9C67CD",minus="34614DDB-2A22-4EA9-BD4A-2DC075643F1B",cfg="A204FF09-07FA-478C-98C9-E56F61377BDE"}
local uGrey = {plus=win.Uuid(Grey.plus),minus=win.Uuid(Grey.minus),cfg=win.Uuid(Grey.cfg)}
local key,desc,mask,cmd,hDlg = "CtrlF","Extend Select Folders/Files Dialog"

Macro {
  area="Dialog"; key=key; description=desc.." Macro";
  condition = function() return hDlg and (Dlg.Id==Grey.plus or Dlg.Id==Grey.minus) end;
  action = function()
    local gkey=Dlg.Id==Grey.plus
    far.SendDlgMessage(hDlg,F.DM_CLOSE,-1,0) far.DialogFree(hDlg) hDlg=nil
    cmd=panel.GetCmdLine(nil)
    panel.SetCmdLine(nil,"@far:config")
    mf.postmacro(Keys,"Enter")
    mf.postmacro(Menu.Select,"Panel.SelectFolders",1)
    mf.postmacro(Keys,"Enter Esc "..(gkey and "ADD" or "SUBTRACT"))
  end;
}

return Event({
  group="DialogEvent",
  description=desc.." Event",
  action = function(event,param)
    if event==F.DE_DLGPROCINIT and param.Msg==F.DN_INITDIALOG then
      local id = far.SendDlgMessage(param.hDlg,F.DM_GETDIALOGINFO)
      id = id and id.Id or ""
      if id==uGrey.plus or id==uGrey.minus then
        hDlg=param.hDlg
        far.SendDlgMessage(hDlg,F.DM_SETTEXT,1,(id==uGrey.plus and "Select" or "Deselect").." ["..(Far.GetConfig("Panel.SelectFolders") and "x" or " ").."] Folders [ "..key.." ]")
        if mask then far.SendDlgMessage(hDlg,F.DM_SETTEXT,2,mask) end
      end
    elseif event==F.DE_DLGPROCEND and param.Msg==F.DN_CLOSE then
      local id = far.SendDlgMessage(param.hDlg,F.DM_GETDIALOGINFO)
      id = id and id.Id or ""
      if id==uGrey.cfg then far.DialogFree(param.hDlg) panel.SetCmdLine(nil,cmd or "")
      elseif id==uGrey.plus or id==uGrey.minus then mask=tostring(far.SendDlgMessage(param.hDlg,F.DM_GETTEXT,2))
      end
    end
  end
})
