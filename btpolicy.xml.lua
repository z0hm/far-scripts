-- btpolicy.xml.lua
-- v1.0.2
-- Create btpolicy.xml for uTorrent, with priority peering zone (example for Belarus users)
-- Keys: launch from Macro Browser alt.

local function pgus() if panel then panel.GetUserScreen() end end
local function psus() if panel then panel.SetUserScreen() end end

local F=far.Flags

Macro {
area="Common"; flags=""; description="! btpolicy.xml";
action=function()
  pgus()
  local function fread(f) local x,h = nil,io.open(f,"rb") if h then x=h:read("*all") io.close(h) end return x end
  local function fwrite(s,f) local x,h = nil,io.open(f,"wb") if h then x=h:write(s or "") io.close(h) end return x end
  local function GetPage(x) local s="" if x then s=io.popen("curl.exe "..x,"rb"):read("*all") end return s end
  local function bynets(u)
    local s=GetPage(u)
    if s and string.find(s,"^[%d%.%/%s%c]+$") then return string.gsub(s," ","") end
    s=string.find(u,'^https:') and GetPage('-k '..u)
    if s and string.find(s,"^[%d%.%/%s%c]+$") then return string.gsub(s," ","") end
  end
  
  local Temp=win.GetEnv("TEMP")
  local AppData=win.GetEnv("APPDATA")
  -- local bl="https://datacenter.by/ip/local.txt"
  local bp="https://datacenter.by/ip/bynets.txt"
  local txt=bynets(bp)
  if not txt then io.write('\nno ip list\n') psus() return end
  local function ips(d1,d2,d3,d4,d5)
    local ip1d=tonumber(d1)*16777216+tonumber(d2)*65536+tonumber(d3)*256+tonumber(d4)
    local ip2d=ip1d+math.pow(2,32-tonumber(d5))-1
    local x=ip2d
    local a=math.floor(x/16777216) x=x-a*16777216
    local b=math.floor(x/65536) x=x-b*65536
    local c=math.floor(x/256) x=x-c*256
    local ip2s=a.."."..b.."."..c.."."..x
    local ip1s=d1.."."..d2.."."..d3.."."..d4
    return {d1,d2,d3,d4,d5,ip1d,ip2d,ip1s,ip2s}
  end
  local tp={}
  for d1,d2,d3,d4,d5 in string.gmatch(txt,"(%d+)%.(%d+)%.(%d+)%.(%d+)/(%d+)") do table.insert(tp,ips(d1,d2,d3,d4,d5)) end
  table.sort(tp,function(a,b) return a[6]==b[6] and a[7]<b[7] or a[6]<b[6] end)
  -- remove repeats
  for i=#tp,2,-1 do if tp[i][6]==tp[i-1][6] then table.remove(tp,i) end end

  txt='<btpolicy version="1.0">\n<revision>1</revision>\n<!-- Private networks -->\n<iprange start="10.0.0.0" end="10.255.255.255" weight="10" />\n<iprange start="172.16.0.0" end="172.31.255.255" weight="10" />\n<iprange start="192.168.0.0" end="192.168.255.255" weight="10" />\n<!-- Peering -->'
  local tp2={}
  for i=1,#tp do if i>1 and tp[i][6]<=tp[i-1][7]+1 then if tp[i][7]>tp[i-1][7] then tp2[#tp2][2]=tp[i][9] end else table.insert(tp2,{tp[i][8],tp[i][9]}) end end
  for i=1,#tp2 do txt=txt..'\n<iprange start="'..tp2[i][1]..'" end="'..tp2[i][2]..'" weight="8" />' end
  txt=txt..'\n</btpolicy>'
  local src=AppData.."\\uTorrent\\btpolicy.xml"
  local old=fread(src)
  local size=old and #old/2 or 6000
  if not old then
    fwrite(txt,src)
    far.MkLink(src ,Temp.."\\btpolicy.xml" ,F.LINK_SYMLINKFILE,F.MLF_SHOWERRMSG+F.MLF_HOLDTARGET)
  elseif old and txt~=old and #txt>=size then
    --far.CopyToClipboard(txt)
    fwrite(txt,src)
    far.MkLink(src ,Temp.."\\btpolicy.xml" ,F.LINK_SYMLINKFILE,F.MLF_SHOWERRMSG+F.MLF_HOLDTARGET)
    local src0=AppData.."\\uTorrent\\btpolicy0.xml"
    fwrite(old,src0)
    far.MkLink(src0,Temp.."\\btpolicy0.xml",F.LINK_SYMLINKFILE,F.MLF_SHOWERRMSG+F.MLF_HOLDTARGET)
  elseif old and txt==old then io.write('\nWithout changes\n')
  elseif #txt<size then io.write('\nLength answer <'..size..' bytes\n')
  else io.write('\nOther error\n')
  end
  psus()
end
}
