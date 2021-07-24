-- Panel.Files2HEX_ffi.lua
-- v1.0.0.1
-- (un)HEX selected files, VERY FAST!
-- Keys: launch from Macro Browser alt.
-- author Shmuel, co-author AleXH

local buf_size=0x10000

local ffi=require 'ffi'
local C=ffi.C
ffi.cdef[[
  typedef struct {int a;} FILE;
  size_t fread(void*,size_t,size_t,FILE*);
  size_t fwrite(const void*,size_t,size_t,FILE*);
  FILE* _wfopen(const wchar_t*,const wchar_t*);
  int fclose(FILE*);
]]

Macro {
  area="Shell"; flags="NoPluginPanels NoFolders"; description="(un)HEX Files ffi";
  action=function()
    local t1=Far.UpTime
    if not APanel.Selected then Panel.Select(0,1,1,0) end
    while APanel.Selected do
      Panel.SetPosIdx(0,1,1)
      local fname = APanel.Path0.."\\"..APanel.Current
      local hex = fname:match("%.hex$") and true or false
      local name_in = win.Utf8ToUtf16(fname).."\0"
      fname = hex and fname:gsub("%.hex$","") or fname..".hex"
      local name_out = win.Utf8ToUtf16(fname).."\0"
      local mode_in,mode_out = "\114\0\98\0\0","\119\0\98\0\0" -- win.Utf8ToUtf16("rb").."\0", win.Utf8ToUtf16("wb").."\0"
      local f_in =assert(C._wfopen(ffi.cast("wchar_t*", name_in), ffi.cast("wchar_t*", mode_in)))
      local f_out=assert(C._wfopen(ffi.cast("wchar_t*", name_out), ffi.cast("wchar_t*", mode_out)))
      if hex
      then
        -- unHEX
        local ibuf,obuf = ffi.new("unsigned char[?]",buf_size*2),ffi.new("unsigned char[?]",buf_size)
        while true do
          local n = tonumber(C.fread(ibuf,1,ffi.sizeof(ibuf),f_in))
          if n==0 then break end
          for i=0,n/2-1 do
            local high = ibuf[i+i]
            local low  = ibuf[i+i+1]
            high = high<65 and high-48 or high-55
            low  = low<65  and low-48  or low-55
            obuf[i] = high*16+low
          end
          C.fwrite(obuf,1,n/2,f_out)
        end
      else
        -- HEX
        local ibuf,obuf = ffi.new("unsigned char[?]",buf_size),ffi.new("unsigned char[?]",buf_size*2)
        while true do
          local n = tonumber(C.fread(ibuf,1,ffi.sizeof(ibuf),f_in))
          if n==0 then break end
          for i=0,n-1 do
            local low  = ibuf[i]%16 --bit.band(ibuf[i],0xf)
            local high = bit.rshift(ibuf[i],4)
            obuf[i+i]   = high<10 and high+48 or high+55
            obuf[i+i+1] = low<10  and low+48  or low+55
          end
          C.fwrite(obuf,1,n+n,f_out)
        end
      end
      C.fclose(f_out)
      C.fclose(f_in)
      Panel.Select(0,0,1,0)
    end
    panel.UpdatePanel(nil,1)
    panel.RedrawPanel(nil,1)
    far.Message("Time: "..(Far.UpTime-t1).." ms","(un)HEX Files")
  end;
}
