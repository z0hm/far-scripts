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


[&nbsp;](#user-content-ansicolorslua)

## [AnsiColors.lua](https://github.com/z0hm/far-scripts/blob/master/AnsiColors.lua "AnsiColors.lua")

  ansicolors.lua

  *v1.1.2 (4974 bytes, changed 2021-09-03 05:20)*

  *SHA-256 `411afd16e69c2b7b4bc63fe0804a5b081a5892dba4c4a3874efa90d04d66edda`*

  Ansi colors for console

  ![Ansi Colors](http://i.piccy.info/i9/5302080eb549332b420c736af1a1a8da/1629987471/985/1439927/180392021_08_26_171510.png)

  Tags format: **<#xya>**, **x** - foreground color **0..f**, **y** - background color **0..f**, **a** - attributes [rbdiul]

  **r** - restore default color for foreground/background, **s** - skip, don't change foreground/background color

  Examples:

  ``` lua

    local colors = require'ansicolors'

    print(colors('%{bright italic red underline}hello'))

    print(colors('<#ecuib>Hello<#rrr>, World!'))

  ```




[&nbsp;](#user-content-chessknightc)

## [ChessKnight.c](https://github.com/z0hm/far-scripts/blob/master/ChessKnight.c "ChessKnight.c")

  *v0.9.2.4 (24115 bytes, changed 2025-02-23 15:22)*

  *SHA-256 `1c3801df371974959e06a816ea84f8f80cad9dd94c068e6ada67f870a5678697`*

  For fast find solution, put the compiled ChessKnight.exe to one folder with ChessKnight.lua




[&nbsp;](#user-content-chessknightlua)

## [ChessKnight.lua](https://github.com/z0hm/far-scripts/blob/master/ChessKnight.lua "ChessKnight.lua")

  *v0.9.2.4 (16006 bytes, changed 2025-03-05 08:49)*

  *SHA-256 `9ee9debacac8475cd41a250791461e945d36f6217ffa525b8133b9b5a5ad614f`*

  Finding the path of the chess knight. The path can be closed. The chessboard can be up to 127x127 in size, with any aspect ratio. Rules: previously visited squares and squares with holes are not available for moving.

  ![Chess Knight](http://i.piccy.info/i9/e36cd250a4b8367f2253c06f4b77c386/1627298655/18083/1436873/2021_07_26_142058.png)

  Launch: in cmdline Far.exe: lua:@ChessKnight.lua




[&nbsp;](#user-content-commandlinef4lua)

## [CommandLineF4.lua](https://github.com/z0hm/far-scripts/blob/master/CommandLineF4.lua "CommandLineF4.lua")

  *v1.1.2 (2399 bytes, changed 2023-08-20 07:32)*

  *SHA-256 `ee1296bf4c455f99d41449810257f76636423e42f35a8272e159467d9f89fd13`*

  Editing command line content in the editor

  Keys: <kbd>F4</kbd> in Panel with not empty command line, <kbd>F2</kbd> in editor for save text to command line




[&nbsp;](#user-content-dialogmaximizemoon)

## [Dialog.Maximize.moon](https://github.com/z0hm/far-scripts/blob/master/Dialog.Maximize.moon "Dialog.Maximize.moon")

  *v1.1.11.6 (13916 bytes, changed 2024-11-28 09:10)*

  *SHA-256 `f6eff85bfa1f90a5c81c0b49ed269daa2bd9f2b258d765fc872c811323f40e48`*

  Resizing dialogs, aligning the positions of dialog elements

  Keys: <kbd>F2</kbd> in dialogs or <kbd>CtrlAltRight</kbd> or <kbd>CtrlAltLeft</kbd>

  Url: https://forum.farmanager.com/viewtopic.php?p=148024#p148024

  Based on https://forum.farmanager.com/viewtopic.php?p=146816#p146816




[&nbsp;](#user-content-editorcyrspacehighlightingmoon)

## [Editor.CyrSpaceHighlighting.moon](https://github.com/z0hm/far-scripts/blob/master/Editor.CyrSpaceHighlighting.moon "Editor.CyrSpaceHighlighting.moon")

  *v1.1.3.6 (5410 bytes, changed 2022-11-10 17:50)*

  *SHA-256 `abc539767024908eabb9fef9751600c7cdc9faf08d2e0b8fbe762d89ba617300`*

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

  *v1.2.3.1 (12524 bytes, changed 2021-07-17 05:03)*

  *SHA-256 `b1b883f7aca361827213dae91b1862c7cf95ae4e13ab03468c8b1c8867af2525`*

  Filter Duplicates File Names with complex logic

  ![Editor.FilterDuplicatesFileNames](http://i.piccy.info/i9/ef8a00f82a655df0f6058b78be55fc5f/1585847959/7483/1370793/2020_04_02_201451.png)

  Keys: launch from Macro Browser alt.

  Tip: In the dialog all elements have prompts, press <kbd>F1</kbd> for help




[&nbsp;](#user-content-editorlatcyrmixhighlightingmoon)

## [Editor.LatCyrMixHighlighting.moon](https://github.com/z0hm/far-scripts/blob/master/Editor.LatCyrMixHighlighting.moon "Editor.LatCyrMixHighlighting.moon")

  *v1.1.3.6 (5290 bytes, changed 2022-11-10 17:51)*

  *SHA-256 `377ddf564e8f64af8afc069f0ccaf4e8a194f6d7311bc91174df20ef6cab8e96`*

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

  *SHA-256 `7c0cdf472de926a76334f580227ceeeca5e597cf7ae32714d8b172ae0f8c0a03`*

  Url: http://forum.ru-board.com/topic.cgi?forum=5&topic=31718&start=7640#7




[&nbsp;](#user-content-editorsearchlineswithminmaxlengthlua)

## [Editor.SearchLinesWithMinMaxLength.lua](https://github.com/z0hm/far-scripts/blob/master/Editor.SearchLinesWithMinMaxLength.lua "Editor.SearchLinesWithMinMaxLength.lua")

  *v1.3.2.1 (2980 bytes, changed 2021-07-12 18:23)*

  *SHA-256 `2dbf102652abcdaef4bce8ed36f64d725497d4259fbff2bfee6fb2394d044f40`*

  Search for lines with minimum and maximum length, excluding the first and last lines, they are often empty

  ![Panel.SelectDuplicatesFileNames](http://i.piccy.info/i9/2fbf64356c455c4f73c6c7a9a79e075c/1602930317/34080/1401072/293632020_10_17_132412.png)

  Press the [ Min ] or [ Max ] button for to go to this line

  Required: MessageX.lua in the modules folder

  Keys: <kbd>F3</kbd>




[&nbsp;](#user-content-editortaggotolua)

## [Editor.TagGoto.lua](https://github.com/z0hm/far-scripts/blob/master/Editor.TagGoto.lua "Editor.TagGoto.lua")

  *v1.1.2 (6180 bytes, changed 2022-02-18 13:18)*

  *SHA-256 `10eb2e8768dbb5ecd904125a1d6ac670484894eb044f0d177ed26aa01a001b37`*

  Tag navigation in files opened in the editor: [dgmsx]?html?, xslt?, [xy]ml

  Required: plugin LFSearch (LuaFAR Search) by Shmuel

  Keys: <kbd>Alt[JKLP]</kbd>




[&nbsp;](#user-content-farexitlua)

## [FarExit.lua](https://github.com/z0hm/far-scripts/blob/master/FarExit.lua "FarExit.lua")

  *v1.1.0.4 (5760 bytes, changed 2024-09-28 18:16)*

  *SHA-256 `cffb87d34d957deec87a74f52a0776f7b932f1e57fc30e24a8bf1a355af49e20`*

  Extend Quit Far Dialog

  ![changelog](http://i.piccy.info/i9/c30733a554949540a04b6ec94d7c20b8/1620285331/7939/1427986/FarExit.png)

  Required: MessageX.lua in the modules folder

  Keys: <kbd>F10</kbd>




[&nbsp;](#user-content-farupdatelua)

## [FarUpdate.lua](https://github.com/z0hm/far-scripts/blob/master/FarUpdate.lua "FarUpdate.lua")

  *v1.9.2 (13133 bytes, changed 2024-12-24 09:42)*

  *SHA-256 `5375e5c7a73dd0d20b85720b8d0a8c71c0b3fad8f79a682cdd2ef7302963cc36`*

  Opening changelog and updating Far Manager to any version available on the site

  ![changelog](http://i.piccy.info/i9/ff857187ff978fdbe845befda7fbfa4e/1592909758/25212/1384833/2020_06_23_134723.png)

  Far: press **[ Reload last ]** to reload the list with files

  GitHub: press **[ More >> ]** to get more files

  GitHub: press **[ Reload last ]** to reload last page with files

  GitHub: press **[ Reload all ]** to reload all pages

  GitHub: press **[ Goto build ]** to go to enter build number

  When you run the macro again, the build will be taken from the current line in Far.changelog

  Required: curl.exe, nircmd.exe, 7z.exe, requires tuning for local conditions

  Keys: launch from Macro Browser alt.

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=700#19




[&nbsp;](#user-content-html-xmloneline-multilinelua)

## [HTML-XML.OneLine-MultiLine.lua](https://github.com/z0hm/far-scripts/blob/master/HTML-XML.OneLine-MultiLine.lua "HTML-XML.OneLine-MultiLine.lua")

  *v1.0.1.1 (1485 bytes, changed 2023-10-24 18:04)*

  *SHA-256 `7a4d07fbbc0371c7da85159d960fb7849d54617a263c98804f41e3ddea100ac0`*

  Visual improvement of HTML-XML code (pretty print), creates a new file name~2.ext

  Keys: launch from Macro Browser alt.




[&nbsp;](#user-content-messagexlua)

## [MessageX.lua](https://github.com/z0hm/far-scripts/blob/master/MessageX.lua "MessageX.lua")

  *v0.6.7.9 (9274 bytes, changed 2021-07-29 15:13)*

  *SHA-256 `532b2f28cae344de8cef4c94288dd40e7a13769683bf9fdac564188a9567de78`*

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

  *v2.0.1.1 (11942 bytes, changed 2021-07-14 11:22)*

  *SHA-256 `203eee8dccd80457559ca486a5c49c48ef68de92d765fa1e59be4e1ecbfdfaa7`*

  Panel files sorting by attributes

  ![Panel.CustomSortByAttributes](http://i.piccy.info/i9/e4a7f377afa812d28e195dbae27e802b/1585895856/14743/1370861/2020_04_03_093318.png)

  Keys: <kbd>CtrlShiftF3</kbd> or from Menu "Sort by"

  Tip: In the dialog all elements have prompts, press <kbd>F1</kbd> for help

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2240#16




[&nbsp;](#user-content-panelcustomsortbynamelua)

## [Panel.CustomSortByName.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.CustomSortByName.lua "Panel.CustomSortByName.lua")

  *v1.1.0.3 (20461 bytes, changed 2022-11-19 06:51)*

  *SHA-256 `4cf377f49c893dd5ccd4d0c89202590279a177a31cb2d1287c846fb073afdca9`*

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

      local efbbbf,fffe,feff,ffi,sub = '\239\187\191','\255\254','\254\255',require'ffi',string.sub

      local C=ffi.C

      local function bom(fp)

        local res=0

        local f=win.WideCharToMultiByte(ffi.string(fp,tonumber(C.wcslen(fp))*2),65001)

        local h=io.open(f,"rb")

        if h then

          local s=h:read(3) or '' h:close()

          if s==efbbbf then res=3 else s=sub(s,1,2) if s==fffe then res=2 elseif s==feff then res=1 end end

        end

        return res

      end

      return bom(_G.sFuncTbl.fp1)-bom(_G.sFuncTbl.fp2)

    ```

  </details>

  <details><summary>by BOM ffi</summary>



    ``` lua

      -- by BOM ffi

      local ffi = require'ffi'

      local C = ffi.C

      local NULL = ffi.cast("void*",0)

      local ibuf=ffi.new"unsigned char[3]"

      

      local mode_in = "\114\0\98\0\0" -- "rb" UTF-16LE..'\0'

      local function bom(fp)

        local res=0

        local f_in=assert(C._wfopen(ffi.cast("wchar_t*",fp),ffi.cast("wchar_t*",mode_in)))

        if f_in~=NULL then

          ffi.fill(ibuf,3)

          local n=C.fread(ibuf,1,ffi.sizeof(ibuf),f_in)

          C.fclose(f_in)

          local n,b0,b1,b2 = tonumber(n),tonumber(ibuf[0]),tonumber(ibuf[1]),tonumber(ibuf[2])

          if n==3 and b0==0xef and b1==0xbb and b2==0xbf then res=3

          elseif n>=2 then

            if     b0==0xff and b1==0xfe then res=2

            elseif b0==0xfe and b1==0xff then res=1

            end

          end

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

      local C=ffi.C

      return tonumber(C.wcslen(_G.sFuncTbl.fp1))-tonumber(C.wcslen(_G.sFuncTbl.fp2))

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

      local C=ffi.C

      local _,x1 = regex.gsubW(ffi.string(_G.sFuncTbl.fp1,tonumber(C.wcslen(_G.sFuncTbl.fp1))*2),BS,BS)

      local _,x2 = regex.gsubW(ffi.string(_G.sFuncTbl.fp2,tonumber(C.wcslen(_G.sFuncTbl.fp2))*2),BS,BS)

      return x1-x2

    ```

  </details>

  <details><summary>by HEX in FileName</summary>



    ``` lua

      -- by HEX in FileName

      local ffi,RE,huge,gsub = require'ffi',regex.new'[0-9A-Fa-f]+$',math.huge,string.gsub

      local C=ffi.C

      local function p(s)

        local num=huge

        local fp=ffi.string(s,tonumber(C.wcslen(s))*2)

        local hex=RE:matchW(fp)

        if hex then num=tonumber(gsub(hex,'\000',''),16) end

        return num

      end

      return p(_G.sFuncTbl.fp1)-p(_G.sFuncTbl.fp2)

    ```

  </details>

  <details><summary>LastWriteTime in Day</summary>



    ``` lua

      -- by LastWriteTime in Day

      local guid="8EA08735-AF4A-4B90-A79F-6D453ADFA3B6"

      local ffi = require "ffi"

      local C = ffi.C

      

      if not _G.sFuncTbl[guid] then _G.sFuncTbl[guid]=""

      ffi.cdef [[

        typedef struct { WORD wYear,wMonth,wDayOfWeek,wDay,wHour,wMinute,wSecond,wMilliseconds; } SYSTEMTIME;

        BOOL FileTimeToSystemTime(const FILETIME*, SYSTEMTIME*);

        BOOL SystemTimeToTzSpecificLocalTime(void*, const SYSTEMTIME*, SYSTEMTIME*);

      ]]

      end

      

      local ft1, ft2, ftmp = ffi.new("SYSTEMTIME"), ffi.new("SYSTEMTIME"), ffi.new("SYSTEMTIME")

      

      local function ms(st)

        return ((st.wHour*60+st.wMinute)*60+st.wSecond)*1000+st.wMilliseconds 

      end

      

      C.FileTimeToSystemTime(_G.sFuncTbl.lwt1, ftmp)

      C.SystemTimeToTzSpecificLocalTime(nil, ftmp, ft1)

      C.FileTimeToSystemTime(_G.sFuncTbl.lwt2, ftmp)

      C.SystemTimeToTzSpecificLocalTime(nil, ftmp, ft2)

      return ms(ft1) - ms(ft2)

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

  *SHA-256 `41ceda1e697108c79e9b95525ad5a4f13f07e7c007f712080846b491c5396bac`*

  Custom panel file sorts: by Name with StrCmpLogicalW, by FullPath length

  Keys: <kbd>CtrlShiftF3</kbd> or from Menu "Sort by"




[&nbsp;](#user-content-panelfiles2hex_ffilua)

## [Panel.Files2HEX_ffi.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.Files2HEX_ffi.lua "Panel.Files2HEX_ffi.lua")

  *v1.0.0.2 (2751 bytes, changed 2021-08-10 21:12)*

  *SHA-256 `1267a5362b2d63d09bf74d450a621d8cbd98c6021193735d7243046c466b32bc`*

  (un)HEX selected files, VERY FAST!

  Keys: launch from Macro Browser alt.

  author Shmuel, co-author AleXH




[&nbsp;](#user-content-panellynx-motionlua)

## [Panel.LYNX-motion.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.LYNX-motion.lua "Panel.LYNX-motion.lua")

  *v1.0 (2687 bytes, changed 2020-04-09 09:55)*

  *SHA-256 `2f4009b51874478fcf9b5acf75190239e6306c0073aead8a8b5eb9b8db3bd261`*

  Extended lynx-motion style

  Very convenient navigation in panels with elevators through empty subfolders and etc.

  Keys: <kbd>Left</kbd> <kbd>Right</kbd> <kbd>Enter</kbd>




[&nbsp;](#user-content-panelselectbomlua)

## [Panel.SelectBOM.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.SelectBOM.lua "Panel.SelectBOM.lua")

  *v1.3 (5653 bytes, changed 2020-05-21 07:09)*

  *SHA-256 `05ee4feb9c45b70acf9880455b9052ef0cda666278a89d124a165d2067160ca5`*

  Selection files with BOM

  Keys: launch from Macro Browser alt.

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2280#12




[&nbsp;](#user-content-panelselectduplicatesfilenameslua)

## [Panel.SelectDuplicatesFileNames.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.SelectDuplicatesFileNames.lua "Panel.SelectDuplicatesFileNames.lua")

  *v1.3.5.0 (15879 bytes, changed 2023-05-19 05:20)*

  *SHA-256 `1f7c81bd5b2fbfdb2e244be70d677d7eb7cf95d7195679fa2da239634380c0bf`*

  Select Duplicates File Names in Branch panel with complex logic

  For the correct result, set default sorting system settings:

    [ ] Treat digits as numbers

    [ ] Case sensitive

  Column **&lt;R&gt;** shows the Result of the comparison

  The Integrity Checker plugin is required to calculate Hashes

  ![Panel.SelectDuplicatesFileNames](http://i.piccy.info/i9/7a5542e442b1ee61b39f6f9ad8dcae63/1585894944/7348/1370861/2020_04_03_091759.png)

  Keys: launch from Macro Browser alt.

  Tip: In the dialog all elements have prompts, press <kbd>F1</kbd> for help




[&nbsp;](#user-content-panelselectfolderslua)

## [Panel.SelectFolders.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.SelectFolders.lua "Panel.SelectFolders.lua")

  *v1.0.0.1 (2107 bytes, changed 2021-05-17 11:28)*

  *SHA-256 `a241b97e3bc46f897e554e9b14735b24847457895d2d7fdbc6fbb02a32953676`*

  Extend Select Folders/Files Dialog

  ![changelog](http://i.piccy.info/i9/9de5c58f6ba15652d9ef22cb7ea4e945/1620055603/2539/1427619/2021_05_03_182332.png)

  Keys: <kbd>Grey+</kbd> <kbd>Grey-</kbd> <kbd>CtrlF</kbd>




[&nbsp;](#user-content-panelshiftf[56]lua)

## [Panel.ShiftF[56].lua](https://github.com/z0hm/far-scripts/blob/master/Panel.ShiftF[56].lua "Panel.ShiftF[56].lua")

  *v1.3.4.0 (4537 bytes, changed 2021-11-30 11:47)*

  *SHA-256 `dc009dbb1ae9451ac9a976696408ec22ac699dfe75e5c9e47cfff7ed4384b88d`*

  Extend Panel (Shift)?F[56] Dialog

  Hint: Press <kbd>CtrlR</kbd> and set replace [x] data for copy the source file to the target file with multiple hardlinks

  Required: FAR3 build >= 5467

  Keys: none, to use put in the scripts folder




[&nbsp;](#user-content-panelvisualcomparelua)

## [Panel.VisualCompare.lua](https://github.com/z0hm/far-scripts/blob/master/Panel.VisualCompare.lua "Panel.VisualCompare.lua")

  *v1.9.0 (9194 bytes, changed 2021-03-31 17:17)*

  *SHA-256 `83a1d956dbf0eb0adb8dc24597868e77bb34a872c3febf0b844ee3814e8a1487`*

  Visual Compare files or folders for panels: Files, Branch, Temporary, Arclite, Netbox, Observer, TorrentView.

  Note: if more than two files are selected on the active panel for comparison, the AdvCmpEx plugin will be called.

  Keys: <kbd>CtrlAltC</kbd>

  The Exchange of lines between files

  Keys: <kbd>Ins</kbd> / <kbd>Del</kbd> - insert / delete line in active file, <kbd>F5</kbd> / <kbd>F6</kbd> - copying with insertion / substitution line

  Keys: <kbd>AltLeft</kbd> / <kbd>AltRight</kbd> - copy line from right file to left file and vice versa

  Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2080#6




[&nbsp;](#user-content-researchgreplua)

## [RESearch.Grep.lua](https://github.com/z0hm/far-scripts/blob/master/RESearch.Grep.lua "RESearch.Grep.lua")

  *v1.4.2.3 (3626 bytes, changed 2024-08-16 06:47)*

  *SHA-256 `80641302c92b8315646d38b9ae2afab3c2b6009756acb784176205ef7bf6a13a`*

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

  *v1.0.3 (3840 bytes, changed 2025-03-22 10:03)*

  *SHA-256 `ee30a9f730ba801065d621b9954748f21421f91f73b4c3d0b2df823d0d411d20`*

  Create btpolicy.xml for uTorrent, with priority peering zone (example for Belarus users)

  Launch: in cmdline Far.exe: lua:@btpolicy.xml.lua or lfjit.exe btpolicy.xml.lua




[&nbsp;](#user-content-iptvlua)

## [iptv.lua](https://github.com/z0hm/far-scripts/blob/master/iptv.lua "iptv.lua")

  *v1.0.5 (3066 bytes, changed 2021-07-08 14:26)*

  *SHA-256 `721584597be8e246ea1a5494ff3b25e41f663558f8b0eccba6f4a2d3f1d79ea1`*

  Combining free, frequently updated iptv sheets into one My.m3u, duplicate links removed

  Launch: in cmdline Far.exe: lua:@iptv.lua, or lfjit.exe iptv.lua, or lflua.exe iptv.lua




[&nbsp;](#user-content-moon2lualua)

## [moon2lua.lua](https://github.com/z0hm/far-scripts/blob/master/moon2lua.lua "moon2lua.lua")

  *v1.0 (629 bytes, changed 2021-05-21 06:55)*

  *SHA-256 `c6246876a21e863f923078f14fae50eb075506818e2bca483f3626bd2d60f130`*

  author Shmuel, 28.05.2020

  copy to folder included Moonscript files and run it: lua:@moon2lua.lua

  all Moonscript files will be deleted after convert!




[&nbsp;](#user-content-shell)

# [shell](https://github.com/z0hm/far-scripts/tree/master/shell "shell")


linux shell scripts - sh, bash, dash, sash & etc.


[&nbsp;](#user-content-aq)

## [aq](https://github.com/z0hm/far-scripts/blob/master/shell/aq "aq")

  *22818 bytes, changed 2024-11-29 06:34*

  *SHA-256 `44ba55be9a9110d4af52343d270dd394d34269597e513859fd00c04ecc42dfbf`*

  Bash script - interface for [Album Player Console](http://albumplayer.ru/linux/ap64.tar.gz "apc")

  ![aq script](http://i.piccy.info/i9/ce0b78c019db240a75a21f00089bfd7a/1600717787/7655/1397248/2020_09_21_221429.png)

  ![aq script](http://i.piccy.info/i9/b978141af12e993afff139bb461039db/1600717816/39618/1397248/946922020_09_21_223718.png)

  Commands:

  **h** - help, **e** - exit, **x** - exit with save path

  **.** - play all music files in folder, just **Enter** - repeat last command

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




