# [far-scripts](https://github.com/z0hm/far-scripts "far-scripts")


lua and moon scripts, macros repository for [Far Manager 3.0](https://farmanager.com/ "File Manager for Windows")

Far Manager is powerful files and archives manager and first choice Admins for Windows OSes.
Far Manager works in text mode and provides a simple and intuitive interface
for performing most of the necessary actions: viewing files and directories;
editing, copying and renaming files; and MANY other actions.

Far Manager has a built-in scripting languages: [lua](https://www.lua.org/ "Lua scripting language")
and [moon](https://moonscript.org/ "MoonScript language"), which allows you to solve
a very wide range of tasks using the Far and Windows API's.


## A brief summary of scripts in the repository:


[&nbsp;](#user-content-commandlinef4lua)

## [CommandLineF4.lua](https://github.com/z0hm/far-scripts/blob/master/CommandLineF4.lua "CommandLineF4.lua")

  *v1.1.1 (2369 bytes, changed 2020-04-09 09:55)*

  Editing command line content in the editor

  Keys: <kbd>F4</kbd> in Panel with not empty command line, <kbd>F2</kbd> in editor for save text to command line




[&nbsp;](#user-content-dialogmaximizemoon)

## [Dialog.Maximize.moon](https://github.com/z0hm/far-scripts/blob/master/Dialog.Maximize.moon "Dialog.Maximize.moon")

  *v1.1.6 (11312 bytes, changed 2020-05-31 08:54)*

  Resizing dialogs, aligning the positions of dialog elements

  Keys: <kbd>F2</kbd> in dialogs or <kbd>CtrlAltRight</kbd> or <kbd>CtrlAltLeft</kbd>

  Url: https://forum.farmanager.com/viewtopic.php?p=148024#p148024

  Based on https://forum.farmanager.com/viewtopic.php?p=146816#p146816




[&nbsp;](#user-content-editorcyrspacehighlightingmoon)

## [Editor.CyrSpaceHighlighting.moon](https://github.com/z0hm/far-scripts/blob/master/Editor.CyrSpaceHighlighting.moon "Editor.CyrSpaceHighlighting.moon")

  *v1.1.3.2 (5234 bytes, changed 2020-07-02 08:58)*

  Highlighting Cyrillic and space symbols

  ![Highlight ON](http://i62.fastpic.ru/big/2014/0603/18/0f2bf6171580c92d52a09ead18b86e18.png)

  ![Highlight ON](http://i.piccy.info/i9/7223f0c8d8e8b124e0849af1cdd4e5de/1587815203/7934/1374955/2020_04_25_134822.png)

  ![Highlight OFF](http://i.piccy.info/i9/953bb710b86c522d71cd4b4211d3f616/1587815270/7789/1374955/2020_04_25_134843.png)

  Required: MessageX.lua in modules folder

  Keys: <kbd>F3</kbd>

  author zg, co-author AleXH

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=48136&start=960#17

  prototype: https://forum.farmanager.com/viewtopic.php?f=60&t=8674




[&nbsp;](#user-content-editorfilterduplicatesfilenameslua)

## [Editor.FilterDuplicatesFileNames.lua](https://github.com/z0hm/far-scripts/blob/master/Editor.FilterDuplicatesFileNames.lua "Editor.FilterDuplicatesFileNames.lua")

  *v1.2.3 (11700 bytes, changed 2020-04-09 09:55)*

  Filter Duplicates File Names with complex logic

  ![Editor.FilterDuplicatesFileNames](http://i.piccy.info/i9/ef8a00f82a655df0f6058b78be55fc5f/1585847959/7483/1370793/2020_04_02_201451.png)

  Keys: launch from Macro Browser alt.

  Tip: In the dialog all elements have prompts, press <kbd>F1</kbd> for help




[&nbsp;](#user-content-editorlatcyrmixhighlightingmoon)

## [Editor.LatCyrMixHighlighting.moon](https://github.com/z0hm/far-scripts/blob/master/Editor.LatCyrMixHighlighting.moon "Editor.LatCyrMixHighlighting.moon")

  *v1.1.3.2 (5100 bytes, changed 2020-07-02 09:02)*

  Highlighting mixed Latin and Cyrillic letters in the editor

  ![Mixed latin and cyrillic letters](http://i.piccy.info/i9/3a9b767a03d92b5970f5be786dca6d04/1585845951/933/1370793/2020_04_02_194011.png)

  Required: MessageX.lua in modules folder

  Keys: <kbd>F3</kbd>

  author zg, co-author AleXH

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2460#3

  prototype: https://forum.farmanager.com/viewtopic.php?f=60&t=8674




[&nbsp;](#user-content-editorreloadlua)

## [Editor.Reload.lua](https://github.com/z0hm/far-scripts/blob/master/Editor.Reload.lua "Editor.Reload.lua")

  *v1.0 (863 bytes, changed 2020-06-09 09:02)*

  Url: http://forum.ru-board.com/topic.cgi?forum=5&topic=31718&start=7640#7




[&nbsp;](#user-content-editorsearchlineswithminmaxlengthlua)

## [Editor.SearchLinesWithMinMaxLength.lua](https://github.com/z0hm/far-scripts/blob/master/Editor.SearchLinesWithMinMaxLength.lua "Editor.SearchLinesWithMinMaxLength.lua")

  *v1.3.2 (2835 bytes, changed 2020-10-17 10:36)*

  Search for lines with minimum and maximum length, excluding the first and last lines, they are often empty

  ![Panel.SelectDuplicatesFileNames](http://i.piccy.info/i9/2fbf64356c455c4f73c6c7a9a79e075c/1602930317/34080/1401072/293632020_10_17_132412.png)

  Press the [ Min ] or [ Max ] button for to go to this line

  Required: MessageX.lua in the modules folder

  Keys: <kbd>F3</kbd>




[&nbsp;](#user-content-editortaggotolua)

## [Editor.TagGoto.lua](https://github.com/z0hm/far-scripts/blob/master/Editor.TagGoto.lua "Editor.TagGoto.lua")

  *v1.1.1 (5835 bytes, changed 2020-10-12 11:30)*

  Tag navigation in files opened in the editor: [dgmsx]?html?, xslt?, [xy]ml

  Required: plugin LFSearch (LuaFAR Search) by Shmuel

  Keys: <kbd>Alt[JKL]</kbd>




[&nbsp;](#user-content-farupdatelua)

## [FarUpdate.lua](https://github.com/z0hm/far-scripts/blob/master/FarUpdate.lua "FarUpdate.lua")

  *v1.7.9 (11063 bytes, changed 2021-04-10 06:17)*

  Opening changelog and updating Far Manager to any version available on the site

  ![changelog](http://i.piccy.info/i9/ff857187ff978fdbe845befda7fbfa4e/1592909758/25212/1384833/2020_06_23_134723.png)

  Far: press **[ Reload Last ]** to reload the list with files

  GitHub: press **[ More >> ]** to get more files

  GitHub: press **[ Reload Last ]** to reload last page with files

  GitHub: press **[ Reload All ]** to reload all pages

  When you run the macro again, the build will be taken from the current position in Far.changelog

  Required: curl.exe, nircmd.exe, 7z.exe, requires tuning for local conditions

  Keys: launch from Macro Browser alt.

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=700#19




[&nbsp;](#user-content-messagexlua)

## [MessageX.lua](https://github.com/z0hm/far-scripts/blob/master/MessageX.lua "MessageX.lua")

  *v0.6.7.6 (8338 bytes, changed 2020-07-02 14:06)*

  Color **MessageX(Msg,Title,Buttons,Flags,HelpTopic,Guid,ExecDelay)** module with support default button assignments

  ![MessageX Dialog](http://i.piccy.info/i9/f5defa4d150c234d882858e3a73978f5/1589987690/2336/1379306/2020_05_20_180740.png)

  Support delay execution in seconds (**ExecDelay**:integer)

  Support flags: **"wlcm"**

  **w** - warning dialog, **l** - left align (default center align), **c** - color mode, **m** - monochrome mode

  without **cm** will be used raw mode

  Tags format: **<#xy>**, **x** - foreground color **0..f**, **y** - background color **0..f**

  **r** - restore default color for foreground/background, **s** - skip, don't change foreground/background color

  Example message string: "aaa<#e1>bbb<#s2>\nccc<#bs>ddd\neee<#rs>fff<#sr>ggg"



  Usage: put **MessageX.lua** to modules folder

  Call in scripts (example):

  ``` lua

    local MessageX = require'MessageX'

    MessageX("aaa <#e2>bbb<#s1>\nccc<#bs> ddd\neee<#9s> fff <#sr> ggg <#ec>hhh","MessageX","&Ok;!Ca&ncel","wc","","",11)

  ```




[&nbsp;](#user-content-panelcustomsortbyattributeslua)

## [Panel.CustomSortByAttributes.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.CustomSortByAttributes.lua "Panel.CustomSortByAttributes.lua")

  *v2.0.1 (11930 bytes, changed 2021-01-17 08:24)*

  Panel files sorting by attributes

  ![Panel.CustomSortByAttributes](http://i.piccy.info/i9/e4a7f377afa812d28e195dbae27e802b/1585895856/14743/1370861/2020_04_03_093318.png)

  Keys: <kbd>CtrlShiftF3</kbd> or from Menu "Sort by"

  Tip: In the dialog all elements have prompts, press <kbd>F1</kbd> for help

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2240#16




[&nbsp;](#user-content-panelcustomsortbynamelua)

## [Panel.CustomSortByName.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.CustomSortByName.lua "Panel.CustomSortByName.lua")

  *v1.1.0.1 (18132 bytes, changed 2020-08-20 20:39)*

  Very powerful panel file sorting

  ![Panel.CustomSortByName](http://i.piccy.info/i9/305c735c17b77b86698f8161f3b6988e/1585847695/9001/1370793/2020_04_02_201018.png)

  <details><summary>Сортировки файлов в панели:</summary>



  1. С вводом Offset при нажатии шорката, если вместо ввода числа нажать Enter, то будет использовано прежнее значение. Стартовое значение (по умолчанию) 0, т.е. обычная сортировка по имени.

  2. C вводом Symbols аналогично п.1, значение по умолчанию "-_ ".

   п.1 и п.2 с игнорированием символов - игнорируется то, что Майкрософт считает символами.

  3. По группе цифр в имени файла с поиском в прямом, либо обратном направлении.

  4. По подстроке, захваченной регэкспом. Регэкспы можно комментировать, в этом случае первую строку начинаем с -- (2-х минусов), далее комментарий, затем перевод строки и на второй строке пишем сам регэксп. Порядок сортировки можно изменить, добавив в конец регэкспа конструкцию {!:...}, где вместо ... указываем порядок возврата захваченных групп, например {!:$3$2$1}. Для поиска каждой группы по всей строке вне зависимости от их позиции, используется конструкция {?:pat1}{?:pat2}{?:pat3}{!:$3$2$1}, где patN - характерный паттерн группы, захватывается первый совпавший.

  5. По функции пользователя. Примеры:

   [x] Offset=0

   [x] Func

  <details><summary>by BOM</summary>



    ``` lua

      -- by BOM

      local function bom(fp)

        local res,efbbbf,fffe,feff,ffi = 0,'\239\187\191','\255\254','\254\255',require'ffi'

        local f=win.WideCharToMultiByte(ffi.string(fp,tonumber(ffi.C.wcslen(fp))*2),65001)

        local h=io.open(f,"rb")

        if h then

          local s=h:read(3) or '' h:close()

          if s==efbbbf then res=3 else s=string.sub(s,1,2) if s==fffe then res=2 elseif s==feff then res=1 end end

        end

        return res

      end

      return bom(_G.sFuncTbl.fp1)-bom(_G.sFuncTbl.fp2)

    ```

  </details>

  <details><summary>by FullPath length</summary>



    ``` lua

      -- by FullPath length

      local ffi = require'ffi'

      return tonumber(ffi.C.wcslen(_G.sFuncTbl.fp1))-tonumber(ffi.C.wcslen(_G.sFuncTbl.fp2))

    ```

  </details>

  <details><summary>by FileName length</summary>



    ``` lua

      -- by FileName length

      return _G.sFuncTbl.ln1-_G.sFuncTbl.ln2

    ```

  </details>

  <details><summary>by level Folder</summary>



    ``` lua

    -- by level Folder

      local ffi,BS = require'ffi',[[\\]]

      local _,x1 = regex.gsubW(ffi.string(_G.sFuncTbl.fp1,tonumber(ffi.C.wcslen(_G.sFuncTbl.fp1))*2),BS,"")

      local _,x2 = regex.gsubW(ffi.string(_G.sFuncTbl.fp2,tonumber(ffi.C.wcslen(_G.sFuncTbl.fp2))*2),BS,"")

      return x1-x2

    ```

  </details>

  <details><summary>by HEX in FileName</summary>



    ``` lua

      -- by HEX in FileName

      local ffi,RE,huge = require'ffi','[0-9A-Fa-f]+$',math.huge

      local function p(s)

        local num=huge

        local fp=ffi.string(s,tonumber(ffi.C.wcslen(s))*2)

        local hex=regex.matchW(fp,RE)

        if hex then num=tonumber(string.gsub(hex,'\000',''),16) end

        return num

      end

      return p(_G.sFuncTbl.fp1)-p(_G.sFuncTbl.fp2)

    ```

  </details>

  </details>

  ---

  Keys: <kbd>CtrlShiftF3</kbd> or from Menu "Sort by"

  Tip: In the dialog all elements have prompts, press <kbd>F1</kbd> for help

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2240#16




[&nbsp;](#user-content-panelcustomsortotherlua)

## [Panel.CustomSortOther.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.CustomSortOther.lua "Panel.CustomSortOther.lua")

  *v1.0.0.1 (1008 bytes, changed 2020-08-20 20:43)*

  Custom panel file sorts: by Name with StrCmpLogicalW, by FullPath length

  Keys: <kbd>CtrlShiftF3</kbd> or from Menu "Sort by"




[&nbsp;](#user-content-panelfiles2hex_ffilua)

## [Panel.Files2HEX_ffi.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.Files2HEX_ffi.lua "Panel.Files2HEX_ffi.lua")

  *v1.0 (2690 bytes, changed 2020-05-21 13:50)*

  (un)HEX selected files, VERY FAST!

  Keys: launch from Macro Browser alt.

  author Shmuel, co-author AleXH




[&nbsp;](#user-content-panellynx-motionlua)

## [Panel.LYNX-motion.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.LYNX-motion.lua "Panel.LYNX-motion.lua")

  *v1.0 (2687 bytes, changed 2020-04-09 09:55)*

  Extended lynx-motion style

  Very convenient navigation in panels with elevators through empty subfolders and etc.

  Keys: <kbd>Left</kbd> <kbd>Right</kbd> <kbd>Enter</kbd>




[&nbsp;](#user-content-panelrad2m3ulua)

## [Panel.RAD2M3U.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.RAD2M3U.lua "Panel.RAD2M3U.lua")

  *v1.0.2 (1741 bytes, changed 2021-04-16 19:10)*

  [Album Player](http://albumplayer.ru/index.html "Album Player") (APlayer) radio station files converter *.rad<=>FolderName.m3u

  Actions:

  * M3U: creating a playlist from rad files in a folder and subfolders

  * RAD: to create rad files with folders and subfolders from the playlist, place the cursor on the playlist and press <kbd>F2</kbd>

  Keys: <kbd>F2</kbd>




[&nbsp;](#user-content-panelselectbomlua)

## [Panel.SelectBOM.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.SelectBOM.lua "Panel.SelectBOM.lua")

  *v1.3 (5653 bytes, changed 2020-05-21 07:09)*

  Selection files with BOM

  Keys: launch from Macro Browser alt.

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2280#12




[&nbsp;](#user-content-panelselectduplicatesfilenameslua)

## [Panel.SelectDuplicatesFileNames.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.SelectDuplicatesFileNames.lua "Panel.SelectDuplicatesFileNames.lua")

  *v1.3.2.5 (11534 bytes, changed 2020-08-20 20:44)*

  Select Duplicates File Names in Branch panel with complex logic

  ![Panel.SelectDuplicatesFileNames](http://i.piccy.info/i9/7a5542e442b1ee61b39f6f9ad8dcae63/1585894944/7348/1370861/2020_04_03_091759.png)

  Keys: launch from Macro Browser alt.

  Tip: In the dialog all elements have prompts, press <kbd>F1</kbd> for help




[&nbsp;](#user-content-panelselectfolderslua)

## [Panel.SelectFolders.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.SelectFolders.lua "Panel.SelectFolders.lua")

  *v1.0 (2153 bytes, changed 2021-05-03 16:38)*

  Extend Select Folders/Files Dialog

  ![changelog](http://i.piccy.info/i9/9de5c58f6ba15652d9ef22cb7ea4e945/1620055603/2539/1427619/2021_05_03_182332.png)

  Keys: <kbd>Grey+</kbd> <kbd>Grey-</kbd> <kbd>CtrlF</kbd>




[&nbsp;](#user-content-panelshiftf[56]lua)

## [Panel.ShiftF[56].lua](https://github.com/z0hm/far-scripts/blob/master/Panel.ShiftF[56].lua "Panel.ShiftF[56].lua")

  *v1.3.2 (3080 bytes, changed 2020-05-21 07:09)*

  Extend Panel (Shift)?F[56] Dialog

  Required: FAR3 build >= 5467

  Keys: none, to use put in the scripts folder




[&nbsp;](#user-content-panelvisualcomparelua)

## [Panel.VisualCompare.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.VisualCompare.lua "Panel.VisualCompare.lua")

  *v1.9.0 (9194 bytes, changed 2021-03-31 17:17)*

  Visual Compare files or folders for panels: Files, Branch, Temporary, Arclite, Netbox, Observer, TorrentView.

  Note: if more than two files are selected on the active panel for comparison, the AdvCmpEx plugin will be called.

  Keys: <kbd>CtrlAltC</kbd>

  The Exchange of lines between files

  Keys: <kbd>Ins</kbd> / <kbd>Del</kbd> - insert / delete line in active file, <kbd>F5</kbd> / <kbd>F6</kbd> - copying with insertion / substitution line

  Keys: <kbd>AltLeft</kbd> / <kbd>AltRight</kbd> - copy line from right file to left file and vice versa

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2080#6




[&nbsp;](#user-content-researchgreplua)

## [RESearch.Grep.lua](https://github.com/z0hm/far-scripts/blob/master/RESearch.Grep.lua "RESearch.Grep.lua")

  *v1.4.2 (3717 bytes, changed 2020-05-17 18:24)*

  Comfortable Grep text from files by search pattern to editor

  ![RESearch Grep](http://i.piccy.info/i9/23f14ef428e4f1d2f1fc1937da2a549c/1442294013/13901/950058/1.png)

  Press <kbd>AltG</kbd>, MacroBrowserAlt.lua file will be opened in the editor and the cursor will be set to this position on hDlg.

  Actions:

  1. Grep: &#9829; Goto this line in this file

  2. Grep: &#9830; Save this line in this file

  3. Grep: &#9827; Save all lines in this file

  4. Grep: &#9824; Save all lines in all files

  Required: plugin RESearch or LFSearch

  Keys: <kbd>AltG</kbd>

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2600#19




[&nbsp;](#user-content-btpolicyxmllua)

## [btpolicy.xml.lua](https://github.com/z0hm/far-scripts/blob/master/btpolicy.xml.lua "btpolicy.xml.lua")

  *v1.0.1 (2992 bytes, changed 2020-06-20 09:14)*

  Create btpolicy.xml for uTorrent, with priority peering zone (example for Belarus users)

  Keys: launch from Macro Browser alt.




[&nbsp;](#user-content-iptvlua)

## [iptv.lua](https://github.com/z0hm/far-scripts/blob/master/iptv.lua "iptv.lua")

  *v1.0.4 (2479 bytes, changed 2021-01-09 09:17)*

  Combining free, frequently updated iptv sheets into one My.m3u, duplicate links removed

  Launch: in cmdline Far.exe: lua:@iptv.lua, or lfjit.exe iptv.lua, or lflua.exe iptv.lua




[&nbsp;](#user-content-moon2lualua)

## [moon2lua.lua](https://github.com/z0hm/far-scripts/blob/master/moon2lua.lua "moon2lua.lua")

  *v1.0 (627 bytes, changed 2020-06-05 16:35)*

  author Shmuel, 28.05.2020

  copy to folder included Moonscript files and run it: lua:@moon2lua.lua

  all Moonscript files will be deleted after convert!




[&nbsp;](#user-content-shell)

# [shell](https://github.com/z0hm/far-scripts/tree/master/shell "shell")


linux shell scripts - sh, bash, dash, sash & etc.


[&nbsp;](#user-content-aq)

## [aq](https://github.com/z0hm/far-scripts/blob/master/shell/aq "aq")

  *21782 bytes, changed 2021-02-11 18:38*

  Bash script - interface for [Album Player Console](http://albumplayer.ru/linux/ap64.tar.gz "apc")

  ![aq script](http://i.piccy.info/i9/ce0b78c019db240a75a21f00089bfd7a/1600717787/7655/1397248/2020_09_21_221429.png)

  ![aq script](http://i.piccy.info/i9/b978141af12e993afff139bb461039db/1600717816/39618/1397248/946922020_09_21_223718.png)

  Commands:

  **.** - play all music files in folder

  **e** - exit, **x** - exit with save path, just **Enter** - repeat last command

  **l** - list files in folder, **a**/**z** - show **previous**/**next** 100 files

  **c&lt;num&gt;** - convert file to **/tmp/out.wav**, **v&lt;num&gt;**/**u&lt;num&gt;** - view ansi/utf-8 file

  **&lt;num&gt;** - play file &lt;num&gt;, **p**/**n** - play **previous**/**next** file, after **Enter** **Enter** ...

  **&lt;num&gt;.&lt;num&gt;:&lt;num&gt;** or **&lt;num&gt;:&lt;num&gt;** - play file number &lt;num&gt; from min:sec

  **&lt;num&gt;.&lt;num&gt;** or **.&lt;num&gt;** - play file &lt;num&gt; from track number &lt;num&gt;, if cue sheet loaded

  **s** - stop playback, **r** - return on jump history, after **Enter** **Enter** ...

  **ro&lt;num&gt;**/**rw&lt;num&gt;** - remount **FAT** partition as **read only**/**writable**, available in **/media** folder only

  **cp&lt;num&gt;** - copy file to **/media/flash**, **mv&lt;num&gt;** - move file, **rm&lt;num&gt;** - remove file

  **ap** - show active player, **ap0** - use auto select player, **ap1**/**ap2** - use player without/with timeshift

  **i** - show name played file and info about it, **i&lt;num&gt;** - show info about file

  **t** - show time and playing time, **tr** - reset playback time

  Url: http://albumplayer.ru/linux/english.html




