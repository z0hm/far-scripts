-- Panel.RAD2M3U.lua
-- v1.0
-- Functions:
--    Creating a playlist from rad files in a folder and subfolders.
--    To create rad files with folders and subfolders from the playlist, place the cursor on the playlist and press F2.
-- Keys: F2

Macro {
  area="Shell"; key="F2"; description="RAD<=>M3U";
  action=function()
    local app,apc = APanel.Path,APanel.Current
    -- read file
    local fread = function(f) local h,x = io.open(f,"rb") if h then x=h:read("*all") io.close(h) end return x end
    -- write file
    local fwrite = function(s,f) s = s or "" local h,x = io.open(f,"wb") if h then x=h:write(s) io.close(h) end return x end
    -- delete invisible symbols at the end of a link
    local fixlink = function(link)
      while true do if string.byte(string.sub(link,-1,-1))<=32 then link=string.sub(link,1,-2) else break end end
      return link
    end

    if string.sub(apc,-4,-1)==".m3u" then
      for fname,link in fread(app.."\\"..apc):gmatch("#EXTINF:(%C-)%c%c-(%C+)") do
        if string.sub(fname,-4,-1)==".rad" then
          win.CreateDir(fname:gsub("\\[^\\]+$",""))
          fwrite(fixlink(link),app.."\\"..fname)
        else break
        end
      end
    else
      local m3u="#EXTM3U"
      local offset=string.len(app)+2
      far.RecursiveSearch(app,"*.rad",
        function(item,fullpath)
          if not item.FileAttributes:find("d") then
            local link=fread(fullpath)
            m3u=m3u.."\n#EXTINF:"..string.sub(fullpath,offset,-1).."\n"..fixlink(link)
          end
        end,
        7
      )
      fwrite(m3u,app.."\\"..app:match("[^\\]+$")..".m3u")
    end
  end
}
