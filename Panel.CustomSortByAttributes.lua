-- Panel.CustomSortByAttributes.lua
-- v2.0.0.1
-- Panel files sorting by attributes
-- ![Panel.CustomSortByAttributes](http://i.piccy.info/i9/e4a7f377afa812d28e195dbae27e802b/1585895856/14743/1370861/2020_04_03_093318.png)
-- Keys: CtrlShiftF3 or from Menu "Sort by"
-- Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2240#16

if not (bit and jit) then return end

local F = far.Flags
local guid = win.Uuid("A79390CE-5450-403A-8FAE-17EE3315CB38")
local MenuGuid = "B8B6E1DA-4221-47D2-AB2E-9EC67D0DC1E3"
-- Settings --------------------------------------------------------------------
local ModeNumber = 100109
local Description = "Custom: by Attributes"
local Indi1 = "aA"
local Indicator = Indi1
local Key = "CtrlShiftF3"
--------------------------------------------------------------------------------

local edtFlags = F.DIF_HISTORY+F.DIF_USELASTHISTORY
local Items = {
--[[01]] {F.DI_DOUBLEBOX, 3,1, 66,18, 0, 0,0, 0, "Custom sort by Attributes"},
--[[02]] {F.DI_TEXT,      5,2, 64,0, 0, 0,0, 0, "File:"},
--[[03]] {F.DI_TEXT,      5,3, 18,0, 0, 0,0, 0, "Attributes:"},
--[[04]] {F.DI_EDIT,      17,3, 35,0, 0, "CustomSortByAttributes_Attributes",0, edtFlags, ""},
--[[05]] {F.DI_BUTTON,    38,3, 54,0, 0, 0,0, 0, "[ Get from &File ]"},
--[[06]] {F.DI_TEXT,     -1,4,  0,0, 0, 0,0, F.DIF_SEPARATOR,""},
--[[07]] {F.DI_CHECKBOX,  5,5,  30,0, 0, 0,0, 0, "&Read only"},
--[[08]] {F.DI_CHECKBOX,  5,6,  30,0, 0, 0,0, 0, "&Archive"},
--[[09]] {F.DI_CHECKBOX,  5,7,  30,0, 0, 0,0, 0, "&Hidden"},
--[[10]] {F.DI_CHECKBOX,  5,8,  30,0, 0, 0,0, 0, "&System"},
--[[11]] {F.DI_CHECKBOX,  5,9,  30,0, 0, 0,0, 0, "&Directory"},
--[[12]] {F.DI_CHECKBOX,  5,10, 30,0, 0, 0,0, 0, "&Compressed"},
--[[13]] {F.DI_CHECKBOX,  5,11, 30,0, 0, 0,0, 0, "&Encrypted"},
--[[14]] {F.DI_CHECKBOX,  5,12, 30,0, 0, 0,0, 0, "Not &indexed"},
--[[15]] {F.DI_CHECKBOX,  5,13, 30,0, 0, 0,0, 0, "S&parse"},
--[[16]] {F.DI_CHECKBOX,  5,14, 30,0, 0, 0,0, 0, "&Temporary"},
--[[17]] {F.DI_CHECKBOX,  38,5, 62,0, 0, 0,0, 0, "Off&line"},
--[[18]] {F.DI_CHECKBOX,  38,6, 62,0, 0, 0,0, 0, "Reparse point &X"},
--[[19]] {F.DI_CHECKBOX,  38,7, 62,0, 0, 0,0, 0, "&Virtual"},
--[[20]] {F.DI_CHECKBOX,  38,8, 62,0, 0, 0,0, 0, "Inte&grity stream"},
--[[21]] {F.DI_CHECKBOX,  38,9, 62,0, 0, 0,0, 0, "No scru&b data"},
--[[22]] {F.DI_CHECKBOX,  38,10,62,0, 0, 0,0, 0, "Pinned &Y"},
--[[23]] {F.DI_CHECKBOX,  38,11,62,0, 0, 0,0, 0, "&Unpinned"},
--[[24]] {F.DI_CHECKBOX,  38,12,62,0, 0, 0,0, 0, "Recall on open &J"},
--[[25]] {F.DI_CHECKBOX,  38,13,62,0, 0, 0,0, 0, "Recall on data access &K"},
--[[26]] {F.DI_CHECKBOX,  38,14,62,0, 0, 0,0, 0, "Strictly se&quential"},
--[[27]] {F.DI_CHECKBOX,  20,15,36,0, 0, 0,0, 0, "by selected &Z"},
--[[28]] {F.DI_CHECKBOX,  5,17, 17,0, 0, 0,0, 0, "Report &W"},
--[[29]] {F.DI_TEXT,     -1,16,  0,0, 0, 0,0, F.DIF_SEPARATOR,""},
--[[30]] {F.DI_BUTTON,    0,17,  0,0, 0, 0,0, F.DIF_DEFAULTBUTTON+F.DIF_CENTERGROUP,"&Ok"},
--[[31]] {F.DI_BUTTON,    0,17,  0,0, 0, 0,0, F.DIF_CENTERGROUP,"Ca&ncel"}
}

local AttributesSymbols="rahsdceipyltvgbxujkq"

local AttributeValue = {
--[[FILE_ATTRIBUTE_READONLY           ]] 0x00000001,
--[[FILE_ATTRIBUTE_ARCHIVE            ]] 0x00000020,
--[[FILE_ATTRIBUTE_HIDDEN             ]] 0x00000002,
--[[FILE_ATTRIBUTE_SYSTEM             ]] 0x00000004,
--[[FILE_ATTRIBUTE_DIRECTORY          ]] 0x00000010,
--[[FILE_ATTRIBUTE_COMPRESSED         ]] 0x00000800,
--[[FILE_ATTRIBUTE_ENCRYPTED          ]] 0x00004000,
--[[FILE_ATTRIBUTE_NOT_CONTENT_INDEXED]] 0x00002000,
--[[FILE_ATTRIBUTE_SPARSE_FILE        ]] 0x00000200,
--[[FILE_ATTRIBUTE_TEMPORARY          ]] 0x00000100,
--[[FILE_ATTRIBUTE_OFFLINE            ]] 0x00001000,
--[[FILE_ATTRIBUTE_REPARSE_POINT      ]] 0x00000400,
--[[FILE_ATTRIBUTE_VIRTUAL            ]] 0x00010000,
--[[FILE_ATTRIBUTE_INTEGRITY_STREAM   ]] 0x00008000,
--[[FILE_ATTRIBUTE_NO_SCRUB_DATA      ]] 0x00020000,
--[[FILE_ATTRIBUTE_PINNED             ]] 0x00080000,
--[[FILE_ATTRIBUTE_UNPINNED           ]] 0x00100000,
--[[FILE_ATTRIBUTE_RECALL_ON_OPEN     ]] 0x00040000,
--[[FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS]] 0x00400000,
--[[FILE_ATTRIBUTE_STRICTLY_SEQUENTIAL]] 0x20000000
}

--  FILE_ATTRIBUTE_DIRECTORY             0x00000010
--  FILE_ATTRIBUTE_DEVICE                0x00000040
--  FILE_ATTRIBUTE_NORMAL                0x00000080

local SAttributes,FAttributes,FAMasque,AttributesWeight,CompareMode,xReport,count,FName,GFocus,ttime0,count0 = "",{},0x205FFF37,0,true,false,0,"",4
for i=1,#AttributeValue do FAttributes[i]=false end

local function BySelected(l)
  if l==AttributesWeight then l=(#AttributeValue+1)*#AttributeValue+1
  else
    local equal=bit.band(l,AttributesWeight)
    local diff=bit.bxor(l,AttributesWeight)
    local e,d = 0,0
    for i=1,#AttributeValue do
      if bit.band(equal,AttributeValue[i])>0 then e=e+1 end
      if bit.band(diff,AttributeValue[i])>0 then d=d+1 end
    end
    l=(#AttributeValue+1)*e-d
  end
  return -l
end

local Compare = function(p1,p2)
  count = count+1
  local l1 = bit.band(tonumber(p1.FileAttributes),FAMasque)
  local l2 = bit.band(tonumber(p2.FileAttributes),FAMasque)
  if CompareMode then l1,l2 = BySelected(l1),BySelected(l2) end
  return l1<l2 and -1 or (l1>l2 and 1 or 0)
end

local tFAttributes,tSAttributes,tCompareMode = {}

local function DlgProc(hDlg,Msg,Param1,Param2)
  if Msg==F.DN_INITDIALOG then
    tSAttributes,tCompareMode = SAttributes,CompareMode
    hDlg:send(F.DM_SETTEXT,2,"File: "..(FName:len()<55 and FName or (FName:sub(1,27).."…"..FName:sub(-26,-1))))
    for i=1,#AttributeValue do tFAttributes[i]=FAttributes[i] end
    hDlg:send(F.DM_SETTEXT,4,tostring(tSAttributes):gsub("^0",""))
    hDlg:send(F.DM_SETCHECK,27,tCompareMode and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    for i=1,#AttributeValue do
      hDlg:send(F.DM_SETCHECK,i+6,tFAttributes[i] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    end
    hDlg:send(F.DM_SETFOCUS,GFocus)
  elseif Msg==F.DN_EDITCHANGE and Param1==4 then
    local text = hDlg:send(F.DM_GETTEXT,4):lower()
    if text:match("^%d") then text=text:gsub("%D","")
    elseif text:match("^["..AttributesSymbols.."]") then text=text:gsub("[^"..AttributesSymbols.."]","")
    else text=text:gsub("[^%d"..AttributesSymbols.."]","")
    end
    if tonumber(text) then
      text = text:gsub("^0","")
      tSAttributes = bit.band(tonumber(text) or 0,FAMasque)
      for i=1,#AttributeValue do
        tFAttributes[i] = bit.band(tSAttributes,AttributeValue[i])==AttributeValue[i] and true or false
        hDlg:send(F.DM_SETCHECK,i+6,tFAttributes[i] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
      end
    else
      tSAttributes,text = tostring(text),""
      for i=1,#AttributesSymbols do
        local symbol=AttributesSymbols:sub(i,i)
        local _,n = tSAttributes:gsub(symbol,symbol)
        if n==1 then tFAttributes[i]=true text=text..symbol else tFAttributes[i]=false end
        hDlg:send(F.DM_SETCHECK,i+6,tFAttributes[i] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
      end
      tSAttributes = text
    end
    hDlg:send(F.DM_SETTEXT,4,text)
  elseif Msg==F.DN_BTNCLICK and Param1==5 then
    tSAttributes = mf.fattr(FName) or tSAttributes
    hDlg:send(F.DM_SETTEXT,4,tSAttributes)
    for i=1,#AttributeValue do
      tFAttributes[i] = bit.band(tSAttributes,AttributeValue[i])==AttributeValue[i] and true or false
      hDlg:send(F.DM_SETCHECK,i+6,tFAttributes[i] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    end
  elseif Msg==F.DN_BTNCLICK and Param1==26 then
    tCompareMode = Param2~=0
  elseif Msg==F.DN_BTNCLICK and Param1>6 and Param1<27 then
    local i=Param1-6
    tFAttributes[i] = Param2~=0
    if tonumber(tSAttributes) then
      tSAttributes = tFAttributes[i] and bit.bor(tSAttributes,AttributeValue[i]) or bit.band(tSAttributes,bit.bnot(AttributeValue[i]))
    else
      tSAttributes = tFAttributes[i] and tSAttributes..AttributesSymbols:sub(i,i) or tSAttributes:gsub(AttributesSymbols:sub(i,i),"")
    end
    hDlg:send(F.DM_SETTEXT,4,tSAttributes)
  elseif Msg==F.DN_BTNCLICK and Param1==28 then   -- [x] Report
    xReport = Param2~=0
  else
    return
  end
  return true
end

Panel.LoadCustomSortMode(ModeNumber,{Description=Description;Indicator=Indicator;Compare=Compare})

Macro {
  description = Description; area = "Shell Menu"; key = Key.." Enter MsLClick";
  condition = function(key) return Area.Shell and key==Key or Area.Menu and Menu.Id==MenuGuid and Menu.Value:match(Description) and (key=="Enter" or key=="MsLClick") end;
  action = function()
    local kbd=bit.band(Far.KbdLayout(),0xFFFF)
    if kbd==0 and _G.KbdLayout then kbd=_G.KbdLayout() end
    if not kbd or kbd and kbd~=0x0409 then Far.KbdLayout(0x0409) end
    FName=APanel.Current
    if Area.Menu then Keys("Esc") end
    if far.Dialog(guid,-1,-1,70,20,nil,Items,nil,DlgProc)==#Items-1 then
      SAttributes = tSAttributes
      local OldAttributesWeight = AttributesWeight
      AttributesWeight=0 for i=1,#AttributeValue do FAttributes[i]=tFAttributes[i] if FAttributes[i] then AttributesWeight=AttributesWeight+AttributeValue[i] end end
      if AttributesWeight~=OldAttributesWeight or tCompareMode~=CompareMode then panel.SetSortOrder(nil,1,bit.band(panel.GetPanelInfo(nil,1).Flags,F.PFLAGS_REVERSESORTORDER)==0) end
      CompareMode = tCompareMode
      count = 0
      local ttime=far.FarClock()
      Panel.LoadCustomSortMode(ModeNumber,{Description=Description;Indicator=Indicator;Compare=Compare})
      Panel.SetCustomSortMode(ModeNumber,0)
      ttime = far.FarClock()-ttime
      local report = "Curr count: "..count.."  mcs: "..ttime
      if count0 then
        report = report.."\nPrev count: "..count0.."  mcs: "..ttime0.."\nDifference:"..string.format("%+"..(string.len(tostring(count0))+1).."d",count-count0).."  mcs:"..string.format("%+"..(string.len(tostring(ttime0))+1).."d",ttime-ttime0)
      end
      count0,ttime0 = count,ttime
      if xReport then
        panel.RedrawPanel(nil,1)
        far.Message(report,"Report",nil,"l")
      end
    end
    if kbd and type(kbd)=="number" and kbd~=0x0409 then Far.KbdLayout(kbd) end
  end;
}
