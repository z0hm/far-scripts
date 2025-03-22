-- btpolicy.xml.lua
-- v1.0.3
-- Create btpolicy.xml for uTorrent, with priority peering zone (example for Belarus users)
-- Launch: in cmdline Far.exe: lua:@btpolicy.xml.lua or lfjit.exe btpolicy.xml.lua

local function pgus() if panel then panel.GetUserScreen() end end
local function psus() if panel then panel.SetUserScreen() end end

pgus()

local table = table
local tinsert,tremove,tsort = table.insert,table.remove,table.sort

local math = math
local mfloor,mpow = math.floor,math.pow

local string = string
local sfind,sgsub,smatch,sgmatch,sformat,ssub = string.find,string.gsub,string.match,string.gmatch,string.format,string.sub

--local F=far.Flags

local function fread(f) local x,h = nil,io.open(f,"rb") if h then x=h:read("*all") io.close(h) end return x end
local function fwrite(s,f) local x,h = nil,io.open(f,"wb") if h then x=h:write(s or "") io.close(h) end return x end
local function GetPage(x) local s="" if x then s=io.popen("curl.exe "..x,"rb"):read("*all") end return s end
local function bynets(u)
  local s=GetPage(u)
  if not s or not sfind(s,"^[%d%.%/%s%c]+$") then s=GetPage('-k -L --location-trusted '..u) end
  if s and sfind(s,"^[%d%.%/%s%c]+$") then return sgsub(s," ","") end
end

local tmp=win.GetEnv("TEMP")..'\\'
local AppData=win.GetEnv("APPDATA")
local bp="https://ip.datacenter.by/ip/bynets.txt"
local txt=bynets(bp)
if not txt then io.write('\nno ip list\n') return end
local function ips(d1,d2,d3,d4,d5)
  local ip1d=tonumber(d1)*16777216+tonumber(d2)*65536+tonumber(d3)*256+tonumber(d4)
  local ip2d=ip1d+mpow(2,32-tonumber(d5))-1
  local x=ip2d
  local a=mfloor(x/16777216) x=x-a*16777216
  local b=mfloor(x/65536) x=x-b*65536
  local c=mfloor(x/256) x=x-c*256
  local ip2s=a.."."..b.."."..c.."."..x
  local ip1s=d1.."."..d2.."."..d3.."."..d4
  return {d1,d2,d3,d4,d5,ip1d,ip2d,ip1s,ip2s}
end
local tp={}
for d1,d2,d3,d4,d5 in sgmatch(txt,"(%d+)%.(%d+)%.(%d+)%.(%d+)/(%d+)") do tinsert(tp,ips(d1,d2,d3,d4,d5)) end
tsort(tp,function(a,b) return a[6]==b[6] and a[7]<b[7] or a[6]<b[6] end)
-- remove repeats
for i=#tp,2,-1 do if tp[i][6]==tp[i-1][6] then tremove(tp,i) end end

local t=win.GetSystemTime()
txt='<btpolicy version="1.0">\n<revision>'..t.wYear..sformat('%02d',t.wMonth)..sformat('%02d',t.wDay)..'</revision>\n<!-- Private networks -->\n<iprange start="10.0.0.0" end="10.255.255.255" weight="10" />\n<iprange start="172.16.0.0" end="172.31.255.255" weight="10" />\n<iprange start="192.168.0.0" end="192.168.255.255" weight="10" />\n<!-- Peering -->'
local tp2={}
for i=1,#tp do if i>1 and tp[i][6]<=tp[i-1][7]+1 then if tp[i][7]>tp[i-1][7] then tp2[#tp2][2]=tp[i][9] end else tinsert(tp2,{tp[i][8],tp[i][9]}) end end
for i=1,#tp2 do txt=txt..'\n<iprange start="'..tp2[i][1]..'" end="'..tp2[i][2]..'" weight="8" />' end
txt=txt..'\n</btpolicy>'
local src=AppData..'\\uTorrent\\btpolicy.xml'
local old=fread(src)
local size=old and #old/2 or 6000
local new=ssub(txt,291,-1)~=ssub(old,291,-1)
if not old then
  fwrite(txt,src)
  --far.MkLink(src ,tmp.."btpolicy.xml" ,F.LINK_SYMLINKFILE,F.MLF_SHOWERRMSG+F.MLF_HOLDTARGET)
  win.system('ln.exe -s '..src..' '..tmp..'btpolicy.xml')
elseif old and new and #txt>=size then
  --far.CopyToClipboard(txt)
  fwrite(txt,src)
  --far.MkLink(src ,tmp.."btpolicy.xml" ,F.LINK_SYMLINKFILE,F.MLF_SHOWERRMSG+F.MLF_HOLDTARGET)
  win.system('ln.exe -s '..src..' '..tmp..'btpolicy.xml')
  local src0=AppData..'btpolicy0.xml'
  fwrite(old,src0)
  --far.MkLink(src0,tmp.."btpolicy0.xml",F.LINK_SYMLINKFILE,F.MLF_SHOWERRMSG+F.MLF_HOLDTARGET)
  win.system('ln.exe -s '..src0..' '..tmp..'btpolicy0.xml')
elseif old and not new then io.write('\nWithout changes\n')
elseif #txt<size then io.write('\nLength answer <'..size..' bytes\n')
else io.write('\nOther error\n')
end

psus()
