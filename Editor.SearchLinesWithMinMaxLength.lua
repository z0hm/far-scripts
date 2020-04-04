-- Editor.SearchLinesWithMinMaxLength.lua
-- v1.3
-- Search for lines with minimum and maximum length, excluding the first and last lines, they are often empty
-- Keys: F3

Macro {
  description="Search Lines with MinMax Lengths";
  area="Editor"; key="F3";
  action=function()
    local ttime=far.FarClock()
    local MinText,MaxText,LineInfo,StringNumber,MinNumber,MaxNumber,MinSymbols,MaxSymbols = "","",{},1,0,0,math.huge,0
    local EGI=editor.GetInfo()
    local EditorID,CodePage,TotalLines = EGI.EditorID,EGI.CodePage,EGI.TotalLines
    while true do
      LineInfo=editor.GetStringW(EditorID,StringNumber,0)
      if LineInfo then
        local Symbols=LineInfo.StringLength
        if Symbols<MinSymbols and StringNumber>1 and StringNumber<TotalLines then MinText,MinNumber,MinSymbols = LineInfo.StringText,StringNumber,Symbols
        elseif Symbols>MaxSymbols then MaxText,MaxNumber,MaxSymbols = LineInfo.StringText,StringNumber,Symbols
        end
        StringNumber=StringNumber+1
      else break
      end
    end
    local MinBytes,MaxBytes
    if CodePage>=1200 and CodePage<=1201
    then MinBytes,MaxBytes = MinSymbols*2,MaxSymbols*2
    else MinBytes,MaxBytes = #win.WideCharToMultiByte(MinText,CodePage),#win.WideCharToMultiByte(MaxText,CodePage)
    end
    MinText=win.Utf16ToUtf8(MinText)--:sub(1,70)
    MaxText=win.Utf16ToUtf8(MaxText)--:sub(1,70)
    ttime=far.FarClock()-ttime
    local res=far.Message(
      '   MinLine: '..MinNumber..'   Symbols: '..MinSymbols..'   Bytes: '..MinBytes..'\n'..MinText..'\n\n'..
      '   MaxLine: '..MaxNumber..'   Symbols: '..MaxSymbols..'   Bytes: '..MaxBytes..'\n'..MaxText..'\n\nTime: '..ttime..' mcs',
      'Search Lines with MinMax Lengths',
      'Min;Max;Cancel'
    )
    if res==1 then editor.SetPosition(EditorID,{CurLine=MinNumber})
    elseif res==2 then editor.SetPosition(EditorID,{CurLine=MaxNumber})
    end
  end
}
