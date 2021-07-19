-- Dialog.Maximize.moon
-- v1.1.10.1
-- Resizing dialogs, aligning the positions of dialog elements
-- Keys: F2 in dialogs or CtrlAltRight or CtrlAltLeft
-- Url: https://forum.farmanager.com/viewtopic.php?p=148024#p148024
-- Based on https://forum.farmanager.com/viewtopic.php?p=146816#p146816

XScale=0 -- scale 0<=XScale<=1 for all dialogs: 0 = original width, 1 = full width, 0.5 = (full - original) / 2
XStep=0.25 -- width change step
DX=4 -- indent

XScale=_G.XScale or XScale
_XScale={id:"",xs:XScale,cw:nil,ch:nil,dw:nil,dh:nil,dl:nil,dt:nil,dr:nil,db:nil,pl:nil,pr:nil} -- original width

f=far
F,AdvControl,Dialog,GetDlgItem,Guids,SetDlgItem,SendDlgMessage,InputRecordToName = f.Flags,f.AdvControl,f.Dialog,f.GetDlgItem,f.Guids,f.SetDlgItem,f.SendDlgMessage,f.InputRecordToName

m=math
abs,ceil,floor,fmod,modf = m.abs,m.ceil,m.floor,m.fmod,m.modf

s=string
match = s.match

w=win
Uuid=w.Uuid

Guid_DlgXScale=Uuid"D37E1039-B69B-4C63-B750-CBA4B3A7727C"

