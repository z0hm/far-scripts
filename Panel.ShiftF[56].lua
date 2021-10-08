-- Panel.ShiftF[56].lua
-- v1.3.4.0
-- Extend Panel (Shift)?F[56] Dialog
-- Hint: Press CtrlR and set replace [x] data for copy the source file to the target file with multiple hardlinks
-- Required: FAR3 build >= 5467
-- Keys: none, to use put in the scripts folder

local repkey,desc,repdata,Act,pSIN,hDlg = "CtrlR","Replace data for Copy/Move Dialog",false,""
local TDlg={
far.Guids.CopyFilesId, -- "F5"
far.Guids.MoveFilesId, -- "F6"
far.Guids.CopyCurrentOnlyFileId, -- "SF5"
far.Guids.MoveCurrentOnlyFileId, -- "SF6"
far.Guids.CopyOverwriteId  -- Warning
}
local TGuid={
[win.Uuid(TDlg[1])]="F5",
[win.Uuid(TDlg[2])]="F6",
[win.Uuid(TDlg[3])]="SF5",
[win.Uuid(TDlg[4])]="SF6"
}
local wDlg=win.Uuid(TDlg[5])
local btnOK=18        -- dialog execution button
local btnOverwrite=10 -- dialog overwrite button

local lng,key,btn,wrn
local lang={
  English={re=regex.new("^(Copy|Clone|Rename or move|Rename|Move)"),
    Copy="Copy",Clone="Clone",Move="Move",Rename="Rename",
    MsgHdr="Warning!",MsgTXT="Path or file name don't specified"},
  Russian={re=regex.new("^(Копировать|Клонировать|Переименовать или перенести|Переименовать|Переместить)"),
    Copy="Копировать",Clone="Клонировать",Move="Переместить",Rename="Переименовать",
    MsgHdr="Внимание!",MsgTXT="Путь или имя файла не заданы"}
}

local F=far.Flags

local Proc=function(hDlg,PF,txt)
  local ret
  if txt:find(":$") or PF==txt:gsub(":%s*$","") then ret=true else ret=txt:find("[\\/]") end
  Act,pSIN = ""
  if key.F5 or key.F6 then
    pSIN=panel.GetPanelInfo(nil,1).SelectedItemsNumber
    if pSIN>1 then repdata=false end
  end
  if     key.F5 then Act=(ret or pSIN>1) and lang[lng].Copy or lang[lng].Clone
  elseif key.F6 then Act=(ret or pSIN>1) and lang[lng].Move or lang[lng].Rename
  elseif key.SF5 then pSIN=1 Act=ret and lang[lng].Copy or lang[lng].Clone
  elseif key.SF6 then pSIN=1 Act=ret and lang[lng].Move or lang[lng].Rename
  end
  hDlg:send(F.DM_SETTEXT,1,(key.F5 or key.F6) and Act or "[Shift] "..Act)
  txt=hDlg:send(F.DM_GETTEXT,2)
  hDlg:send(F.DM_SETTEXT,2,lang[lng].re:gsub(txt,Act))
  hDlg:send(F.DM_SETTEXT,btnOK,(lng=="English" and (key.F6 or key.SF6)) and Act:sub(1,-2).."&e" or "&"..Act)
  return ret
end

Event {
  group="DialogEvent";
  description="Extend Panel (Shift)?F[56] Dialog";
  condition=function(Event,Param)
    if Event==F.DE_DLGPROCINIT then
      local id=Param.hDlg:send(F.DM_GETDIALOGINFO)
      id=id and id.Id or ""
      btn=TGuid[id]
      wrn=wDlg==id
      if btn and pSIN==1 then
        hDlg=Param.hDlg
        far.SendDlgMessage(hDlg,F.DM_SETTEXT,1,Act.." and replace ["..(repdata and "x" or " ").."] data [ "..repkey.." ]")
      end
      lng=Far.GetConfig('Language.Main')
      return btn and (lng=='English' or lng=='Russian') or wrn
    end
  end;
  action=function(Event,Param)
    if btn then
      key={F5=false,F6=false,SF5=false,SF6=false}
      key[btn]=true
    end
    local PF,PP,AP,AC = PPanel.Format,PPanel.Path,APanel.Path,APanel.Current
    if btn and Param.Msg==F.DN_INITDIALOG then
        repdata=false
        if PP:find("^[A-Za-z]:$") then PP=PP.."\\" end
        local txt=PF=="" and PP or PF..":"
        Param.hDlg:send(F.DM_SETTEXT,3,Proc(Param.hDlg,PF,txt) and txt or AC)
    elseif btn and Param.Msg==F.DN_EDITCHANGE and Param.Param1==3 then
      Proc(Param.hDlg,PF,Param.hDlg:send(F.DM_GETTEXT,3))
    elseif btn and Param.Msg==F.DN_CLOSE and Param.Param1==btnOK and Param.hDlg:send(F.DM_GETTEXT,3)=="" then
      far.Message(lang[lng].MsgTXT,lang[lng].MsgHdr,nil,"w")
      Param.hDlg:send(F.DM_SETFOCUS,3)
      return 0
    elseif wrn and repdata and Param.Msg==F.DN_CLOSE and Param.Param1==btnOverwrite then
      local source=AP..(AP:sub(-1,-1)=="\\" and "" or "\\")..AC
      local target=PP..(PP:sub(-1,-1)=="\\" and "" or "\\")..AC
      if     key.F5 or key.SF5 then win.CopyFile(source,target)
      elseif key.F6 or key.SF6 then win.CopyFile(source,target) win.DeleteFile(source)
      end
      return true
    end
    return false
  end
}

Macro {
  area="Dialog"; key=repkey; description=desc.." Macro";
  condition = function() return hDlg and (Dlg.Id==TDlg[1] or Dlg.Id==TDlg[2] or Dlg.Id==TDlg[3] or Dlg.Id==TDlg[4]) end;
  action = function() repdata = pSIN and pSIN==1 and not repdata or false end;
}
