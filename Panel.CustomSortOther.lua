-- Panel.CustomSortOther.lua
-- v1.0
-- Custom panel file sorts: by Name with StrCmpLogicalW, by FullPath length
-- Keys: CtrlShiftF3 or from Menu "Sort by"

local ffi=require'ffi'
local C=ffi.C
local Key="CtrlShiftF3"

local desc111="Custom: by FullPath length"
Panel.LoadCustomSortMode (111, {
  Description=desc111; Indicator="lL";
  Compare=function(p1,p2)
    local l=C.wcslen(p1.FileName)-C.wcslen(p2.FileName)
    return l<0 and -1 or l>0 and 1 or 0
  end;
})

Macro {
  description=desc111; area="Shell"; key=Key;
  action=function() Panel.SetCustomSortMode(111,0) end;
}

local shlwapi=ffi.load("shlwapi")
local desc112="Custom: by Name with StrCmpLogicalW"
Panel.LoadCustomSortMode (112, {
  Description=desc112;
  Compare=function(pi1,pi2)
  return shlwapi.StrCmpLogicalW(pi1.FileName, pi2.FileName)
  end;
  Indicator="bB";
})

Macro {
  description=desc112; area="Shell"; key=Key;
  action=function() Panel.SetCustomSortMode(112,0) end;
}
