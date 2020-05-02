-- Panel.ShiftF[56].lua
-- v1.3.2
-- Extend Panel (Shift)?F[56] Dialog
-- Required: FAR3 build >= 5467
-- Keys: none, to use put in the scripts folder

local TGuid={
[win.Uuid("FCEF11C4-5490-451D-8B4A-62FA03F52759")]="F5",
[win.Uuid("431A2F37-AC01-4ECD-BB6F-8CDE584E5A03")]="F6",
[win.Uuid("502D00DF-EE31-41CF-9028-442D2E352990")]="SF5",
[win.Uuid("89664EF4-BB8C-4932-A8C0-59CAFD937ABA")]="SF6"
}
local btnOK=18 -- dialog execution button

local lng,key,btn
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
  local Act=""
  if key.F5 then Act=(ret or panel.GetPanelInfo(nil,1).SelectedItemsNumber>1) and lang[lng].Copy or lang[lng].Clone
  elseif key.F6 then Act=(ret or panel.GetPanelInfo(nil,1).SelectedItemsNumber>1) and lang[lng].Move or lang[lng].Rename
  elseif key.SF5 then Act=ret and lang[lng].Copy or lang[lng].Clone
  elseif key.SF6 then Act=ret and lang[lng].Move or lang[lng].Rename
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
      lng=Far.GetConfig('Language.Main')
      return btn and (lng=='English' or lng=='Russian')
    end
  end;
  action=function(Event,Param)
    key={F5=false,F6=false,SF5=false,SF6=false}
    key[btn]=true
    local PF,PP = PPanel.Format,PPanel.Path
    if PP:match("^[A-Za-z]:$") then PP=PP.."\\" end
    if Param.Msg==F.DN_INITDIALOG then
      local txt=PF=="" and PP or PF..":"
      Param.hDlg:send(F.DM_SETTEXT,3,Proc(Param.hDlg,PF,txt) and txt or APanel.Current)
    elseif Param.Msg==F.DN_EDITCHANGE and Param.Param1==3 then
      Proc(Param.hDlg,PF,Param.hDlg:send(F.DM_GETTEXT,3))
    elseif Param.Msg==F.DN_CLOSE and Param.Param1==btnOK and Param.hDlg:send(F.DM_GETTEXT,3)=="" then
      far.Message(lang[lng].MsgTXT,lang[lng].MsgHdr,nil,"w")
      Param.hDlg:send(F.DM_SETFOCUS,3)
      return 0
    end
    return false
  end
}
