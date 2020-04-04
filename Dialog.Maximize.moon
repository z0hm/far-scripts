-- Dialog.Maximize.moon
-- v1.0
-- Resizing dialogs, aligning the positions of dialog elements
-- Keys: F2 in dialogs
-- Url: https://forum.farmanager.com/viewtopic.php?p=148024#p148024
-- Based on https://forum.farmanager.com/viewtopic.php?p=146816#p146816

Guid_DlgXScale=win.Uuid"D37E1039-B69B-4C63-B750-CBA4B3A7727C"
DX=4
if not _G._XScale
  _G._XScale=0  -- Default coefficient

transform=
  -- Set Dlg.XScale
  [Guid_DlgXScale]: {0,"1.16.A27",3.0}
  [win.Uuid"FCEF11C4-5490-451D-8B4A-62FA03F52759"]: {1,3,11} --copy
  [win.Uuid"431A2F37-AC01-4ECD-BB6F-8CDE584E5A03"]: {1,3,11} --move
  [win.Uuid"FAD00DBE-3FFF-4095-9232-E1CC70C67737"]: {1,3,6,8} --mkdir
  [win.Uuid"5EB266F4-980D-46AF-B3D2-2C50E64BCA81"]: {1,3,11} --link
  [win.Uuid"1D07CEE2-8F4F-480A-BE93-069B4FF59A2B"]: {1,3,6} --new
  [win.Uuid"8C9EAD29-910F-4B24-A669-EDAFBA6ED964"]: {1,3,6,7,9,15.1,16.1,17.1,18.1,20.1,22.2,23.1} --findfile
  [win.Uuid"5D3CBA90-F32D-433C-B016-9BB4AF96FACC"]: {1,2.3,3.3,5,7,12.1,13.1} --editsearch
  [win.Uuid"8BCCDFFD-3B34-49F8-87CD-F4D885B75873"]: {1,2.3,3.3,5,7,12.1,13.1} --editreplace
  [win.Uuid"9162f965-78b8-4476-98ac-d699e5b6afe7"]: {1,3,6} --saveas
  [win.Uuid"D8AF7A38-8357-44A5-A44B-A595CF707549"]: {1,3,6} -- Describe file
  [win.Uuid"044EF83E-8146-41B2-97F0-404C2F4C7B69"]: {1,3,6} -- Apply command
  [win.Uuid'502D00DF-EE31-41CF-9028-442D2E352990']: {1,3,11} -- Copy current
  [win.Uuid'89664EF4-BB8C-4932-A8C0-59CAFD937ABA']: {1,3,11} -- Move current
  -- RESearch
  [win.Uuid"E506EA8F-484F-7261-FEED-9B10267753E9"]: {1.0,4.0,6.0,7.3,26.3}          -- Shell/Search
  [win.Uuid"9736CFC1-9F3A-D4F9-02A4-566717182E8B"]: {1.0,4.0,6.0,8.0,9.3,10.3,37.3} -- Shell/Replace
  [win.Uuid"3D95792C-E25C-1CE1-EC09-DC409184EC7A"]: {1.0,4.0,6.0,7.3,24.0,35.3}     -- Shell/Grep
  [win.Uuid"AA3CA1C7-062A-67A8-3A73-80B5E9394046"]: {1.0,5.0} -- Shell/SelectFiles,UnselectFiles,FlipSelection
  [win.Uuid"0AE75CCC-5872-74A7-3561-BBA1991C0395"]: {1.0,4.0,6.0,8.0,28.3}          -- Shell/RenameFiles
  [win.Uuid"622AAD65-B7CA-7670-6622-A267028B1A06"]: {1.0,5.0,7.0,16.3}              -- Shell/RenameSelectedFiles
  [win.Uuid"FF1E3A24-0B7A-0149-EFA2-1ED2309F8410"]: {1.0,3.0,4.3,14.3,18.3}  -- Viewer,Editor/Search (hack: [Presets] is 14 in V, 18 in E)
  [win.Uuid"411BF77E-5743-D87A-A8E7-0EFDF0C71D79"]: {1.0,3.0,5.0,6.3,7.3,25.3}      -- Editor/Replace
  [win.Uuid"3A6225FC-AD65-75B1-2643-5158B78D6BC4"]: {1.0,3.0,4.3,14.3}              -- Editor/Filter
  [win.Uuid"6938029A-B71F-09EE-D09D-9982EE2B40BC"]: {1.0,3.0,4.3,15.3}              -- Editor/Repeat
  [win.Uuid"DCDDDA35-A319-1B82-8410-36C04A1390B0"]: {1.0,3.0,5.0,10.3}              -- Editor/Transliterate
  -- LFSearch/Shell
  [win.Uuid"3CD8A0BB-8583-4769-BBBC-5B6667D13EF9"]: {1.0,3.0,5.0,6.3} -- Shell/Find
  [win.Uuid"F7118D4A-FBC3-482E-A462-0167DF7CC346"]: {1.0,3.0,5.0,7.0,8.3,9.3,10.4,31.2,32.1,33.5} -- Shell/Replace
  [win.Uuid"74D7F486-487D-40D0-9B25-B2BB06171D86"]: {1.0,3.0,5.0,7.0,8.3,9.3} -- Shell/Grep
  [win.Uuid"AF8D7072-FF17-4407-9AF4-7323273BA899"]: {1.0,3.0,11.0,13.0,14.4,16.4,20.2,21.1,22.5,25.0,27.0} -- Shell/Rename
  -- LFSearch/Editor
  [win.Uuid"0B81C198-3E20-4339-A762-FFCBBC0C549C"]: {1.0,3.0,4.3,7.1,"8.12.F2.2.13",10.1,14.4,15.4,"16.12.3.2","17.10.16","18.10.16","19.12.3.3","20.10.19","21.10.19",25.0,27.2,28.1,29.5} -- Editor/Find
  [win.Uuid"FE62AEB9-E0A1-4ED3-8614-D146356F86FF"]: {1.0,3.0,5.0,6.3,7.3,8.4,9.1,10.4,11.5,12.8,14.1,"14.9.-2.6","15.12.F2.2.11","17.10.11","20.12.3.1","21.10.10","22.10.20","23.12.3.2","24.10.23","25.10.23","26.12.3.3","27.10.26","28.10.26",32.0,34.2,35.5,36.5} -- Editor/Replace
  [win.Uuid"87ED8B17-E2B2-47D0-896D-E2956F396F1A"]: {1.0,3.0,5.0,6.4,19.2,20.1,21.5} -- Editor/Multi-Line Replace
  -- Editor Find
  [win.Uuid"A0562FC4-25FA-48DC-BA5E-48EFA639865F"]: {1.0,4.0,10.1} -- Find
  [win.Uuid"070544C7-E2F6-4E7B-B348-7583685B5647"]: {1.0,4.0,6.0,12.1,13.1} -- Replace
  -- Calculator
  [win.Uuid"E45555AE-6499-443C-AA04-12A1AADAB989"]: {1.0,3.0,10.0,11.0,12.0,13.0,14.0}
  -- LiveFileSearch
  [win.Uuid"6A69A5AF-FC3F-4B7A-9A3C-6047B7CBA242"]: {1.0,5.0,"8.12.2.1","10.12.2.1",11.1,12.1,13.1,14.1,15.1}

