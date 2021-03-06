﻿-- Editor.SearchLinesWithMinMaxLength.lua
-- v1.3.2.1
-- Search for lines with minimum and maximum length, excluding the first and last lines, they are often empty
-- ![Panel.SelectDuplicatesFileNames](http://i.piccy.info/i9/2fbf64356c455c4f73c6c7a9a79e075c/1602930317/34080/1401072/293632020_10_17_132412.png)
-- Press the [ Min ] or [ Max ] button for to go to this line
-- Required: MessageX.lua in the modules folder
-- Keys: F3

local MessageX=require'MessageX'

local e=editor
local GetInfo,GetStringW,SetPosition = e.GetInfo,e.GetStringW,e.SetPosition

local w=win
local Utf16ToUtf8,WideCharToMultiByte = w.Utf16ToUtf8,w.WideCharToMultiByte

Macro {
  description="Search Lines with MinMax Lengths";
  area="Editor"; key="F3";
  action=function()
    local ttime=far.FarClock()
    local MinText,MaxText,LineInfo,StringNumber,MinNumber,MaxNumber,MinSymbols,MaxSymbols = "","",{},1,0,0,math.huge,0
    local EGI=GetInfo()
    local EditorID,CodePage,TotalLines = EGI.EditorID,EGI.CodePage,EGI.TotalLines
    while true do
      LineInfo=GetStringW(EditorID,StringNumber,0)
      if LineInfo then
        local Symbols=LineInfo.StringLength
        if Symbols<MinSymbols and StringNumber>1 and StringNumber<TotalLines then MinText,MinNumber,MinSymbols = LineInfo.StringText,StringNumber,Symbols
        elseif Symbols>MaxSymbols then MaxText,MaxNumber,MaxSymbols = LineInfo.StringText,StringNumber,Symbols
        end
        StringNumber=StringNumber+1
      else break
      end
    end
    local MaxLen,MinPf,MaxPf,MinBytes,MaxBytes = 2000,"",""
    if MinSymbols>MaxLen then MinText=MinText:sub(0,MaxLen) MinPf=">" end
    if MaxSymbols>MaxLen then MaxText=MaxText:sub(0,MaxLen) MaxPf=">" end
    if CodePage>=1200 and CodePage<=1201
    then MinBytes,MaxBytes,MinPf,MaxPf = MinSymbols*2,MaxSymbols*2,"",""
    else MinBytes,MaxBytes = #WideCharToMultiByte(MinText,CodePage),#WideCharToMultiByte(MaxText,CodePage)
    end
    MinText=Utf16ToUtf8(MinText)
    MaxText=Utf16ToUtf8(MaxText)
    local spc='\194\183'
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
      '   MinLine: <#1s>'..MinNumber..'<#rs>   Symbols: <#1s>'..MinSymbols..'<#rs>   Bytes: <#1s>'..MinPf..MinBytes..'<#rs>\n'..MinText..'   \n\n'..
      '   MaxLine: <#1s>'..MaxNumber..'<#rs>   Symbols: <#1s>'..MaxSymbols..'<#rs>   Bytes: <#1s>'..MaxPf..MaxBytes..'<#rs>\n'..MaxText..'   \n\nTime: <#9s>'..ttime..'<#rs> mcs',
      'Search Lines with MinMax Lengths',
      'Min;Max;Cancel','c'
    )
    if res==1 then SetPosition(EditorID,{CurLine=MinNumber})
    elseif res==2 then SetPosition(EditorID,{CurLine=MaxNumber})
    end
  end
}
