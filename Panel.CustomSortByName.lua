-- Panel.CustomSortByName.lua
-- v1.1.0.2
-- Very powerful panel file sorting
-- ![Panel.CustomSortByName](http://i.piccy.info/i9/305c735c17b77b86698f8161f3b6988e/1585847695/9001/1370793/2020_04_02_201018.png)
-- <details><summary>Сортировки файлов в панели:</summary>
--
-- 1. С вводом Offset при нажатии шорката, если вместо ввода числа нажать Enter, то будет использовано прежнее значение. Стартовое значение (по умолчанию) 0, т.е. обычная сортировка по имени.
-- 2. C вводом Symbols аналогично п.1, значение по умолчанию "-_ ".
--  п.1 и п.2 с игнорированием символов - игнорируется то, что Майкрософт считает символами.
-- 3. По группе цифр в имени файла с поиском в прямом, либо обратном направлении.
-- 4. По подстроке, захваченной регэкспом. Регэкспы можно комментировать, в этом случае первую строку начинаем с -- (2-х минусов), далее комментарий, затем перевод строки и на второй строке пишем сам регэксп. Порядок сортировки можно изменить, добавив в конец регэкспа конструкцию {!:...}, где вместо ... указываем порядок возврата захваченных групп, например {!:$3$2$1}. Для поиска каждой группы по всей строке вне зависимости от их позиции, используется конструкция {?:pat1}{?:pat2}{?:pat3}{!:$3$2$1}, где patN - характерный паттерн группы, захватывается первый совпавший.
-- 5. По функции пользователя. Примеры:
--  [x] Offset=0
--  [x] Func
-- <details><summary>by BOM</summary>
--
--   ``` lua
--     -- by BOM
--     local efbbbf,fffe,feff,ffi,sub = '\239\187\191','\255\254','\254\255',require'ffi',string.sub
--     local C=ffi.C
--     local function bom(fp)
--       local res=0
--       local f=win.WideCharToMultiByte(ffi.string(fp,tonumber(C.wcslen(fp))*2),65001)
--       local h=io.open(f,"rb")
--       if h then
--         local s=h:read(3) or '' h:close()
--         if s==efbbbf then res=3 else s=sub(s,1,2) if s==fffe then res=2 elseif s==feff then res=1 end end
--       end
--       return res
--     end
--     return bom(_G.sFuncTbl.fp1)-bom(_G.sFuncTbl.fp2)
--   ```
-- </details>
-- <details><summary>by BOM ffi</summary>
--
--   ``` lua
--     -- by BOM ffi
--     local ffi = require'ffi'
--     local C = ffi.C
--     local NULL = ffi.cast("void*",0)
--     local ibuf=ffi.new"unsigned char[3]"
--     
--     local mode_in = "\114\0\98\0\0" -- "rb" UTF-16LE..'\0'
--     local function bom(fp)
--       local res=0
--       local f_in=assert(C._wfopen(ffi.cast("wchar_t*",fp),ffi.cast("wchar_t*",mode_in)))
--       if f_in~=NULL then
--         ffi.fill(ibuf,3)
--         local n=C.fread(ibuf,1,ffi.sizeof(ibuf),f_in)
--         C.fclose(f_in)
--         local n,b0,b1,b2 = tonumber(n),tonumber(ibuf[0]),tonumber(ibuf[1]),tonumber(ibuf[2])
--         if n==3 and b0==0xef and b1==0xbb and b2==0xbf then res=3
--         elseif n>=2 then
--           if     b0==0xff and b1==0xfe then res=2
--           elseif b0==0xfe and b1==0xff then res=1
--           end
--         end
--       end
--       return res
--     end
--     return bom(_G.sFuncTbl.fp1)-bom(_G.sFuncTbl.fp2)
--   ```
-- </details>
-- <details><summary>by FullPath length</summary>
--
--   ``` lua
--     -- by FullPath length
--     local ffi = require'ffi'
--     local C=ffi.C
--     return tonumber(C.wcslen(_G.sFuncTbl.fp1))-tonumber(C.wcslen(_G.sFuncTbl.fp2))
--   ```
-- </details>
-- <details><summary>by FileName length</summary>
--
--   ``` lua
--     -- by FileName length
--     return _G.sFuncTbl.ln1-_G.sFuncTbl.ln2
--   ```
-- </details>
-- <details><summary>by level Folder</summary>
--
--   ``` lua
--   -- by level Folder
--     local ffi,BS = require'ffi',[[\\]]
--     local C=ffi.C
--     local _,x1 = regex.gsubW(ffi.string(_G.sFuncTbl.fp1,tonumber(C.wcslen(_G.sFuncTbl.fp1))*2),BS,"")
--     local _,x2 = regex.gsubW(ffi.string(_G.sFuncTbl.fp2,tonumber(C.wcslen(_G.sFuncTbl.fp2))*2),BS,"")
--     return x1-x2
--   ```
-- </details>
-- <details><summary>by HEX in FileName</summary>
--
--   ``` lua
--     -- by HEX in FileName
--     local ffi,RE,huge,gsub = require'ffi',regex.new'[0-9A-Fa-f]+$',math.huge,string.gsub
--     local C=ffi.C
--     local function p(s)
--       local num=huge
--       local fp=ffi.string(s,tonumber(C.wcslen(s))*2)
--       local hex=RE:matchW(fp)
--       if hex then num=tonumber(gsub(hex,'\000',''),16) end
--       return num
--     end
--     return p(_G.sFuncTbl.fp1)-p(_G.sFuncTbl.fp2)
--   ```
-- </details>
-- </details>
-- ---
-- Keys: CtrlShiftF3 or from Menu "Sort by"
-- Tip: In the dialog all elements have prompts, press F1 for help
-- Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2240#16

if not (bit and jit) then return end

local F = far.Flags
local guid = "5B40F3FF-6593-48D2-8F78-4A32C8C36BCA"
local uGuid = win.Uuid(guid)
local MenuGuid = "B8B6E1DA-4221-47D2-AB2E-9EC67D0DC1E3"

-- Settings --------------------------------------------------------------------
local ModeNumber = 100110
local GFocus,tSort = 3,{nil,true,0,false,"",false,false,false,4,true,false,"",false,"",false}
local First,AlgSort,Offset,Symbols,DigSort,Digits,DirectSeek,xRegexp,sRegexp,xFunc,sFunc,sRgxTbl,sRgxRet,sRgxTrue = true,tSort[2],tSort[3],tSort[5],tSort[8],tSort[9],tSort[10],tSort[11],tSort[12],tSort[13],tSort[14],{}
local Desc1,Indi1 = "Custom: by Name","!?"
local Indicator = Indi1
local Key = "CtrlShiftF3"
--------------------------------------------------------------------------------

local ffi = require'ffi'
local C = ffi.C
local Flags = C.SORT_STRINGSORT
local DOT,BS = string.byte("."),string.byte("\\")
local maxnum,count,ttime0,count0 = math.pow(10,tSort[9]),0
local re0 = regex.new("\\$(\\d+)")

ffi.cdef[[
wchar_t* wcschr(const wchar_t*, wchar_t);
wchar_t* wcsrchr(const wchar_t*, wchar_t);
wchar_t* wcspbrk(const wchar_t*, const wchar_t*);
]]

local edtFlags = F.DIF_HISTORY+F.DIF_USELASTHISTORY
local Items = {
--[[01]] {F.DI_DOUBLEBOX,    3,1, 65,9, 0, 0,0, 0, "Custom sort by Name. Help: F1"},
--[[02]] {F.DI_CHECKBOX,     5,2, 15,0, 0, 0,0, 0, "O&ffset"},
--[[03]] {F.DI_EDIT,        16,2, 22,0, 0, 0,0, 0, ""},
--[[04]] {F.DI_CHECKBOX,    25,2, 36,0, 0, 0,0, 0, "Sy&mbols"},
--[[05]] {F.DI_EDIT,        37,2, 63,0, 0, "CustomSortByName_Symbols",0, edtFlags, ""},
--[[06]] {F.DI_CHECKBOX,     5,3, 20,0, 0, 0,0, 0, "Ignore &case"},
--[[07]] {F.DI_CHECKBOX,    37,3, 56,0, 0, 0,0, 0, "Ignore &symbols"},
--[[08]] {F.DI_CHECKBOX,     5,4, 15,0, 0, 0,0, 0, "&Digits"},
--[[09]] {F.DI_EDIT,        16,4, 19,0, 0, 0,0, 0, ""},
--[[10]] {F.DI_CHECKBOX,    37,4, 52,0, 0, 0,0, 0, "Direct s&eek"},
--[[11]] {F.DI_CHECKBOX,     5,5, 15,0, 0, 0,0, 0, "Re&gexp"},
--[[12]] {F.DI_EDIT,        16,5, 63,0, 0, "CustomSortByName_Regexp",0, edtFlags, ""},
--[[13]] {F.DI_CHECKBOX,     5,6, 15,0, 0, 0,0, 0, "F&unc()"},
--[[14]] {F.DI_EDIT,        16,6, 63,0, 0, "CustomSortByName_Function",0, edtFlags, ""},
--[[15]] {F.DI_CHECKBOX,     5,8, 15,0, 0, 0,0, 0, "Re&port"},
--[[16]] {F.DI_TEXT,        -1,7,  0,0, 0, 0,0, F.DIF_SEPARATOR,""},
--[[17]] {F.DI_BUTTON,       0,8,  0,0, 0, 0,0, F.DIF_DEFAULTBUTTON+F.DIF_CENTERGROUP,"&Ok"},
--[[18]] {F.DI_BUTTON,       0,8,  0,0, 0, 0,0, F.DIF_CENTERGROUP,"Ca&ncel"}
}

local function ToWChar(str)
  str=win.Utf8ToUtf16(str)
  local res=ffi.new("wchar_t[?]",#str/2+1)
  ffi.copy(res,str)
  return res
end

local function GetStartAndLen(name)
  local ptr = C.wcsrchr(name,BS)
  name = ptr==nil and name or ptr+1
  local len = tonumber(C.wcslen(name))
  if AlgSort then
    if Offset==0 or Offset<=-len then
    elseif Offset<0 then name,len = name+len+Offset,-Offset
    elseif Offset<len then name,len = name+Offset,len-Offset
    else name,len = name+len,0
    end
  else
    ptr = C.wcspbrk(name,Symbols)
    name,len = ptr==nil and name or ptr+1, ptr==nil and len or name+len-ptr
  end
  return name,len
end

local function GetDigits(name,len)
  local num,nm,lastnum,pos,a,b,c = 0,1,maxnum,0
  if DirectSeek then a,b,c = 0,len,1 else a,b,c = len,0,-1 end
  for j=a,b,c do
    local code = name[j]
    if code>=48 and code<=57 then
      if DirectSeek then num=num*10+code-48 else num=num+(code-48)*nm end
      nm = nm*10
      if j==b and nm==maxnum then
        lastnum = num
        if DirectSeek then pos = j+1-Digits else pos=j end
      end
    else
      if nm==maxnum then
        lastnum = num
        if DirectSeek then pos = j-Digits else pos=j+1 end
        break
      end
      num,nm = 0,1
    end
  end
  return lastnum,name+pos,len-pos
end

local Compare = function(p1,p2)
  count = count+1
  local st1,len1 = GetStartAndLen(p1.FileName)
  local st2,len2 = GetStartAndLen(p2.FileName)
  if DigSort then
    local res1 = GetDigits(st1,len1)
    local res2 = GetDigits(st2,len2)
    local res = res1-res2
    if res~=0 then
      return res
    else
      return -2 + C.CompareStringW(C.LOCALE_USER_DEFAULT,Flags,st1,len1,st2,len2)
    end
  elseif xRegexp then
    local function sRegFind(st,ln)
      local fname = ffi.string(st,ln*2)
      if sRgxRet then
        local t={}
        if sRgxTrue then
          t = {sRegexp:matchW(fname)}
        else
          for i=1,#sRgxTbl do t[i]=sRgxTbl[i]:matchW(fname) end
        end
        st = re0:gsub(sRgxRet,function(n) return t[tonumber(n)] end)
      else
        st = sRegexp:matchW(fname)
      end
      if st then
        ln = #st/2+1
        local s = ffi.new("wchar_t[?]",ln)
        ffi.copy(s,st)
        st = s
      end
      return st,ln
    end
    local st10,len10 = sRegFind(st1,len1)
    local st20,len20 = sRegFind(st2,len2)
    if not st10 and not st20 then return -2 + C.CompareStringW(C.LOCALE_USER_DEFAULT,Flags,st1,len1,st2,len2)
    elseif st10 and not st20 then return -1
    elseif not st10 and st20 then return  1
    elseif st10 and st20 then return -2 + C.CompareStringW(C.LOCALE_USER_DEFAULT,Flags,st10,len10,st20,len20)
    end
  elseif xFunc then
    _G.sFuncTbl = {fp1=p1.FileName,fp2=p2.FileName,st1=st1,ln1=len1,st2=st2,ln2=len2}
    return sFunc()
  else
    return -2 + C.CompareStringW(C.LOCALE_USER_DEFAULT,Flags,st1,len1,st2,len2)
  end
end

local ttSort={}

local function DlgProc(hDlg,Msg,Param1,Param2)
  local function SetAlg()
    hDlg:send(F.DM_SETCHECK,2,ttSort[2] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_SETCHECK,4,ttSort[4] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_ENABLE,3,ttSort[2] and 1 or 0)
    hDlg:send(F.DM_ENABLE,5,ttSort[2] and 0 or 1)
  end
  local function Set2()
    hDlg:send(F.DM_SETCHECK,8,ttSort[8] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_SETCHECK,11,ttSort[11] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_SETCHECK,13,ttSort[13] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_ENABLE,9,ttSort[8] and 1 or 0)
    hDlg:send(F.DM_ENABLE,10,ttSort[8] and 1 or 0)
    hDlg:send(F.DM_ENABLE,12,ttSort[11] and 1 or 0)
    hDlg:send(F.DM_ENABLE,14,ttSort[13] and 1 or 0)
  end
  local function SetAlg2(p1,p2)
    if p2 then
      ttSort[8],ttSort[11],ttSort[13] = false,false,false
      ttSort[p1]=true
      Set2()
    else
      ttSort[p1]=false
      hDlg:send(F.DM_ENABLE,p1+1,0)
      if p1==8 then hDlg:send(F.DM_ENABLE,10,0) end
    end
  end
  if Msg==F.DN_INITDIALOG then
    for i=2,#Items-3 do ttSort[i]=tSort[i] end
    SetAlg()
    hDlg:send(F.DM_SETTEXT,3,ttSort[3])
    hDlg:send(F.DM_SETCHECK,6,ttSort[6] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_SETCHECK,7,ttSort[7] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_SETTEXT,9,ttSort[9])
    ttSort[5] = tostring(hDlg:send(F.DM_GETTEXT,5))
    ttSort[12] = tostring(hDlg:send(F.DM_GETTEXT,12))
    ttSort[14] = tostring(hDlg:send(F.DM_GETTEXT,14))
    Set2()
    hDlg:send(F.DM_SETCHECK,10,ttSort[10] and F.BSTATE_CHECKED or F.BSTATE_UNCHECKED)
    hDlg:send(F.DM_SETFOCUS,GFocus)
  elseif Msg==F.DN_BTNCLICK and Param1==2 then   -- [x] Offset
    ttSort[2] = Param2~=0 ttSort[4] = not ttSort[2] SetAlg()
    GFocus = ttSort[2] and 3 or 5
    hDlg:send(F.DM_SETFOCUS,GFocus)
  elseif Msg==F.DN_BTNCLICK and Param1==4 then   -- [x] Symbols
    ttSort[4] = Param2~=0 ttSort[2] = not ttSort[4] SetAlg()
    GFocus = ttSort[2] and 3 or 5
    hDlg:send(F.DM_SETFOCUS,GFocus)
  elseif Msg==F.DN_EDITCHANGE and Param1==3 then -- Offset changed
    ttSort[3] = tonumber(hDlg:send(F.DM_GETTEXT,3)) or ttSort[3]
  elseif (Msg==F.DN_EDITCHANGE or Msg==F.DN_LISTCHANGE) and Param1==5 then -- Symbols changed
    ttSort[5] = tostring(hDlg:send(F.DM_GETTEXT,5)) or ttSort[5]
  elseif Msg==F.DN_BTNCLICK and Param1==6 then   -- [x] IgnoreCase
    ttSort[6] = Param2~=0 -- C.NORM_IGNORECASE
  elseif Msg==F.DN_BTNCLICK and Param1==7 then   -- [x] IgnoreSymbols
    ttSort[7] = Param2~=0 -- C.NORM_IGNORESYMBOLS
  elseif Msg==F.DN_BTNCLICK and Param1==8 then   -- [x] Digits
    SetAlg2(Param1,Param2~=0)
    GFocus = ttSort[8] and 9 or 11
    hDlg:send(F.DM_SETFOCUS,GFocus)
  elseif Msg==F.DN_EDITCHANGE and Param1==9 then -- Digits changed
    ttSort[9] = tonumber(hDlg:send(F.DM_GETTEXT,9)) or ttSort[9]
    maxnum = math.pow(10,ttSort[9])
  elseif Msg==F.DN_BTNCLICK and Param1==10 then   -- [x] DirectSeek
    ttSort[10] = Param2~=0
  elseif Msg==F.DN_BTNCLICK and Param1==11 then   -- [x] Regexp
    SetAlg2(Param1,Param2~=0)
    GFocus = ttSort[11] and 12 or 13
    hDlg:send(F.DM_SETFOCUS,GFocus)
  elseif (Msg==F.DN_EDITCHANGE or Msg==F.DN_LISTCHANGE) and Param1==12 then -- Regexp changed
    ttSort[12] = tostring(hDlg:send(F.DM_GETTEXT,12)) or ttSort[12]
  elseif Msg==F.DN_BTNCLICK and Param1==13 then   -- [x] Func()
    SetAlg2(Param1,Param2~=0)
    GFocus = ttSort[13] and 14 or 15
    hDlg:send(F.DM_SETFOCUS,GFocus)
  elseif (Msg==F.DN_EDITCHANGE or Msg==F.DN_LISTCHANGE) and Param1==14 then -- Func() changed
    ttSort[14] = tostring(hDlg:send(F.DM_GETTEXT,14)) or ttSort[14]
  elseif Msg==F.DN_BTNCLICK and Param1==15 then   -- [x] Report
    ttSort[15] = Param2~=0
  elseif Msg==F.DN_GOTFOCUS then
    if Param1>2 and Param1<#Items-2 then GFocus=Param1 end
  else
    return
  end
  return true
end

Panel.LoadCustomSortMode(ModeNumber,{Description=Desc1;Indicator=Indicator;Compare=Compare})

Macro {
  description = Desc1; area = "Shell Menu"; key = Key.." Enter MsLClick";
  condition = function(key) return Area.Shell and key==Key or Area.Menu and Menu.Id==MenuGuid and Menu.Value:match(Desc1) and (key=="Enter" or key=="MsLClick") end;
  action=function()
    if Area.Menu then Keys("Esc") end
    if far.Dialog(uGuid,-1,-1,69,11,nil,Items,nil,DlgProc)==#Items-1 then
      local res=false for i=2,#Items-3 do res = res or tSort[i]~=ttSort[i] tSort[i]=ttSort[i] end
      if res or First then panel.SetSortOrder(nil,1,bit.band(panel.GetPanelInfo(nil,1).Flags,F.PFLAGS_REVERSESORTORDER)==0) First=false end
      AlgSort,Offset,Symbols,DigSort,Digits,DirectSeek,xRegexp,sRegexp,xFunc,sFunc = tSort[2],tSort[3],ToWChar(tSort[5]),tSort[8],tSort[9],tSort[10],tSort[11],tSort[12],tSort[13],loadstring(tSort[14])
      if xRegexp then
        sRegexp,sRgxRet = regex.match(sRegexp,"^(?:--[^\\n]+?\\n)?(.*?)(?:\\{!:(.*?)\\}|)$")
        if sRegexp:match("%[%[..-%]%]") then sRegexp = regex.gsub(sRegexp,"\\[\\[(.+?)\\]\\]",function(s) return regex.gsub(s,"[^\\|]","\\%1") end) end
        --far.Message(sRegexp,"Regexp",nil,"l")
        for i=1,#sRgxTbl do sRgxTbl[i]=nil end
        local i=0 for v in regex.gmatch(sRegexp,"\\{\\?:(.*?)\\}(?=\\{\\?:|$)") do i=i+1 sRgxTbl[i]=regex.new(v) end
        if not sRgxRet or #sRgxTbl==0 then sRegexp,sRgxTrue = regex.new(sRegexp),true else sRgxTrue=false end
      end
      Flags = tSort[6] and bit.bor(Flags,C.NORM_IGNORECASE) or bit.band(Flags,bit.bnot(C.NORM_IGNORECASE))
      Flags = tSort[7] and bit.bor(Flags,C.NORM_IGNORESYMBOLS) or bit.band(Flags,bit.bnot(C.NORM_IGNORESYMBOLS))
      count = 0
      local ttime=far.FarClock()
      Panel.LoadCustomSortMode(ModeNumber,{Description=Desc1;Indicator=Indicator;Compare=Compare})
      Panel.SetCustomSortMode(ModeNumber,0)
      ttime = far.FarClock()-ttime
      local report = "Curr count: "..count.."  mcs: "..ttime
      if count0 then
        report = report.."\nPrev count: "..count0.."  mcs: "..ttime0.."\nDifference:"..string.format("%+"..(string.len(tostring(count0))+1).."d",count-count0).."  mcs:"..string.format("%+"..(string.len(tostring(ttime0))+1).."d",ttime-ttime0)
      end
      count0,ttime0 = count,ttime
      if tSort[15] then
        panel.RedrawPanel(nil,1)
        far.Message(report,"Report",nil,"l")
      end
    end
  end;
}

Macro {
  description = Desc1.." - Help"; area = "Dialog"; key = "F1";
  condition=function() return Area.Dialog and Dlg.Id==guid end;
  action=function()
    if Dlg.CurPos<=3 then far.Message("Offset for capture substring in FileName","Help: Offset")
    elseif Dlg.CurPos<=5 then far.Message("Substring will be captured after these symbols","Help: Symbols")
    elseif Dlg.CurPos==6 then far.Message("Case of letters in FileName will be ignored","Help: Ignore case")
    elseif Dlg.CurPos==7 then far.Message("Symbols like &()[]{}-!?.,:; and other will be ignored","Help: Ignore symbols")
    elseif Dlg.CurPos<=9 then far.Message("Number of digits for sorting FileName by captured digits","Help: Digits")
    elseif Dlg.CurPos==10 then far.Message("Search direction of digits: [x] Forward seek, [ ] Reverse seek","Help: Direct seek")
    elseif Dlg.CurPos<=12 then far.Message("Use regex syntax for regexp\n\nFor comment use design like:\n1st line: -- comment\n2nd line: regexp    \n\nAdditionally for change the sort order,\nyou can use non standard design like:\n\nmultigroup_pattern{!:$2$1}\nor\n{?:singlegroup_pattern}{?:singlegroup_pattern}{!:$2$1}\n\nIn the second case, groups are searched independently.","Help: Regexp")
    elseif Dlg.CurPos<=14 then far.Message("_G.sFuncTbl.fp1 FullPath1\n_G.sFuncTbl.st1 substring by offset\n_G.sFuncTbl.ln1 length of substring\n\n_G.sFuncTbl.fp2 FullPath2\n_G.sFuncTbl.st2 substring by offset\n_G.sFuncTbl.ln2 length of substring","Help: Func()",nil,"l")
    elseif Dlg.CurPos==15 then far.Message("count - the number of calls the comparison function\ntime  - total time of execution","Help: Report",nil,"l")
    end
  end;
}
