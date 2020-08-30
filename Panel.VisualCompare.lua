-- Panel.VisualCompare.lua
-- v1.8.7
-- Visual Compare files or folders for panels: Files, Branch, Temporary, Arclite, Netbox, Observer, TorrentView.
-- Note: if more than two files are selected on the active panel for comparison, the AdvCmpEx plugin will be called.
-- Keys: CtrlAltC
-- Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2080#6

local ffi = require("ffi")

ffi.cdef([[
typedef struct {
  void*          hwnd;
  uint32_t       wFunc;
  const wchar_t* pFrom;
  const wchar_t* pTo;
  unsigned short fFlags;
  int            fAnyOperationsAborted;
  void*          hNameMappings;
  const wchar_t* lpszProgressTitle;
} SHFILEOPSTRUCTW;
int SHFileOperationW(SHFILEOPSTRUCTW *);
]])

local FO_DELETE          = 0x0003
local FOF_SILENT         = 0x0004
local FOF_NOCONFIRMATION = 0x0010

local function utf16(str)
  local strw = win.Utf8ToUtf16(str)
  local result = ffi.new("wchar_t[?]", #strw/2+1)
  ffi.copy(result, strw)
  return result
end

local function remove(fname)
  local fileopw = ffi.new("SHFILEOPSTRUCTW")
  fileopw.wFunc = FO_DELETE
  fileopw.pFrom = utf16(fname.."\0\0")
  fileopw.pTo = utf16("\0\0")
  fileopw.fFlags = FOF_SILENT+FOF_NOCONFIRMATION
  return 0 == ffi.load("shell32").SHFileOperationW(fileopw)
end

local VisComp = "AF4DAB38-C00A-4653-900E-7A8230308010"
local CopyDl1 = "42E4AEB1-A230-44F4-B33C-F195BB654931"
local CopyDl2 = "FCEF11C4-5490-451D-8B4A-62FA03F52759"
local CopyDl3 = "2430BA2F-D52E-4129-9561-5E8B1C3BACDB"
local ExtrDlg = "97877FD0-78E6-4169-B4FB-D76746249F4D"
local TorrDlg = "00000000-0000-0000-546F-7272656E7400"
local MArcDlg = "C5508DDB-5175-4736-9A10-C8F6EED7B32F"

local function f(p,f) if f:match("^[A-Z]:") then p=f elseif p=="" then p="\\" elseif f~=".." then if p:sub(-1,-1)=="\\" then p=p..f else p=p.."\\"..f end end return p end
local function e(p,f)
  local h=Far.DisableHistory(-1)
  if f==".." then Panel.Select(0,1) end
  Keys("F5"); p=p.."\\"
  if Area.Dialog and Dlg.ItemType==4 and (Dlg.Id==CopyDl1 or Dlg.Id==CopyDl2 or Dlg.Id==CopyDl3 or Dlg.Owner==MArcDlg) then print(p) Keys("Enter") end
  if Area.Dialog and (Dlg.ItemType==4 or Dlg.ItemType==8) and (Dlg.Id==CopyDl1 or Dlg.Id==CopyDl3 or Dlg.Owner==MArcDlg) then print(p) Keys("Enter") end -- fix 2nd dialog
  if Area.Dialog and Dlg.Owner==TorrDlg then print(p) Keys("Enter") end
  if Area.Dialog and Dlg.ItemType==7 and Dlg.Id==CopyDl1 then Keys("Enter") end
  if Area.Dialog and Dlg.ItemType==4 and Dlg.Id==ExtrDlg then print(p) Keys("AltO Enter") end
  Far.DisableHistory(h)
end

local VC="Visual Compare"
local msg=[[Selection wrong! - I don't know what to compare.

File compare modes by priority order:
1. At Active panel selected 2 files
2. At Active panel selected 1 file and Passive panel selected 1 file
3. At Active panel selected 1 file and 2nd under cursor
4. At Active panel selected 0 files, will be used file under cursor
   At Passive panel will be used selected file or file under cursor ]]

Macro {
description="VC: Визуальное сравнение файлов"; area="Shell"; key="CtrlAltC";
condition = function()
  local tPanelInfo1 = panel.GetPanelInfo(nil,1)
  local tPanelInfo0 = panel.GetPanelInfo(nil,0)
  if tPanelInfo1 and tPanelInfo0 then
    if tPanelInfo1.SelectedItemsNumber>2 then
      local t1,t0 = {},{}
      for i=1,tPanelInfo1.SelectedItemsNumber do table.insert(t1,panel.GetSelectedPanelItem(nil,1,i).FileName) end -- selected => t1
      Panel.Select(1,0) -- clear selection on the passive panel
      for i=1,tPanelInfo0.ItemsNumber do -- select files on the passive panel with the same names
        for k,v in ipairs(t1) do
          if panel.GetPanelItem(nil,0,i).FileName==v then table.insert(t0,i) table.remove(t1,k) break end
        end
        if #t1==0 then break end
      end
      if #t0>0 then panel.SetSelection(nil,0,t0,true) end
      Plugin.SyncCall("ED0C4BD8-D2F0-4B6E-A19F-B0B0137C9B0C") -- call AdvCmpEx
      panel.RedrawPanel(nil,1)
      panel.RedrawPanel(nil,0)
    elseif tPanelInfo1.SelectedItemsNumber==2
      or tPanelInfo1.SelectedItemsNumber==1 and tPanelInfo0.SelectedItemsNumber<=1
      or tPanelInfo1.SelectedItemsNumber==0 and (not PPanel.Plugin or PPanel.Plugin and
      (PPanel.Format=="Branch" or PPanel.Prefix=="tmp" or tPanelInfo0.SelectedItemsNumber<=1))
    then return true
    else far.Message(msg,VC)
    end
  end
end;
action = function()
  local APR,PPR,AP,PP,AC,PC,AF,PF,ePF,APD,PPD,TMP,S2,CI = APanel.Prefix,PPanel.Prefix,APanel.Path0,PPanel.Path0,APanel.Current,PPanel.Current,APanel.Format,PPanel.Format,regex.new"netbox|observe|torrent","\\AP","\\PP",win.GetEnv("Temp").."\\~arc"
  remove(TMP)
  if APanel.SelCount==2 then
    S2,PC,AC = true,panel.GetSelectedPanelItem(nil,1,1).FileName,panel.GetSelectedPanelItem(nil,1,2).FileName
    --if not APanel.Left then AC,PC = PC,AC end
  elseif APanel.SelCount==1 and PPanel.SelCount==1 then PC,AC = panel.GetSelectedPanelItem(nil,0,1).FileName,panel.GetSelectedPanelItem(nil,1,1).FileName
  elseif APanel.SelCount==1 then S2,PC,AC = true,panel.GetSelectedPanelItem(nil,1,1).FileName,panel.GetCurrentPanelItem(nil,1).FileName
    CI=panel.GetPanelInfo(nil,1).CurrentItem
    panel.BeginSelection(nil,1) panel.SetSelection(nil,1,CI,true)
  elseif APanel.SelCount==0 and PPanel.SelCount==1 then PC=panel.GetSelectedPanelItem(nil,0,1).FileName
  end
  local eAP,ePP = AF=="arc" or APR=="ma" or ePF:match(APR or ""),PF=="arc" or PPR=="ma" or ePF:match(PPR or "")
  if S2 and eAP then
    AP=TMP..APD PP=AP e(AP,AC)
  elseif S2 then
    PP=AP
  else
    if eAP then AP=TMP..APD e(AP,AC) end
    if ePP then PP=TMP..PPD panel.SetActivePanel(nil,0) e(PP,PC) panel.SetActivePanel(nil,0) end
  end
  if CI then panel.SetSelection(nil,1,CI,false) panel.EndSelection(nil,1) end
  AP,PP = f(AP,AC),f(PP,PC)
  if AP==PP then far.Message("it's the same object\n\n1st: "..PP.."\n2nd: "..AP,VC)
  else
    local NotRead,NotReadFile = false,""
    local function crash_protect(f)
      local fffezzzz,zzzzfeff,feff,fffe,efbbbf,zero = "\255\254\000\000","\000\000\254\255","\254\255","\255\254","\239\187\191"
      if not win.GetFileInfo(f).FileAttributes:find("d") then
        local h=io.open(f,"rb")
        if h then
          local s=h:read(4) or ""
          local l=string.len(s)
          zero=(l==0 or l==3 and s==efbbbf or l==2 and (s==fffe or s==feff) or l==4 and (s==fffezzzz or s==zzzzfeff)) h:close()
        else
          NotRead,NotReadFile = true,f
        end
      end
      return zero
    end
    local cp_AP,cp_PP = crash_protect(AP),crash_protect(PP)
    if NotRead then far.Message("\nCrash protect!\n\nFile: "..NotReadFile.."\n- blocked?",VC)
    elseif cp_AP and cp_PP
    then
      local APlen = AP:len()-PP:len()
      far.Message("\nCrash protect!\n\nFiles have zero sizes or BOM only\n\n1st: "..PP..(APlen>0 and string.rep(" ",APlen) or "").."\n2nd: "..AP..(APlen<0 and string.rep(" ",-APlen) or ""),VC)
    else
      if APanel.Left
      then Plugin.Command(VisComp,'"'..AP..'" "'..PP..'"')
      else Plugin.Command(VisComp,'"'..PP..'" "'..AP..'"') Keys("Tab")
      end
    end
  end
end
}
