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


## [CommandLineF4.lua](https://github.com/z0hm/far-scripts/blob/master/CommandLineF4.lua "CommandLineF4.lua")   *(2369 bytes)*

  v1.1.1

  Editing command line content in the editor

  Keys: <kbd>F4</kbd> in Panel with not empty command line, <kbd>F2</kbd> in editor for save text to command line




## [Dialog.Maximize.moon](https://github.com/z0hm/far-scripts/blob/master/Dialog.Maximize.moon "Dialog.Maximize.moon")   *(11220 bytes)*

  v1.1.5

  Resizing dialogs, aligning the positions of dialog elements

  Keys: <kbd>F2</kbd> in dialogs or <kbd>CtrlAltRight</kbd> or <kbd>CtrlAltLeft</kbd>

  Url: https://forum.farmanager.com/viewtopic.php?p=148024#p148024

  Based on https://forum.farmanager.com/viewtopic.php?p=146816#p146816




## [Editor.CyrSpaceHighlighting.moon](https://github.com/z0hm/far-scripts/blob/master/Editor.CyrSpaceHighlighting.moon "Editor.CyrSpaceHighlighting.moon")   *(5189 bytes)*

  v1.1.3.1

  Highlighting Cyrillic and space symbols

  ![Highlight ON](http://i62.fastpic.ru/big/2014/0603/18/0f2bf6171580c92d52a09ead18b86e18.png)

  ![Highlight ON](http://i.piccy.info/i9/7223f0c8d8e8b124e0849af1cdd4e5de/1587815203/7934/1374955/2020_04_25_134822.png)

  ![Highlight OFF](http://i.piccy.info/i9/953bb710b86c522d71cd4b4211d3f616/1587815270/7789/1374955/2020_04_25_134843.png)

  Required: MessageX.lua in modules folder

  Keys: <kbd>F3</kbd>

  author zg, co-author AleXH

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=48136&start=960#17

  prototype: https://forum.farmanager.com/viewtopic.php?f=60&t=8674




## [Editor.FilterDuplicatesFileNames.lua](https://github.com/z0hm/far-scripts/blob/master/Editor.FilterDuplicatesFileNames.lua "Editor.FilterDuplicatesFileNames.lua")   *(11700 bytes)*

  v1.2.3

  Filter Duplicates File Names with complex logic

  ![Editor.FilterDuplicatesFileNames](http://i.piccy.info/i9/ef8a00f82a655df0f6058b78be55fc5f/1585847959/7483/1370793/2020_04_02_201451.png)

  Keys: launch from Macro Browser alt.

  Tip: In the dialog all elements have prompts, press <kbd>F1</kbd> for help




## [Editor.LatCyrMixHighlighting.moon](https://github.com/z0hm/far-scripts/blob/master/Editor.LatCyrMixHighlighting.moon "Editor.LatCyrMixHighlighting.moon")   *(5055 bytes)*

  v1.1.3.1

  Highlighting mixed Latin and Cyrillic letters in the editor

  ![Mixed latin and cyrillic letters](http://i.piccy.info/i9/3a9b767a03d92b5970f5be786dca6d04/1585845951/933/1370793/2020_04_02_194011.png)

  Required: MessageX.lua in modules folder

  Keys: <kbd>F3</kbd>

  author zg, co-author AleXH

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2460#3

  prototype: https://forum.farmanager.com/viewtopic.php?f=60&t=8674




## [Editor.SearchLinesWithMinMaxLength.lua](https://github.com/z0hm/far-scripts/blob/master/Editor.SearchLinesWithMinMaxLength.lua "Editor.SearchLinesWithMinMaxLength.lua")   *(2410 bytes)*

  v1.3.1

  Search for lines with minimum and maximum length, excluding the first and last lines, they are often empty

  Required: MessageX.lua in the modules folder

  Keys: <kbd>F3</kbd>




## [Editor.TagGoto.lua](https://github.com/z0hm/far-scripts/blob/master/Editor.TagGoto.lua "Editor.TagGoto.lua")   *(5924 bytes)*

  v1.1

  Tag navigation in files opened in the editor: [dgmsx]?html?, xslt?, [xy]ml

  Required: plugin LFSearch (LuaFAR Search) by Shmuel

  Keys: <kbd>Alt[JKL]</kbd>




## [FarUpdate.lua](https://github.com/z0hm/far-scripts/blob/master/FarUpdate.lua "FarUpdate.lua")   *(11000 bytes)*

  v1.7.5

  Opening changelog and updating Far Manager to any version available on the site

  ![changelog](http://i.piccy.info/i9/853d060868f60a97875406b017505b28/1586274980/29703/1371677/2020_04_07_182023.png)

  ![update dialog](http://i.piccy.info/i9/2926dae366e86ea1eacadc3a55508f5d/1585846888/29457/1370793/2020_04_02_195019.png)

  Far: press **[ Reload Last ]** to reload the list with files

  GitHub: press **[ More >> ]** to get more files

  GitHub: press **[ Reload Last ]** to reload last page with files

  GitHub: press **[ Reload All ]** to reload all pages

  When you run the macro again, the build will be taken from the current position in Far.changelog

  Required: curl.exe, nircmd.exe, 7z.exe, requires tuning for local conditions

  Keys: launch from Macro Browser alt.

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=700#19




## [MessageX.lua](https://github.com/z0hm/far-scripts/blob/master/MessageX.lua "MessageX.lua")   *(8290 bytes)*

  v0.6.7.5

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




## [Panel.CustomSortByAttributes.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.CustomSortByAttributes.lua "Panel.CustomSortByAttributes.lua")   *(10276 bytes)*

  v2.0

  Panel files sorting by attributes

  ![Panel.CustomSortByAttributes](http://i.piccy.info/i9/e4a7f377afa812d28e195dbae27e802b/1585895856/14743/1370861/2020_04_03_093318.png)

  Keys: <kbd>CtrlShiftF3</kbd> or from Menu "Sort by"

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2240#16




## [Panel.CustomSortByName.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.CustomSortByName.lua "Panel.CustomSortByName.lua")   *(18080 bytes)*

  v1.1

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




## [Panel.CustomSortOther.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.CustomSortOther.lua "Panel.CustomSortOther.lua")   *(992 bytes)*

  v1.0

  Custom panel file sorts: by Name with StrCmpLogicalW, by FullPath length

  Keys: <kbd>CtrlShiftF3</kbd> or from Menu "Sort by"




## [Panel.Files2HEX_ffi.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.Files2HEX_ffi.lua "Panel.Files2HEX_ffi.lua")   *(2690 bytes)*

  v1.0

  (un)HEX selected files, VERY FAST!

  Keys: launch from Macro Browser alt.

  author Shmuel, co-author AleXH




## [Panel.LYNX-motion.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.LYNX-motion.lua "Panel.LYNX-motion.lua")   *(2687 bytes)*

  v1.0

  Extended lynx-motion style

  Very convenient navigation in panels with elevators through empty subfolders and etc.

  Keys: <kbd>Left</kbd> <kbd>Right</kbd> <kbd>Enter</kbd>




## [Panel.RAD2M3U.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.RAD2M3U.lua "Panel.RAD2M3U.lua")   *(1744 bytes)*

  v1.0.1

  [Album Player](http://albumplayer.ru/index.html "Album Player") (APlayer) radio station files converter *.rad<=>FolderName.m3u

  Actions:

  1. M3U: &#9679; Creating a playlist from rad files in a folder and subfolders

  2. RAD: &#9679; To create rad files with folders and subfolders from the playlist, place the cursor on the playlist and press <kbd>F2</kbd>

  Keys: <kbd>F2</kbd>




## [Panel.SelectBOM.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.SelectBOM.lua "Panel.SelectBOM.lua")   *(5653 bytes)*

  v1.3

  Selection files with BOM

  Keys: launch from Macro Browser alt.

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2280#12




## [Panel.SelectDuplicatesFileNames.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.SelectDuplicatesFileNames.lua "Panel.SelectDuplicatesFileNames.lua")   *(11530 bytes)*

  v13.2.4

  Select Duplicates File Names in Branch panel with complex logic

  ![Panel.SelectDuplicatesFileNames](http://i.piccy.info/i9/7a5542e442b1ee61b39f6f9ad8dcae63/1585894944/7348/1370861/2020_04_03_091759.png)

  Keys: launch from Macro Browser alt.

  Tip: In the dialog all elements have prompts, press <kbd>F1</kbd> for help




## [Panel.ShiftF[56].lua](https://github.com/z0hm/far-scripts/blob/master/Panel.ShiftF[56].lua "Panel.ShiftF[56].lua")   *(3080 bytes)*

  v1.3.2

  Extend Panel (Shift)?F[56] Dialog

  Required: FAR3 build >= 5467

  Keys: none, to use put in the scripts folder




## [Panel.VisualCompare.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.VisualCompare.lua "Panel.VisualCompare.lua")   *(6132 bytes)*

  v.1.8.3

  Visual Compare files or folders for panels: Files, Branch, Temporary, Arclite, Netbox, Observer, TorrentView.

  Keys: <kbd>CtrlAltC</kbd>

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2080#6




## [RESearch.Grep.lua](https://github.com/z0hm/far-scripts/blob/master/RESearch.Grep.lua "RESearch.Grep.lua")   *(3717 bytes)*

  v1.4.2

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




## [btpolicy.xml.lua](https://github.com/z0hm/far-scripts/blob/master/btpolicy.xml.lua "btpolicy.xml.lua")   *(2990 bytes)*

  v1.0

  Create btpolicy.xml for uTorrent, with priority peering zone (example for Belarus users)

  Keys: launch from Macro Browser alt.




## [iptv.lua](https://github.com/z0hm/far-scripts/blob/master/iptv.lua "iptv.lua")   *(1965 bytes)*

  v1.0

  Combining free, frequently updated iptv sheets into one My.m3u, duplicate links removed

  Launch: in cmdline Far.exe: lua:@iptv.lua, or lfjit.exe iptv.lua, or lflua.exe iptv.lua


