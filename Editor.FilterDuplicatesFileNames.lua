-- Editor.FilterDuplicatesFileNames.lua
-- v1.2.3.1
-- Filter Duplicates File Names with complex logic
-- ![Editor.FilterDuplicatesFileNames](http://i.piccy.info/i9/ef8a00f82a655df0f6058b78be55fc5f/1585847959/7483/1370793/2020_04_02_201451.png)
-- Keys: launch from Macro Browser alt.
-- Tip: In the dialog all elements have prompts, press F1 for help

local guid = "FE9B8874-9651-434C-8182-72329F2371A5"
local uGuid = win.Uuid(guid)
local Temp = win.GetEnv("Temp")
local lstfile = "EFDFN-FList.txt"
lstfile = Temp.."\\"..lstfile
local FList = lstfile
local repfile = "EFDFN-Report.txt"
repfile = Temp.."\\"..repfile
local FReport = repfile


local F = far.Flags
local ffi = require'ffi'
local C = ffi.C

local bit_band,bit_bnot,bit_bor = bit.band,bit.bnot,bit.bor
local bit64_bor = bit64.bor
local editor_Editor,editor_GetStringW = editor.Editor,editor.GetStringW
local far_CPluginStartupInfo,far_Dialog,far_FarClock,far_Message,far_SendDlgMessage = far.CPluginStartupInfo,far.Dialog,far.FarClock,far.Message,far.SendDlgMessage
local regex_matchW = regex.matchW
local string_byte,string_rep = string.byte,string.rep
local table_insert,table_remove,table_sort = table.insert,table.remove,table.sort
local win_GetFileAttr,win_Utf16ToUtf8,win_Utf8ToUtf16 = win.GetFileAttr,win.Utf16ToUtf8,win.Utf8ToUtf16

local NULL = ffi.cast("void*",0)
local pHTAB = ffi.cast("void*",win_Utf8ToUtf16("\t"))
local PANEL_ACTIVE = ffi.cast("HANDLE",-1)
local pBL0,pBL1 = ffi.cast("BOOL*",0),ffi.cast("BOOL*",1)
local FSF = ffi.cast("struct PluginStartupInfo*",far_CPluginStartupInfo()).FSF
local ZERO,HTAB,BS = ffi.cast("unsigned int",0),ffi.cast("unsigned int",9),string_byte("\\")
local ts = {nil,true,9999,true,false,2,2,true,true}
local Flags = C.SORT_STRINGSORT
local tts,FullPathEF,FileSizeEF,FileAttrEF = {}

ffi.cdef[[
unsigned long int wcstoul(const wchar_t*, wchar_t**, int);
unsigned long long int wcstoull(const wchar_t*, wchar_t**, int);
]]

local function ToWChar(str)
  str=win_Utf8ToUtf16(str)
  local res=ffi.new("wchar_t[?]",#str/2+1)
  ffi.copy(res,str)
  return res
end

local function GetStartAndLenW(name)
  local ptr = C.wcsrchr(name,BS)
  name = ptr==NULL and name or ptr+1
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
  local ptr,size,attr
  if FileAttrEF then
    attr = tonumber(C.wcstoul(name,pHTAB,0))
    --attr = tonumber(FSF.atoi(name))
    ptr = C.wcschr(name,HTAB)
    name = ptr==NULL and name or ptr+1
  end
  if FileSizeEF then
    size = tonumber(FSF.atoi64(name))
    ptr = C.wcschr(name,HTAB)
    name = ptr==NULL and name or ptr+1
  end
  ptr = C.wcsrchr(name,BS)
  name = ptr==NULL and name or ptr+1
  local len = tonumber(C.wcslen(name))
  if ts[2] and ts[3]<0 and -ts[3]<len then
    return name+len+ts[3],-ts[3],name,len,size,attr
  elseif ts[2] and ts[3]>0 and ts[3]<len then
    return name,ts[3],name,len,size,attr
  else
    return name,len,name,len,size,attr
  end
end

local compare = function(p1,p2)
  local st1,ln1 = GetStartAndLenW(p1[4])
  local st2,ln2 = GetStartAndLenW(p2[4])
  local res = -2 + C.CompareStringW(C.LOCALE_USER_DEFAULT,Flags,st1,ln1,st2,ln2)
  if res==0 and ts[6]~=2 then res=p1[6]-p2[6] end
  if res==0 and ts[7]~=2 then res=p1[7]-p2[7] end
  return res>0
end

local Items = {
 --[[01]] {F.DI_DOUBLEBOX,    3,1, 65,9, 0, 0,0, 0, "Filter duplicates of FileName. Help: F1"},
 --[[02]] {F.DI_CHECKBOX,     5,2, 26,2, 0, 0,0, 0, "Num&ber of symbols"},
 --[[03]] {F.DI_EDIT,        27,2, 32,2, 0, 0,0, 0, ""},
 --[[04]] {F.DI_CHECKBOX,     5,3, 20,3, 0, 0,0, 0, "Ignore &case"},
 --[[05]] {F.DI_CHECKBOX,    38,3, 62,3, 0, 0,0, 0, "Ignore Full &Duplicates"},
 --[[06]] {F.DI_CHECKBOX,     5,4, 21,4, 0, 0,0, F.DIF_3STATE, "&Sizes of FD:"},
 --[[07]] {F.DI_CHECKBOX,     5,5, 26,5, 0, 0,0, F.DIF_3STATE, "&Attributes of FD:"},
 --[[08]] {F.DI_CHECKBOX,     5,6, 35,6, 0, 0,0, 0, "Accuracy (&two-pass method)"},
 --[[09]] {F.DI_CHECKBOX,     5,8, 15,8, 0, 0,0, 0, "Re&port"},
 --[[10]] {F.DI_TEXT,        -1,7,  0,0, 0, 0,0, F.DIF_SEPARATOR,""},
 --[[11]] {F.DI_BUTTON,       0,8,  0,0, 0, 0,0, F.DIF_DEFAULTBUTTON+F.DIF_CENTERGROUP,"&Ok"},
 --[[12]] {F.DI_BUTTON,       0,8,  0,0, 0, 0,0, F.DIF_CENTERGROUP,"Ca&ncel"}
}

local function DlgProc(hDlg,Msg,Param1,Param2)
  if Msg==F.DN_INITDIALOG then
    for i=2,#Items-3 do tts[i]=ts[i] end
    far_SendDlgMessage(hDlg,F.DM_SETTEXT,3,tts[3])
    far_SendDlgMessage(hDlg,F.DM_SETCHECK,2,tts[2] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    far_SendDlgMessage(hDlg,F.DM_SETCHECK,4,tts[4] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    far_SendDlgMessage(hDlg,F.DM_SETCHECK,5,tts[5] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    far_SendDlgMessage(hDlg,F.DM_SETCHECK,6,tts[6]==0 and F.BSTATE_UNCHECKED or tts[6]==1 and F.BSTATE_CHECKED or tts[6]==2 and F.BSTATE_3STATE)
    far_SendDlgMessage(hDlg,F.DM_SETTEXT,6,"&Sizes of FD: "..(tts[6]==0 and "<>" or tts[6]==1 and "==" or "--"))
    far_SendDlgMessage(hDlg,F.DM_ENABLE,6,FileSizeEF and 1 or 0)
    far_SendDlgMessage(hDlg,F.DM_SETCHECK,7,tts[7]==0 and F.BSTATE_UNCHECKED or tts[7]==1 and F.BSTATE_CHECKED or tts[7]==2 and F.BSTATE_3STATE)
    far_SendDlgMessage(hDlg,F.DM_SETTEXT,7,"&Attributes of FD: "..(tts[7]==0 and "<>" or tts[7]==1 and "==" or "--"))
    far_SendDlgMessage(hDlg,F.DM_ENABLE,7,FileAttrEF and 1 or 0)
    far_SendDlgMessage(hDlg,F.DM_SETCHECK,8,tts[8] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    far_SendDlgMessage(hDlg,F.DM_ENABLE,8,FileSizeEF and 1 or 0)
    far_SendDlgMessage(hDlg,F.DM_SETCHECK,9,tts[9] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
  elseif Msg==F.DN_BTNCLICK and (Param1==2 or Param1==4 or Param1==5 or Param1==8 or Param1==9) then
    tts[Param1] = Param2~=0
  elseif Msg==F.DN_BTNCLICK and (Param1==6 or Param1==7) then
    tts[Param1] = Param2
    far_SendDlgMessage(hDlg,F.DM_SETTEXT,Param1,(Param1==6 and "&Sizes of FD: " or "&Attributes of FD: ")..(Param2==0 and "<>" or Param2==1 and "==" or "--"))
  elseif Msg==F.DN_EDITCHANGE and Param1==3 then -- Number symbols
    tts[3] = tonumber(far_SendDlgMessage(hDlg,F.DM_GETTEXT,3)) or tts[3]
  else
    return
  end
  return true
end


Macro {
description="EFDFN: Filter Duplicates FileName in Editor"; name="EFDFN"; area="Shell Editor";

action=function()
  if Area.Shell then
    local t0 = far_FarClock()
    local count=0
    while true do
      if win_GetFileAttr(FList)
      then count=count+1 FList=lstfile:gsub("%.txt$","_"..count..".txt")
      else break
      end
    end
    local h=io.open(FList,"w+b")
    FSF.FarRecursiveSearch(ToWChar(APanel.Path),ToWChar("*"),
    function (ppi,FullPath,NULL)
      local attr=tonumber(ppi.FileAttributes)
      local size=tonumber(ppi.FileSize)
      if bit_band(attr,C.FILE_ATTRIBUTE_DIRECTORY)==0 then
        h:write(tostring(attr).."\t"..tostring(size).."\t"..win_Utf16ToUtf8(ffi.string(FullPath,C.wcslen(FullPath)*2)).."\n")
      end
      return true
    end
    ,F.FRS_RETUPDIR+F.FRS_RECUR+F.FRS_SCANSYMLINK,NULL)
    io.close(h)
    far_Message("mcs: "..far_FarClock()-t0,"CLFN")
    editor_Editor(FList,nil,0,0,-1,-1,bit64_bor(F.EF_NONMODAL,F.EF_IMMEDIATERETURN,F.EF_OPENMODE_RELOADIFOPEN),1,1,65001)
  end
  local line=editor_GetStringW(-1,1,0).StringText
  if line then
    FileSizeEF,FileAttrEF,FullPathEF = regex_matchW(line,[[^(\d+\t)?(\d+\t)?([^\t]+)$]])
    ts[6],ts[7] = FileSizeEF and ts[6] or 2,FileAttrEF and ts[7] or 2
  end
  if far_Dialog(uGuid,-1,-1,69,11,nil,Items,nil,DlgProc)==#Items-1 then
    local t0 = far_FarClock()
    for i=2,#Items-3 do ts[i]=tts[i] end
    Flags = ts[4] and bit_bor(Flags,C.NORM_IGNORECASE) or bit_band(Flags,bit_bnot(C.NORM_IGNORECASE))
    local tsel = {}
    local ec=ffi.cast("struct PluginStartupInfo*",far_CPluginStartupInfo()).EditorControl
    local ei=ffi.new("struct EditorInfo")
    ei.StructSize=ffi.sizeof(ei)
    if ec(-1,"ECTL_GETINFO",0,ei) then
      local LastLine=tonumber(ei.TotalLines)
      local egs=ffi.new("struct EditorGetString")
      egs.StructSize=ffi.sizeof(egs)
      local function PGPL(i)
        egs.StringNumber=i
        if ec(-1,"ECTL_GETSTRING",0,egs) then
          local st1,ln1,st3,ln3,sz1,fa1=StartAndLenW(egs.StringText)
          table_insert(tsel,{false,st1,ln1,st3,ln3,sz1,fa1,i,egs.StringText})
        end
      end
      for i=0,LastLine-1 do PGPL(i) end
      table_sort(tsel,compare)
      for i=2,LastLine do
        if C.CompareStringW(C.LOCALE_USER_DEFAULT,Flags,tsel[i-1][2],tsel[i-1][3],tsel[i][2],tsel[i][3])==2 then
          local x = C.CompareStringW(C.LOCALE_USER_DEFAULT,Flags,tsel[i-1][4],tsel[i-1][5],tsel[i][4],tsel[i][5])==2
          local y = (ts[6]==0 and tsel[i-1][6]~=tsel[i][6] or ts[6]==1 and tsel[i-1][6]==tsel[i][6] or ts[6]==2)
                and (ts[7]==0 and tsel[i-1][7]~=tsel[i][7] or ts[7]==1 and tsel[i-1][7]==tsel[i][7] or ts[7]==2)
          if not ts[5] and (not ts[2] and x and y or ts[2] and y)
           or ts[5] and (ts[6]==0 and tsel[i-1][6]==tsel[i][6] or ts[6]==1 and tsel[i-1][6]~=tsel[i][6])
                    and (ts[7]==0 and tsel[i-1][7]==tsel[i][7] or ts[7]==1 and tsel[i-1][7]~=tsel[i][7])
          then
            tsel[i-1][1]=true
            tsel[i][1]=true
          end
        end
      end
      -- -ts[5] and ts[6]==0
      -- +ts[5] and ts[6]==1
      -- +not ts[5] and ts[6]==0
      -- -not ts[5] and ts[6]==1
      if ts[8] then
        for i=2,LastLine do
          if (((ts[5] and ts[6]==1 or not ts[5] and ts[6]==0) and tsel[i-1][6]==tsel[i][6])
           or ((ts[5] and ts[7]==1 or not ts[5] and ts[7]==0) and tsel[i-1][7]==tsel[i][7]))
           and C.CompareStringW(C.LOCALE_USER_DEFAULT,Flags,tsel[i-1][4],tsel[i-1][5],tsel[i][4],tsel[i][5])==2
          then
            tsel[i-1][1]=false
            tsel[i][1]=false
          end
        end
      end
    end
    if ts[9] then
      local icount=0
      for i=1,#tsel do if tsel[i][1] then icount=icount+1 end end
      local count=0
      while true do
        if win_GetFileAttr(FReport)
        then count=count+1 FReport=repfile:gsub("%.txt$","_"..count..".txt")
        else break
        end
      end
      local h=io.open(FReport,"w+b")
      h:write("Items: "..icount.."/"..#tsel..
        "\nExecution time: "..(far_FarClock()-t0)..
        " mcs\nNumber of symbols: "..(ts[2] and ts[3] or "all")..
        "\nIgnore case: "..tostring(ts[4])..
        "\nIgnore Full Duplicates: "..tostring(ts[5])..
        "\nSizes of FD: "..(ts[6]==0 and "<>" or ts[6]==1 and "==" or "--")..
        "\nAttributes of FD: "..(ts[7]==0 and "<>" or ts[7]==1 and "==" or "--")..
        "\nAccuracy (two-pass method): "..tostring(ts[8])..
        "\n"..string_rep("-",30).."\n")
      for i=#tsel,1,-1 do if tsel[i][1] then h:write(tostring(tsel[i][8]+1).."\t"..win_Utf16ToUtf8(ffi.string(tsel[i][9],C.wcslen(tsel[i][9])*2)).."\n") end table_remove(tsel) end
      io.close(h)
      editor_Editor(FReport,nil,0,0,-1,-1,bit64_bor(F.EF_NONMODAL,F.EF_IMMEDIATERETURN,F.EF_OPENMODE_RELOADIFOPEN),1,1,65001)
      far_Message("mcs: "..far_FarClock()-t0,"EFDFN")
    end
  end
end;
}

Macro {
  description = "EFDFN - Help"; area = "Dialog"; key = "F1";
  condition=function() return Area.Dialog and Dlg.Id==guid end;
  action=function()
    if Dlg.CurPos<=3 then far_Message("The number of first or last symbols to compare","Help: Number of symbols")
    elseif Dlg.CurPos==4 then far_Message("Case of letters in FileName will be ignored","Help: Ignore case")
    elseif Dlg.CurPos==5 then far_Message("Full duplicates of FileName will be ignored","Help: Ignore Full Duplicates")
    elseif Dlg.CurPos==6 then far_Message("-- ignore, == equal, <> is not equal","Help: Sizes of FD")
    elseif Dlg.CurPos==7 then far_Message("-- ignore, == equal, <> is not equal","Help: Attributes of FD")
    elseif Dlg.CurPos==8 then far_Message("Two-pass method for\n<> (is not equal) options only","Help: Accuracy")
    elseif Dlg.CurPos==9 then far_Message("mcs  - total time of execution in mcs\nReport will be saved to:\n"..FReport,"Help: Report",nil,"l")
    end
  end;
}
