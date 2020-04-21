-- Editor.SearchLinesWithMinMaxLength.lua
-- v1.3.1
-- Search for lines with minimum and maximum length, excluding the first and last lines, they are often empty
-- Required: MessageX.lua in the modules folder
-- Keys: F3

local MessageX=require'MessageX'

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
    local spc='\183'
    local tab='\26'
    local function show(s)
      s=s:gsub('%d+%.?%d*','<#2s>%1<#rs>')
      s=s:gsub(' +','<#1s>%1<#rs>')
      s=s:gsub(' ',spc)
      s=s:gsub('\t+','<#1s>%1<#rs>')
      s=s:gsub('\t',tab)
      return s
    end
    MinText=show(MinText)
    MaxText=show(MaxText)
    ttime=far.FarClock()-ttime
    local res=MessageX(
    --local res=far.Message(
      '   MinLine: <#1s>'..MinNumber..'<#rs>   Symbols: <#1s>'..MinSymbols..'<#rs>   Bytes: <#1s>'..MinBytes..'<#rs>\n'..MinText..'\n\n'..
      '   MaxLine: <#1s>'..MaxNumber..'<#rs>   Symbols: <#1s>'..MaxSymbols..'<#rs>   Bytes: <#1s>'..MaxBytes..'<#rs>\n'..MaxText..'\n\nTime: <#9s>'..ttime..'<#rs> mcs',
      'Search Lines with MinMax Lengths',
      'Min;Max;Cancel','c'
    )
    if res==1 then editor.SetPosition(EditorID,{CurLine=MinNumber})
    elseif res==2 then editor.SetPosition(EditorID,{CurLine=MaxNumber})
    end
  end
}