transform=
  --[Guid_DlgXScale]: {0,"1.16.A27",3.0} -- Set Dlg.XScale
  [Uuid Guids.CopyFilesId                    ]: {1,3,11} -- Shell: Copy
  [Uuid Guids.CopyCurrentOnlyFileId          ]: {1,3,11} -- Shell: Copy current
  [Uuid Guids.MoveFilesId                    ]: {1,3,11} -- Shell: Move
  [Uuid Guids.MoveCurrentOnlyFileId          ]: {1,3,11} -- Shell: Move current
  [Uuid Guids.MakeFolderId                   ]: {1,3,6,8} -- Shell: mkdir
  [Uuid Guids.HardSymLinkId                  ]: {1,3,11} -- Shell: Link
  [Uuid Guids.FileOpenCreateId               ]: {1,3,6} -- Shell: New
  [Uuid Guids.FindFileId                     ]: {1,3,6,7,9,15.1,16.1,17.1,18.1,20.1,22.2,23.1} -- Find File
  [Uuid Guids.EditorSearchId                 ]: {1,2.3,3.3,5,7,12.1,13.1} -- Editor Search
  [Uuid Guids.EditorReplaceId                ]: {1,2.3,3.3,5,7,12.1,13.1} -- Editor Replace
  [Uuid Guids.FileSaveAsId                   ]: {1,3,6} -- File Save As
  [Uuid Guids.PluginInformationId            ]: {1,3,5,7,9,11,13,15,17}
  [Uuid Guids.DescribeFileId                 ]: {1,3} -- Describe File
  [Uuid Guids.ApplyCommandId                 ]: {1,3} -- Shell: Apply command (CtrlG)
  [Uuid Guids.EditUserMenuId                 ]: {1,5,8,9,10,11,12,13,14,15,16,17}
  [Uuid Guids.FileAssocModifyId              ]: {1,3,5,8,10,12,14,16,18}
  -- ArcLite
  [Uuid"08A1229B-AD54-451B-8B53-6D5FD35BCFAA"]: {1,15,19,27,31} -- Configuration
  [Uuid"CD57D7FA-552C-4E31-8FA8-73D9704F0666"]: {1,10,23,"43.10.45"} -- Create archive
  [Uuid"97877FD0-78E6-4169-B4FB-D76746249F4D"]: {1,3,"8.10.11","9.16.8.15","17.9.0.14"} -- Extract files
  [Uuid"0DCE48E5-B205-44A0-B8BF-96B28E2FD3B3"]: {1,9,20,22,33,35,37} -- SFX options
  [Uuid"2C4EFD54-A419-47E5-99B6-C9FD2D386AEC"]: {1,3,5} -- PostMacro
  -- RESearch
  [Uuid"E506EA8F-484F-7261-FEED-9B10267753E9"]: {1,4,6,7.3,26.3} -- Shell: Search
  [Uuid"9736CFC1-9F3A-D4F9-02A4-566717182E8B"]: {1,4,6,8,9.3,10.3,"33.10.32",37.3} -- Shell: Replace
  [Uuid"3D95792C-E25C-1CE1-EC09-DC409184EC7A"]: {1,4,6,7.3,24,35.3} -- Shell: Grep
  [Uuid"AA3CA1C7-062A-67A8-3A73-80B5E9394046"]: {1,5} -- Shell: SelectFiles,UnselectFiles,FlipSelection
  [Uuid"0AE75CCC-5872-74A7-3561-BBA1991C0395"]: {1,4,6,8,28.3} -- Shell: RenameFiles
  [Uuid"622AAD65-B7CA-7670-6622-A267028B1A06"]: {1,5,7,16.3} -- Shell: RenameSelectedFiles
  [Uuid"FF1E3A24-0B7A-0149-EFA2-1ED2309F8410"]: {1,3,4.3,14.3,18.3} -- Viewer,Editor: Search (hack: [Presets] is 14 in V, 18 in E)
  [Uuid"411BF77E-5743-D87A-A8E7-0EFDF0C71D79"]: {1,3,5,6.3,7.3,25.3} -- Editor: Replace
  [Uuid"3A6225FC-AD65-75B1-2643-5158B78D6BC4"]: {1,3,4.3,14.3} -- Editor: Filter
  [Uuid"6938029A-B71F-09EE-D09D-9982EE2B40BC"]: {1,3,4.3,15.3} -- Editor: Repeat
  [Uuid"DCDDDA35-A319-1B82-8410-36C04A1390B0"]: {1,3,5,10.3} -- Editor: Transliterate
  -- LFSearch/Shell
  [Uuid"3CD8A0BB-8583-4769-BBBC-5B6667D13EF9"]: {1,3,5,6.3} -- Shell/Find
  [Uuid"F7118D4A-FBC3-482E-A462-0167DF7CC346"]: {1,3,5,7,8.3,9.3,10.4,31.2,32.1,33.5} -- Shell/Replace
  [Uuid"74D7F486-487D-40D0-9B25-B2BB06171D86"]: {1,3,5,7,8.3,9.3} -- Shell/Grep
  [Uuid"AF8D7072-FF17-4407-9AF4-7323273BA899"]: {1,3,11,13,14.4,16.4,20.2,21.1,22.5,25,27} -- Shell/Rename
  -- LFSearch/Editor
  [Uuid"0B81C198-3E20-4339-A762-FFCBBC0C549C"]: {1,3,4.3,7.1,"8.12.F2.2.13",10.1,14.4,15.4,"16.6.1","19.10.20",25,27.2,28.1,29.5} -- Editor/Find
  [Uuid"FE62AEB9-E0A1-4ED3-8614-D146356F86FF"]: {1,3,5,6.3,7.3,8.4,9.1,10.4,11.5,"14.10.11","15.16.11.11","17.10.11","20.12.3.1","21.10.20","22.10.20","23.6.1",32,34.2,35.5,36.5} -- Editor/Replace
  [Uuid"87ED8B17-E2B2-47D0-896D-E2956F396F1A"]: {1,3,5,6.4,19.2,20.1,21.5} -- Editor/Multi-Line Replace
  -- Editor Find
  [Uuid"A0562FC4-25FA-48DC-BA5E-48EFA639865F"]: {1,4,10.1} -- Find
  [Uuid"070544C7-E2F6-4E7B-B348-7583685B5647"]: {1,4,6,12.1,13.1} -- Replace
  -- Calculator
  [Uuid"E45555AE-6499-443C-AA04-12A1AADAB989"]: {1,3,10,11,12,13,14}
  -- LiveFileSearch
  [Uuid"6A69A5AF-FC3F-4B7A-9A3C-6047B7CBA242"]: {1,5,"8.12.2.1","10.12.2.1",11.1,12.1,13.1,14.1,15.1}
  -- AudioPlayer
  --[Uuid"9C3A61FC-F349-48E8-9B78-DAEBD821694B"]: {1,2,"3.6.0",4.1,5.3,"6.6.0",7.2,8.3,9.3,10.5,12.1,13.3,14} -- don't support width change yet
  -- Macros: Custom sort by Name
  [Uuid"5B40F3FF-6593-48D2-8F78-4A32C8C36BCA"]: {1,5,12,14}


