-- Editor.CyrSpaceHighlighting.moon
-- v1.1.3.6
-- Highlighting Cyrillic and space symbols
-- ![Highlight ON](http://i62.fastpic.ru/big/2014/0603/18/0f2bf6171580c92d52a09ead18b86e18.png)
-- ![Highlight ON](http://i.piccy.info/i9/7223f0c8d8e8b124e0849af1cdd4e5de/1587815203/7934/1374955/2020_04_25_134822.png)
-- ![Highlight OFF](http://i.piccy.info/i9/953bb710b86c522d71cd4b4211d3f616/1587815270/7789/1374955/2020_04_25_134843.png)
-- Required: MessageX.lua in modules folder
-- Keys: F3
-- author zg, co-author AleXH
-- Url: https://forum.ru-board.com/topic.cgi?forum=5&topic=48136&start=960#17
-- prototype: https://forum.farmanager.com/viewtopic.php?f=60&t=8674

-- default values
ExecDelay=2
ShowTimeofProcessing=true
VisibilityColor=0xFF000000
ForegroundColor=VisibilityColor+9
BackgroundColor=VisibilityColor+1

f=far
F,AdvControl,Colors,FarClock = f.Flags,f.AdvControl,f.Colors,f.FarClock

b=bit64
bor,band = b.bor,b.band

m=math
min,fmod = m.min,m.fmod

e=editor
AddColor,DelColor,GetInfo,GetStringW,Redraw,TabToReal = e.AddColor,e.DelColor,e.GetInfo,e.GetStringW,e.Redraw,e.TabToReal

Flags=F.ECF_AUTODELETE
MessageX=require'MessageX'

editors={}
colors={
  {regex.new "/(\\s+)(\\S|$)/"
  {Flags:bor F.FCF_FG_4BIT,F.FCF_BG_4BIT
  ForegroundColor:ForegroundColor
  BackgroundColor:BackgroundColor}}
  {regex.new "/([а-яёА-ЯЁ]+)([^а-яёА-ЯЁ]|$)/"
  {Flags:bor F.FCF_FG_4BIT,F.FCF_BG_4BIT
  ForegroundColor:ForegroundColor+5
  BackgroundColor:BackgroundColor+3}}
--  regex.new [[/([-+*:.,;!?~@#$%^&\\\/]+?)([-+*:.,;!?~@#$%^&\\\/]|$)/]]
--  {Flags:bor F.FCF_FG_4BIT,F.FCF_BG_4BIT
--  ForegroundColor:ForegroundColor+6
--  BackgroundColor:BackgroundColor}
}
colorguid=win.Uuid "F4B5E624-16F6-4243-9A3D-763097C72EAA"

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
    DelColor id,ii,0,colorguid

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
      ei=GetInfo id
      if ei
        ttime=FarClock!
        ProcessColors ei.EditorID,(data)->
          data.start=ei.TopScreenLine
          data.finish=min ei.TopScreenLine+ei.WindowSizeY,ei.TotalLines
          for ii=data.start,data.finish
            RealLeftPos=TabToReal(ei.EditorID,ii,ei.LeftPos)-1
            gsw=GetStringW ei.EditorID,ii
            line=gsw.StringText
            length=gsw.StringLength
            if RealLeftPos<=length
              RightBorder=RealLeftPos+ei.WindowSizeX
              if length<RightBorder
                AddColor ei.EditorID,ii,length+1,length+2,Flags,colors[1][2],190,colorguid
              for i=1,#colors
                sEnd=RealLeftPos
                while sEnd<RightBorder
                  sBegin,sEnd,_,s2=colors[i][1]\findW line,sEnd+1
                  if sEnd
                    if s2~=""
                      sEnd=sEnd-1
                    sEnd=min sEnd,RightBorder
                    AddColor ei.EditorID,ii,sBegin,sEnd,Flags,colors[i][2],190,colorguid
                  else
                    break
        ttime0=ttime0+FarClock!-ttime

description="Подсветка кириллицы и пробельных символов"

Event
  description:description
  group:"ExitFAR"
  action:->
    wincount=AdvControl F.ACTL_GETWINDOWCOUNT,0,0
    for ii=1,wincount
      info=AdvControl F.ACTL_GETWINDOWINFO,ii,0
      if info and F.WTYPE_EDITOR==info.Type
        ProcessColors info.Id,(data)->
          data.start=0
          data.finish=0

Macro
  description:description
  area:"Editor"
  key:"F3"
  action:->
    count,ttime0=0,0
    id=GetInfo!.EditorID
    Msg=(s)->
      Redraw id
      if ShowTimeofProcessing
        Answer=MessageX s.."\n\nEvent count: <#1s>"..count.."<#rs>\nTime: <#1s>"..ttime0.."<#rs> mcs","CyrSpaceHighlighting","Close;Hide","c","","",ExecDelay
        if Answer==2
          ShowTimeofProcessing=false
    if not editors[id]
      tFarColor=AdvControl F.ACTL_GETCOLOR,Colors.COL_EDITORTEXT,0
      if tFarColor
        BackgroundColor=bor tFarColor.BackgroundColor,VisibilityColor
      if 7<band BackgroundColor,0xF
        ForegroundColor=BackgroundColor-8
        colors[2][2].ForegroundColor=VisibilityColor+fmod BackgroundColor-3,8
        colors[2][2].BackgroundColor=VisibilityColor+fmod BackgroundColor-5,8
      else
        ForegroundColor=BackgroundColor+8
        colors[2][2].ForegroundColor=VisibilityColor+8+fmod BackgroundColor+5,8
        colors[2][2].BackgroundColor=VisibilityColor+8+fmod BackgroundColor+3,8
      colors[1][2].ForegroundColor=ForegroundColor
      colors[1][2].BackgroundColor=BackgroundColor
      editor.SetParam id,F.ESPT_SHOWWHITESPACE,1
      editors[id]=
        start:0
        finish:0
      Msg "\nStatus: <#a2> ON  <#rr>"
    else
      editor.SetParam id,F.ESPT_SHOWWHITESPACE,0
      ProcessColors id,(data)->
        data.start=1
        data.finish=1
      editors[id]=nil
      Msg "\nStatus: <#c4> OFF <#rr>"
