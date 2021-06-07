-- Panel.RAD2M3U.lua
-- v1.0.3
-- [Album Player](http://albumplayer.ru/index.html "Album Player") (APlayer) radio station files converter *.rad,*m3u<=>FolderName.m3u
-- Actions:
-- * M3U: creating a common playlist from RAD and M3U files in a folder and subfolders
-- * RAD: to create RAD and M3U files with folders and subfolders from the common playlist, place the cursor on the playlist and press F2
-- Keys: F2

Macro {
  area="Shell"; key="F2"; description="RAD<=>M3U converter";
  action=function()
    local app,apc = APanel.Path,APanel.Current
    -- read file
    local function fread(f) local x,h = nil,io.open(f,"rb") if h then x=h:read("*all") io.close(h) end return x end
    -- write file
    local function fwrite(s,f) local x,h = nil,io.open(f,"wb") if h then x=h:write(s or "") io.close(h) end return x end
    -- append file
    local function fappend(s,f) local x,h = nil,io.open(f,"ab") if h then x=h:write(s or "") io.close(h) end return x end
    -- delete invisible symbols at the end of a link
    local function fixlink(link) link=string.gsub(link,"[%z\1-\32]+$","") return link end

    local inf="\n#EXTINF:-1,"

    if string.lower(string.sub(apc,-4,-1))==".m3u"
    then  -- restore RAD and M3U files from a common playlist
      local m3uFlg,fpath
      local txt=fread(app.."\\"..apc)
      for fname,link in txt:gmatch("#EXTINF:%-1,(%C-)%c%c-(%C+)") do
        local ext=string.lower(string.sub(fname,-4,-1))
        if     ext==".rad" then
          if fpath and m3uFlg then fappend("\n",fpath) m3uFlg=false end
          fpath=app.."\\"..fname
          win.CreateDir(fname:gsub("\\[^\\]+$",""))
        elseif ext==".m3u" then
          if fpath and m3uFlg then fappend("\n",fpath) else m3uFlg=true end
          fpath=app.."\\"..fname
          win.CreateDir(fname:gsub("\\[^\\]+$",""))
          fwrite("#EXTM3U",fpath)
        end
        if fpath then
          if m3uFlg
          then if ext~=".m3u" then fappend(inf..fname.."\n"..fixlink(link),fpath) end
          else fwrite(fixlink(link),fpath)
          end
        end
      end
      if fpath and m3uFlg then fappend("\n",fpath) m3uFlg=false end
    else  -- create a common playlist from RAD and M3U files
      local m3u,fpath = "#EXTM3U",app.."\\"..app:match("[^\\]+$")..".m3u"
      local offset=string.len(app)+2
      far.RecursiveSearch(app,"*.rad,*.m3u",
        function(item,fullpath)
          if not item.FileAttributes:find("d") and fullpath~=fpath then
            local ext=string.lower(string.sub(fullpath,-4,-1))
            if     ext==".rad" then
              m3u=m3u..inf..string.sub(fullpath,offset,-1).."\n"..fixlink(fread(fullpath))
            elseif ext==".m3u" then
              m3u=m3u..inf..string.sub(fullpath,offset,-1).."\n#"
              for title,link in fread(fullpath):gmatch("#EXTINF:%-1,(%C-)%c%c-(%C+)") do
                m3u=m3u..inf..fixlink(title).."\n"..fixlink(link)
              end
            end
          end
        end,
        7
      )
      fwrite(m3u.."\n",fpath)
    end
  end
}
