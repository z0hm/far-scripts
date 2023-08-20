-- CommandLineF4.lua
-- v1.1.2
-- Editing command line content in the editor
-- Keys: F4 in Panel with not empty command line, F2 in editor for save text to command line

local function fwrite(s,f) local x,h = nil,io.open(f,"wb") if h then x=h:write(s or "") io.close(h) end return x end

local F = far.Flags
local name = "far.xxxxxx.cmd"

local ffi = require'ffi'
local C = ffi.C
local table = table
local tinsert = table.insert

Macro {
 area="Shell"; key="F4"; flags="NotEmptyCommandLine"; description="Command Line -> Editor";
 action = function()
  local pc=ffi.cast("struct PluginStartupInfo*",far.CPluginStartupInfo()).PanelControl
  local l,x = "",panel.GetCmdLinePos(-1)
  local ln=pc(PANEL_ACTIVE,"FCTL_GETCMDLINE",0,nil)
  local cl=ffi.new("wchar_t[?]",ln)
  pc(PANEL_ACTIVE,"FCTL_GETCMDLINE",ln,cl)
  local cw=ffi.string(cl,(ln-1)*2)
  local f = win.GetEnv("TEMP").."\\"..name
  fwrite(cw,f)
  cw=ffi.string(cl,x*2)
  local _,y = regex.gsubW(cw,"\n","\n")
  cw=regex.matchW(cw,"(?:^|\n)(.+?)$")
  if cw then x=#cw/2 else x=1 end
  editor.Editor(f,nil,0,0,-1,-1,bit64.bor(F.EF_NONMODAL,F.EF_IMMEDIATERETURN,F.EF_OPENMODE_USEEXISTING),y+1,x,1200)
 end;
}

Macro {
 area="Editor"; key="F2"; description="Command Line <- Editor";
 condition = function() return editor.GetFileName():match("[^\\]+$")==name end;
 action = function()
  local text,len,nw,x,l = "",0,"\10\0" -- win.Utf8ToUtf16("\n")
  local pc=ffi.cast("struct PluginStartupInfo*",far.CPluginStartupInfo()).PanelControl
  local ec=ffi.cast("struct PluginStartupInfo*",far.CPluginStartupInfo()).EditorControl
  local ei=ffi.new("struct EditorInfo")
  ei.StructSize=ffi.sizeof(ei)
  if ec(-1,"ECTL_GETINFO",0,ei) then
    local y=tonumber(ei.CurLine)
    x=tonumber(ei.CurPos)
    l=tonumber(ei.TotalLines)-1
    local t,ln = {}
    local egs=ffi.new("struct EditorGetString")
    egs.StructSize=ffi.sizeof(egs)
    for i=0,l do
      if i==y then x=x+len/2+y end
      egs.StringNumber=i
      if ec(-1,"ECTL_GETSTRING",0,egs) then
        ln=egs.StringLength*2
        len=len+ln
        tinsert(t,ffi.string(egs.StringText,ln))
      end
    end
    text=table.concat(t,nw)
  end
  editor.Quit(-1)
  local cl=ffi.new("wchar_t[?]",len/2+l+1)
  ffi.copy(cl,text)
  pc(PANEL_ACTIVE,"FCTL_SETCMDLINE",0,cl)
  pc(PANEL_ACTIVE,"FCTL_SETCMDLINEPOS",x,nil)
 end;
}
