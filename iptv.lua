-- iptv.lua
-- v1.0.1
-- Combining free, frequently updated iptv sheets into one My.m3u, duplicate links removed
-- Launch: in cmdline Far.exe: lua:@iptv.lua, or lfjit.exe iptv.lua, or lflua.exe iptv.lua

-- replace the path with your own
local dir=win.GetEnv('APPDATA')..'\\IP-TV Player\\'
--local dir=win.GetEnv('TEMP')..'\\'
local fname=dir..'My.m3u'
-- list of links to free playlists
local urls={
  --"http://help.a1.by/_files/TelecomTV/TelecomTVpacket/TVPACKET2.m3u",
  "https://iptvm3u.ru/hdlist.m3u",
  "http://iptvm3u.ru/onelist.m3u",
  "https://smarttvnews.ru/apps/iptvchannels.m3u",
  "https://smarttvnews.ru/apps/AutoIPTV.m3u",
  "https://webarmen.com/my/iptv/auto.nogrp.q.m3u"
}
local function fread(f) local x,h = nil,io.open(f,"rb") if h then x=h:read("*all") io.close(h) end return x end
local function fwrite(f,s) local x,h = nil,io.open(f,"wb") if h then x=h:write(s or "") io.close(h) end return x end
local function GetPage(x) local s="" if x then s=io.popen("curl.exe "..x,"rb"):read("*all") end return s end
local pgm={}
for j=1,#urls do
  local i,s = 1,','..j..': '
  local l=GetPage(urls[j]):gsub(", +",",")
  fwrite(dir..urls[j]:match("/([^/]+)$"),l)
  for h,u in (l.."\n"):gmatch("(#EXTINF:.-)%c%c-(%w%w-://%C-)%c%c-") do
    if h and u then table.insert(pgm,{i=i,h=h:gsub(',',s),u=u}) i=i+1 end
  end
end
table.sort(pgm,function(a,b) return a.u<b.u end)
for i=#pgm,2,-1 do if pgm[i].u==pgm[i-1].u then table.remove(pgm,i) end end
local function comp(x) x=x:match(",(%d+: .+)$") return x:find("[Hh][Dd]") and ' '..x or x end
table.sort(pgm,function(a,b) return comp(a.h)<comp(b.h) end)
fwrite(fname.."_",fread(fname)) -- backup old playlist
local h=io.open(fname,"wb") -- create new playlist
h:write('#EXTM3U\n#EXTINF:-1,-= Update: '..os.date("%d.%m.%Y %H:%M")..' =-\nhttp://127.0.0.1/logo.png\n')
h:close()
h=io.open(fname,"ab")
for i=1,#pgm do h:write(pgm[i].h..'\n'..pgm[i].u..'\n') end
h:close()