F=far.Flags
edtFlags=F.DIF_HISTORY+F.DIF_USELASTHISTORY

ConsoleSize=->
  rr=far.AdvControl"ACTL_GETFARRECT"
  rr.Right-rr.Left+1

Proc=(id,hDlg)->
  cx=ConsoleSize!
  {Left:dl,Top:dt,Right:dr,Bottom:db}=far.SendDlgMessage hDlg,F.DM_GETDLGRECT
  ex,ax = dr-dl+1,cx-DX
--  coeff=transform[id][1] -- 1st value in table - 0<=Value<=1
--  coeff=_G._XScale<=1 and coeff*_G._XScale or coeff
  diff=(ax-ex)*_G._XScale
  DlgWidth=ex+diff
  far.SendDlgMessage hDlg,F.DM_RESIZEDIALOG,0,{X:DlgWidth,Y:db-dt+1}
  far.SendDlgMessage hDlg,F.DM_MOVEDIALOG,1,{X:(ax+DX-DlgWidth)/2,Y:dt}
  itm1=far.SendDlgMessage hDlg,F.DM_GETDLGITEM,1
  pl=itm1[2]+2
  pr=DlgWidth-pl-1
  corr=true
  _G.Items={"ex":ex,"DlgWidth":DlgWidth,"diff":diff,"id":Dlg.Id}
  for ii in *transform[id]
    local idx,opt,ref
    if "number"==type ii
      continue if ii<1
      idx,opt = math.modf ii
      opt=math.floor opt*10+0.5
    else
      idx,opt,ref = ii\match"^(%d%d-)%.(%d%d-)%.(.+)$"
      idx=tonumber idx
      opt=tonumber opt
    item=far.GetDlgItem hDlg,idx
    rawset(_G.Items,idx,item)
    if item  -- prevent error message for out-of-range index (see "hack" above)
      switch opt
        when 0  -- Stretch full
          if idx==1 and item[1]==3
            item[4]=pr+2
          else
            if corr or diff>=0
              if item[4]==item[2]
                item[2]+=diff
              item[4]+=diff
        when 1  -- Move half
          if item[4]==item[2]
            item[4]+=diff/2
          item[2]+=diff/2
        when 2  -- Stretch half
