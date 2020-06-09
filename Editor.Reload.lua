-- Editor.Reload.lua
-- v1.0
-- http://forum.ru-board.com/topic.cgi?forum=5&topic=31718&start=7640#7

local F = far.Flags

Macro {
area="Editor"; key="CtrlR"; flags=""; description="Editor: Reload"; 
action=function()
  local rl=true
  local f=editor.GetInfo(-1).FileName
  if bit64.band(far.AdvControl(F.ACTL_GETWINDOWINFO).Flags,F.WIF_MODIFIED)==F.WIF_MODIFIED then
    local ans=far.Message("File has been modified. Save?","Editor",";YesNoCancel","w")
    if ans==1 then
      if not editor.SaveFile(-1) then
        rl=false
        far.Message("File is not saved - blocked? Reload canceled.","Warning!")
      end
    elseif ans<=0 or ans==3 then rl=false
    end
  end
  if rl then
    editor.Quit(-1)
    editor.Editor(f,_,_,_,_,_,bit64.bor(F.EF_NONMODAL,F.EF_IMMEDIATERETURN,F.EF_OPENMODE_USEEXISTING),1,1)
  end
end;
}