re0,re1,re2,re3,re4,re5 = "^(%d+)%.(%d+)%.(.+)$","[%-%+]?%d+","([%-%+]?%d+)%.([%-%+]?%d+)","([F]?)(%d)%.(%d)%.([%-%+]?%d+)","([F]?)(%d)%.(%d)","([%-%+]?%d+)%.([%-%+]?%d+)%.([%-%+]?%d+)%.([%-%+]?%d+)"

ConsoleSize=->
  rr=AdvControl"ACTL_GETFARRECT"
  rr.Right-rr.Left+1,rr.Bottom-rr.Top+1

CopyTable=(s,t)->
  for k,v in pairs s
    if "table"==type v
      t[k]={}
      CopyTable v,t[k]
    else
      t[k]=v

DlgRect=(id,hDlg,t)->
  {Left:t.dl,Top:t.dt,Right:t.dr,Bottom:t.db}=SendDlgMessage hDlg,F.DM_GETDLGRECT
  t.dw=t.dr-t.dl+1
  t.dh=t.db-t.dt+1
  t.pl=(SendDlgMessage hDlg,F.DM_GETDLGITEM,1)[2]+2
  t.pr=t.dw-t.pl-1
  i=0
  while true
    i+=1
    item=GetDlgItem hDlg,i
    if item
      t[i]={}
      CopyTable item,t[i]
    else
      break

fSetDlgItem=(hDlg,idx,item)->
  if item[1]==F.DI_EDIT or item[1]==F.DI_FIXEDIT
    f=SendDlgMessage hDlg,F.DM_EDITUNCHANGEDFLAG,idx,-1
    SetDlgItem hDlg,idx,item
    SendDlgMessage hDlg,F.DM_EDITUNCHANGEDFLAG,idx,f
  else  
    SetDlgItem hDlg,idx,item

_XScale.cw,_XScale.ch = ConsoleSize!
Proc=(id,hDlg)->
  if id~=_XScale.id
    _XScale.id=id
    if not _XScale[id]
      _XScale[id]={}
      DlgRect id,hDlg,_XScale[id]
  cw,ch = ConsoleSize!
  if cw~=_XScale.cw or ch~=_XScale.ch
    _XScale.cw,_XScale.ch = cw,ch
  dh,pl = _XScale[id].dh,_XScale[id].pl
  df=cw-DX-_XScale[id].dw
  diff=_XScale.xs*df
  dw=_XScale[id].dw+diff
  pr=dw-pl-1
  SendDlgMessage hDlg,F.DM_ENABLEREDRAW,0,0
  --SendDlgMessage hDlg,F.DM_SHOWDIALOG,0,0  -- hide dialog
  for ii in *transform[id]
    local idx,opt,ref
    if "number"==type ii
      continue if ii<1
      idx,opt = modf ii
      opt=floor opt*10+0.5
    else
      idx,opt,ref = match ii,re0
      idx=tonumber idx
      opt=tonumber opt
    if _XScale[id][idx]  -- prevent error message for out-of-range index (see "hack" above)
      item={}
      CopyTable _XScale[id][idx],item
      switch opt
        when 0  -- Stretch full
          if idx==1 and item[1]==3
            item[4]=pr+2
          else
            if item[4]==item[2]
              item[2]+=diff
            item[4]+=diff
        when 1  -- Move half
          if item[4]==item[2]
            item[4]+=diff/2
          item[2]+=diff/2
        when 2  -- Stretch half
          if item[4]==item[2]
            item[2]+=diff/2
          item[4]+=diff/2
        when 3  -- Move full
          if item[4]==item[2]
            item[4]+=diff
          item[2]+=diff
        when 4  -- Move left
          item[2]=pl
        when 5  -- Move half & Stretch full
          if item[4]==item[2]
            item[4]+=diff/2
          item[2]+=diff/2
          if diff>=0
            item[4]+=diff
        when 6  -- Move relative by X
          x=tonumber match ref,re1
          item[2]+=x
          item[4]+=x
        when 7  -- Move relative by Y
          y=tonumber match ref,re1
          item[3]+=y
          item[5]+=y
        --when 8  -- reserved
        when 9  -- Move & Size relative by X1 & X2
          x1,x2 = match ref,re2
          item[2]+=tonumber x1
          item[4]+=tonumber x2
        when 10  -- Align to ref.X
          ref=tonumber ref
          t=_XScale[id][ref] or SendDlgMessage hDlg,F.DM_GETDLGITEM,ref
          item[4]=item[4]+t[2]-item[2]
          item[2]=t[2]
        when 11  -- Align to ref.Y
          ref=tonumber ref
          t=_XScale[id][ref] or SendDlgMessage hDlg,F.DM_GETDLGITEM,ref
          item[5]=item[5]+t[3]-item[3]
          item[3]=t[3]
        when 12  -- Move & Stretch: (colons quantity).(colon number).(dx)
          m,q,n,x = match ref,re3
          if not q
            m,q,n = match ref,re4
            x=0
          wc=(dw-pl*2-1)/tonumber q
          n=tonumber n
          w=item[4]-item[2]+1
          if w>wc
            w=wc
          x=tonumber x
          item[2]=wc*(n-1)+pl+x
          if m=="F"
            item[4]=item[2]+w-1
          else
            item[4]=item[2]+wc-1
        when 13  -- Free Move & Stretch Relative
          x1,x2,y1,y2 = match ref,re5
          item[2]+=tonumber x1
          item[3]+=tonumber y1
          item[4]+=tonumber x2
          item[5]+=tonumber y2
        when 14  -- Free Move & Stretch Absolute
          x1,x2,y1,y2 = match ref,re5
          item[2]=tonumber x1
          item[3]=tonumber y1
          item[4]=tonumber x2
          item[5]=tonumber y2
        when 15  -- Set text
          item[10]=ref
        when 16  -- Align to ref.X + offset
          x1,x2 = match ref,re2
          x1=tonumber x1
          x2=tonumber x2
          t=_XScale[id][x1] or SendDlgMessage hDlg,F.DM_GETDLGITEM,x1
          item[4]=item[4]+t[2]-item[2]+x2
          item[2]=t[2]+x2
      if idx==1
        if item[2]<pl-2
          item[2]=pl-2
        if item[4]>pr+2
          item[4]=pr+2
      else
        if item[2]<pl
          item[2]=pl
        if item[4]>pr
          item[4]=pr
      fSetDlgItem hDlg,idx,item
  SendDlgMessage hDlg,F.DM_RESIZEDIALOG,0,{X:dw,Y:dh}
  SendDlgMessage hDlg,F.DM_MOVEDIALOG,1,{X:(cw-dw)/2,Y:(ch-dh)/2}
  SendDlgMessage hDlg,F.DM_ENABLEREDRAW,1,0
  --SendDlgMessage hDlg,F.DM_REDRAW,0,0
  --SendDlgMessage hDlg,F.DM_SHOWDIALOG,1,0 -- show dialog