--          if corr
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
          x=tonumber ref\match"[%-%+]?%d+"
          item[2]+=x
          item[4]+=x
        when 7  -- Move relative by Y
          y=tonumber ref\match"[%-%+]?%d+"
          item[3]+=y
          item[5]+=y
        when 8  -- Switch Correction Stretch full
          corr=not corr
        when 9  -- Move & Size relative by X1 & X2
          x1,x2 = ref\match"([%-%+]?%d%d-)%.([%-%+]?%d+)"
          item[2]+=tonumber x1
          item[4]+=tonumber x2
        when 10  -- Align to ref.X
          t=far.SendDlgMessage hDlg,F.DM_GETDLGITEM,tonumber ref
          item[4]=item[4]+t[2]-item[2]
          item[2]=t[2]
        when 11  -- Align to ref.Y
          t=far.SendDlgMessage hDlg,F.DM_GETDLGITEM,tonumber ref
          item[5]=item[5]+t[3]-item[3]
          item[3]=t[3]
        when 12  -- Move & Stretch: (colons quantity).(colon number).(dx)
          m,q,n,x = ref\match"([F]?)(%d)%.(%d)%.([%-%+]?%d+)"
          if not q
            m,q,n = ref\match"([F]?)(%d)%.(%d)"
            x=0
          wc=(DlgWidth-pl*2-1)/tonumber q
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
          x1,x2,y1,y2 = ref\match"([%-%+]?%d%d-)%.([%-%+]?%d%d-)%.([%-%+]?%d%d-)%.([%-%+]?%d+)"
          item[2]+=tonumber x1
          item[3]+=tonumber y1
          item[4]+=tonumber x2
          item[5]+=tonumber y2
        when 14  -- Free Move & Stretch Absolute
          x1,x2,y1,y2 = ref\match"([%-%+]?%d%d-)%.([%-%+]?%d%d-)%.([%-%+]?%d%d-)%.([%-%+]?%d+)"
          item[2]=tonumber x1
          item[3]=tonumber y1
          item[4]=tonumber x2
          item[5]=tonumber y2
        when 15  -- Set text
          item[10]=ref
        when 16  -- Scale Dialog
          m,sc=ref\match"([AF]?)([%d%.]+)"
          sc=tonumber sc
          local w
          if m==""
            w=DlgWidth*sc
          else
            w=sc
--          DlgWidth=w
          far.SendDlgMessage hDlg,F.DM_RESIZEDIALOG,0,{X:w,Y:db-dt+1}
          far.SendDlgMessage hDlg,F.DM_MOVEDIALOG,1,{X:(ax+DX-w)/2,Y:dt}
          pr=w-pl-1
          if idx==1
            item[4]=pr+2
          else
            p=pl*2+1
            sc=(w-p)/(DlgWidth-p)
            w=item[4]-item[2]+1
            if m=="A"
              w*=sc  -- Adaptive width
            item[2]=(item[2]-pl)*sc+pl
            item[4]=item[2]+w-1
--      {Left:dl,Top:dt,Right:dr,Bottom:db}=far.SendDlgMessage hDlg,F.DM_GETDLGRECT
--      pr=dr-dl-pl
--      ex=dr-dl+1
--      diff=(ax-ex)*coeff
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
      far.SetDlgItem hDlg,idx,item

local _id,_hDlg
Event
  group:"DialogEvent"
  description:"Dialog Transform"
  action:(event,param)->
    if event==F.DE_DLGPROCINIT and param.Msg==F.DN_INITDIALOG
      id=far.SendDlgMessage param.hDlg,F.DM_GETDIALOGINFO
      if id and transform[id.Id]
        _id,_hDlg = id.Id,param.hDlg
        Proc _id,_hDlg
    elseif event==F.DE_DEFDLGPROCINIT and param.Msg==F.DN_CONTROLINPUT
      if param.Param2.EventType==F.KEY_EVENT
        name=far.InputRecordToName param.Param2
        if name=="F2"
          res=far.InputBox Guid_DlgXScale,"XScale","0<=Value<=1",edtFlags
          if res
            res=tonumber res
            _G._XScale=res and res or 0
            Proc _id,_hDlg
    false
