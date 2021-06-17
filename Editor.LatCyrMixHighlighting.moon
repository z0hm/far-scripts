-- Editor.LatCyrMixHighlighting.moon
-- v1.1.3.4
-- Highlighting mixed Latin and Cyrillic letters in the editor
-- ![Mixed latin and cyrillic letters](http://i.piccy.info/i9/3a9b767a03d92b5970f5be786dca6d04/1585845951/933/1370793/2020_04_02_194011.png)
-- Required: MessageX.lua in modules folder
-- Keys: F3
-- author zg, co-author AleXH
-- Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=49572&start=2460#3
-- prototype: https://forum.farmanager.com/viewtopic.php?f=60&t=8674

-- default values
ExecDelay=2
ShowTimeofProcessing=true
VisibilityColor=0xFF000000
ForegroundColor=VisibilityColor+9
BackgroundColor=VisibilityColor+1

F=far.Flags
bor  = bit64.bor
band = bit64.band
Flags=F.ECF_AUTODELETE
MessageX=require'MessageX'

editors={}
Colors={
  {regex.new "/(\\s+)(\\S|$)/"
  {Flags:bor F.FCF_FG_4BIT,F.FCF_BG_4BIT
  ForegroundColor:ForegroundColor
  BackgroundColor:BackgroundColor}}
  {regex.new "/([a-zA-Z]+)([а-яёА-ЯЁ]+)|([а-яёА-ЯЁ]+)([a-zA-Z]+)/"
  {Flags:bor F.FCF_FG_4BIT,F.FCF_BG_4BIT
  ForegroundColor:ForegroundColor+5
  BackgroundColor:BackgroundColor+3}}
}
colorguid=win.Uuid "A1811CF8-C7AA-4474-A204-F8306028C7A7"

GetEditorData=(id)->
  data=editors[id]
  if not data
    editors[id]=
      start:0
      finish:0
    data=editors[id]
  data

RemoveColors=(id,data)->
  for ii=data.start,data.finish
    editor.DelColor id,ii,0,colorguid

ProcessColors=(id,update)->
  data=GetEditorData id
  RemoveColors id,data
  update data

count,ttime0,ttime1=0,0,0
Event
  group:"EditorEvent"
  condition:(id,event,param)->
    return editors[id]
  action:(id,event,param)->
    if event==F.EE_CLOSE
      editors[id]=nil
    if event==F.EE_REDRAW
      count=count+1
      ei=editor.GetInfo id
      if ei
        ttime=far.FarClock!
        ProcessColors ei.EditorID,(data)->
          data.start=ei.TopScreenLine
          data.finish=math.min ei.TopScreenLine+ei.WindowSizeY,ei.TotalLines
          for ii=data.start,data.finish
            RealLeftPos=editor.TabToReal(ei.EditorID,ii,ei.LeftPos)-1
            gsw=editor.GetStringW ei.EditorID,ii
            line=gsw.StringText
            length=gsw.StringLength
            if RealLeftPos<=length
              RightBorder=RealLeftPos+ei.WindowSizeX
              if length<RightBorder
                editor.AddColor ei.EditorID,ii,length+1,length+2,Flags,Colors[1][2],190,colorguid
              for i=1,#Colors
                sEnd=RealLeftPos
                while sEnd<RightBorder
                  sBegin,sEnd,_,s2,_,s4 = Colors[i][1]\findW line,sEnd+1
                  if sEnd
                    if s2
                      if s2~=""
                        if i==1
                          sEnd=sEnd-1
                        else
                          sBegin=sEnd-#s2/2+1
                    elseif s4 and s4~=""
                      sBegin=sEnd-#s4/2+1
                    sEnd=math.min sEnd,RightBorder
                    editor.AddColor ei.EditorID,ii,sBegin,sEnd,Flags,Colors[i][2],190,colorguid
                  else
                    break
        ttime0=ttime0+far.FarClock!-ttime

Event
  group:"ExitFAR"
  action:->
    wincount=far.AdvControl F.ACTL_GETWINDOWCOUNT,0,0
    for ii=1,wincount
      info=far.AdvControl F.ACTL_GETWINDOWINFO,ii,0
      if info and F.WTYPE_EDITOR==info.Type
        ProcessColors info.Id,(data)->
          data.start=0
          data.finish=0

Macro
  description:"Подсветка смешанной латиницы и кириллицы"
  area:"Editor"
  key:"F3"
  action:->
    count,ttime0=0,0
    id=editor.GetInfo().EditorID
    Msg=(s)->
      editor.Redraw id
      if ShowTimeofProcessing
        Answer=MessageX s.."\n\nEvent count: <#1s>"..count.."<#rs>\nTime: <#1s>"..ttime0.."<#rs> mcs","CyrSpaceHighlighting","Close;Hide","c","","",ExecDelay
        if Answer==2
          ShowTimeofProcessing=false
    if not editors[id]
      tFarColor=far.AdvControl far.Flags.ACTL_GETCOLOR,far.Colors.COL_EDITORTEXT,0
      if tFarColor
        BackgroundColor=bor tFarColor.BackgroundColor,VisibilityColor
      if 7<band BackgroundColor,0xF
        ForegroundColor=BackgroundColor-8
        Colors[2][2].ForegroundColor=VisibilityColor+math.fmod BackgroundColor-3,8
        Colors[2][2].BackgroundColor=VisibilityColor+math.fmod BackgroundColor-5,8
      else
        ForegroundColor=BackgroundColor+8
        Colors[2][2].ForegroundColor=VisibilityColor+8+math.fmod BackgroundColor+5,8
        Colors[2][2].BackgroundColor=VisibilityColor+8+math.fmod BackgroundColor+3,8
      Colors[1][2].ForegroundColor=ForegroundColor
      Colors[1][2].BackgroundColor=BackgroundColor
      Editor.Set 20,1
      editors[id]=
        start:0
        finish:0
      Msg "\nStatus: <#a2> ON  <#rr>"
    else
      Editor.Set 20,0
      ProcessColors id,(data)->
        data.start=1
        data.finish=1
      editors[id]=nil
      Msg "\nStatus: <#c4> OFF <#rr>"