XItems={
         {F.DI_DOUBLEBOX, 0,0,19,2,0,       0,0,       0,  "XScale"}
         {F.DI_TEXT,      2,1, 9,1,0,       0,0,       0,"0<=X<=1:"}
         {F.DI_EDIT,     11,1,17,1,0,"XScale",0,       0,        ""}
       }

XDlgProc=(hDlg,Msg,Param1,Param2)->
  if Msg==F.DN_INITDIALOG
    SendDlgMessage hDlg,F.DM_SETTEXT,3,tostring _XScale.xs
  elseif Msg==F.DN_CLOSE and Param1==3
    res=tonumber SendDlgMessage hDlg,F.DM_GETTEXT,Param1
    if res
      if res<0
        res=0
      elseif res>1
        res=1
      _XScale.xs=res

exec=(hDlg)->
  id=SendDlgMessage hDlg,F.DM_GETDIALOGINFO
  if id and transform[id.Id]
    Proc id.Id,hDlg

Event
  group:"DialogEvent"
  description:"Dialog Transform"
  action:(event,param)->
    if event==F.DE_DLGPROCINIT and (param.Msg==F.DN_INITDIALOG or param.Msg==F.DN_RESIZECONSOLE)
      exec param.hDlg
    elseif event==F.DE_DEFDLGPROCINIT and param.Msg==F.DN_CONTROLINPUT
      if param.Param2.EventType==F.KEY_EVENT
        name=InputRecordToName param.Param2
        if name=="F2"
          res=Dialog Guid_DlgXScale,-1,-1,20,3,nil,XItems,F.FDLG_SMALLDIALOG+F.FDLG_WARNING,XDlgProc
          if res==3
            exec param.hDlg
        elseif name=="CtrlAltRight"
          if _XScale.xs<1
            _XScale.xs+=XStep
            if _XScale.xs>1
              _XScale.xs=1
            exec param.hDlg
        elseif name=="CtrlAltLeft"
          if _XScale.xs>0
            _XScale.xs-=XStep
            if _XScale.xs<0
              _XScale.xs=0
            exec param.hDlg
    false
