-- ChessKnight.lua
-- v0.9.1.0
-- Finding the path of the chess knight. The path can be closed. The chessboard can be up to 127x127 in size, with any aspect ratio. Rules: previously visited squares and squares with holes are not available for moving.
-- ![Chess Knight](http://i.piccy.info/i9/e36cd250a4b8367f2253c06f4b77c386/1627298655/18083/1436873/2021_07_26_142058.png)
-- Launch: in cmdline Far.exe: lua:@ChessKnight.lua

-- Обход конём шахматной доски произвольного размера, посещённые ранее клетки и клетки с дырами для ходов недоступны.
local log  = 0 -- logging in %TEMP%\ChessKnight.log, max board 15x15, 1 move = 1 byte storing xy
local ret0 = 0 -- =0 без обязательного возврата к клетке старта, =1 с возвратом (замкнутый путь)
local name="ChessKnight"
local logname = name..".log"
local exename = name..".exe"
local txtname = name..".txt"

local ffi = require"ffi"
local C=ffi.C
local NULL = ffi.cast("void*",0)
local ffi_copy=ffi.copy
local s=string
local string_byte=s.byte

local F = far.Flags
local title="Chess Knight"
local uuid=win.Uuid"F625937B-B79A-4D58-92B7-9B40BC374F21"
local temp=win.GetEnv"TEMP".."\\"

::ANSWER::
local answer = far.InputBox(uuid,title,"board 6x6, start 1 1, ret 1, log 1, holes 42,43: 6 6 1 1 1 1 42 43","ChessKnight.lua",nil,nil,nil,F.FIB_NONE) or ""
local holes,bx,by,fbx,fby,x0,y0 = {}
if answer=="" then bx,by,x0,y0 = 6,6,1,1
elseif string.find(answer,"^%d+%s+%d+$") then x0,y0,bx,by = 1,1,string.match(answer,"(%d+)%s+(%d+)") bx,by = tonumber(bx),tonumber(by)
else
  local t={}
  for n in string.gmatch(answer,"%d+") do table.insert(t,tonumber(n)) end
  bx,by,x0,y0,ret0,log = unpack(t)
  if #t>6 then for i=7,#t do local s=tostring(t[i]) table.insert(holes,{tonumber(string.sub(s,1,#tostring(bx))),tonumber(string.sub(s,#tostring(bx)+1,#s))}) end end
end
ret0,log = ret0==1,log==1
local full=bx*by-#holes -- количество клеток для ходов
local fbx,fby = "%0"..#tostring(bx).."d","%0"..#tostring(by).."d"
local function holes_check(x,y) for _,v in ipairs(holes) do if v[1]==x and v[2]==y then return true end end return false end
local function holes_show()
  if #holes==0 then return "no" end
  local s="" for _,v in ipairs(holes) do s=s..string.format(fbx,v[1])..string.format(fby,v[2]).."," end
  return string.sub(s,1,-2)
end
local function console()
  panel.GetUserScreen()
  io.write("Board: "..bx.."x"..by..", Start: "..string.format(fbx,x0)..string.format(fby,y0)..", Closed path: "..(ret0 and "yes" or "no")..", Logging: "..(log and "yes" or "no")..", Holes: "..holes_show())
  panel.SetUserScreen()
end
local function Msg() far.Message("For a closed path, the number of squares must be even, add"..(#holes==0 and "" or "/remove").." a hole.",title) end
if ret0 and math.fmod(full,2)==1 then
  local x,y = math.floor((bx+1)/2),math.floor((by+1)/2) -- центр доски
  if x0==x and y0==y -- старт в центре доски?
  then if holes_check(bx,by) then Msg() goto ANSWER else table.insert(holes,{bx,by}) console() end
  else if holes_check( x, y) then Msg() goto ANSWER else table.insert(holes,{ x, y}) console() end
  end
else console()
end
full=bx*by-#holes -- количество клеток для ходов

local ttime=far.FarClock()
-- {dx,dy} - вектор хода
-- порядок следования векторов в массиве определяет приоритет выбора клетки для хода среди клеток с одинаковым количеством доступных для движения векторов
--local dx=ffi.new("int8_t[8]",{-1,-2,-2,-1, 1, 2, 2, 1})
--local dy=ffi.new("int8_t[8]",{ 2, 1,-1,-2,-2,-1, 1, 2})
local dx=ffi.new("const int8_t[8]",{-1,-1, 2,-2, 1, 1,-2, 2}) -- должны быть такими же как и в ChessKnight.exe
local dy=ffi.new("const int8_t[8]",{ 2,-2, 1, 1,-2, 2,-1,-1}) -- должны быть такими же как и в ChessKnight.exe
-- создаём чистую доску, свободная клетка содержит -1, либо вектор хода с неё 0-7, либо дыру 8
local function array(st,...) st=st..string.rep('[$]',#{...}) local array_ct=ffi.typeof(st,...) return array_ct({{-1}}) end
local t00=array("int8_t" ,bx,by) -- слой векторов с дырами
local t01=array("int16_t",bx,by) -- слой нумерации ходов
for _,v in ipairs(holes) do t00[v[1]-1][v[2]-1]=8 end  -- расставляем дыры 0 based
local Tree=ffi.new("uint8_t[?][9]",full) -- дерево, содержащее вектора возможных ходов

bx,by,x0,y0,full = bx-1,by-1,x0-1,y0-1,full-1 -- align from 1 to 0 based
local fw,rb,ret,full1,v,x2,y2 = 1,0,ret0,full-1 -- счётчики: ходов вперёд, возвратов (откатов)
if ret and math.fmod(full,2)==0 then ret=false end
local t1s,t1v,x,y -- номер текущего хода, последний (текущий) вектор, координаты текущей клетки

local function init() t1s,t1v,x,y = 0,0,x0,y0 end -- инициализация
init()

if win.GetFileAttr(exename) then
  local args=" "..(bx+1).." "..(by+1).." "..(x0+1).." "..(y0+1).." "..(ret and 1 or 0).." "..(log and 1 or 0)
  if #holes>0 then for _,v in ipairs(holes) do args=args.." "..v[1].." "..v[2] end end
  local ans=io.popen('"'..exename..args..'"',"rb"):read"*all"
  if ans and string.find(ans,"^Board size:") and win.GetFileAttr(temp..txtname) then
    local h=io.open(temp..txtname,"rb")
    if h then
      local s
      s=h:read(1) x=string_byte(s)
      s=h:read(1) y=string_byte(s)
      s=h:read(2) t1s=string_byte(s,2,2)*256+string_byte(s,1,1)
      s=h:read(4) fw=string_byte(s,4,4)*16777216+string_byte(s,3,3)*65536+string_byte(s,2,2)*256+string_byte(s,1,1)
      s=h:read(4) rb=string_byte(s,4,4)*16777216+string_byte(s,3,3)*65536+string_byte(s,2,2)*256+string_byte(s,1,1)
      for x=0,bx   do for y=0,by do s=h:read(1) t00[x][y]=string_byte(s) end end
      for x=0,bx   do for y=0,by do s=h:read(2) t01[x][y]=string_byte(s,2,2)*256+string_byte(s,1,1) end end
      for x=0,full do for y=0,8  do s=h:read(1) Tree[x][y]=string_byte(s) end end
      h:close()
      goto RESULTS
    end
  end
end

do
  local cx=ffi.new("int8_t[8]",{-1}) -- массив с x координатами клеток 1-го хода (финиша)
  local cy=ffi.new("int8_t[8]",{-1}) -- массив с y координатами клеток 1-го хода (финиша)
  local ti=ffi.new("uint8_t[8]") -- массив с индексами векторов на клетки, доступные для хода с клетки x,y
  local ta=ffi.new("uint8_t[8]") -- массив с количеством векторов у доступных для хода клеток
  -- сортируем вектора по убыванию количества векторов у целевых клеток, обеспечивая приоритет обхода клеток с наименьшим количеством входов
  -- алгоритм сохраняет очерёдность одинаковых значений, обеспечивая неизменность маршрутов и их конечное количество
  local function around(x,y)
    local tl=-1
    for i=0,7 do
      local x1,y1 = x+dx[i],y+dy[i]
      if x1>=0 and x1<=bx and y1>=0 and y1<=by and t00[x1][y1]<0 then
        tl=tl+1
        local a=0
        for j=0,7 do
          local x2,y2 = x1+dx[j],y1+dy[j]
          if x2>=0 and x2<=bx and y2>=0 and y2<=by and t00[x2][y2]<0 then a=a+1 end
        end
        ta[tl],ti[tl] = a,i
        if tl>0 then
          for i1=tl,1,-1 do
            local i0=i1-1
            if ta[i1]>ta[i0]
            then ta[i0],ti[i0],ta[i1],ti[i1] = ta[i1],ti[i1],ta[i0],ti[i0]
            else break
            end
          end
        end
      end
    end
    return tl
  end
  
  local cn,cl = 0,around(x,y) -- индекс клетки финиша, количество клеток на расстоянии 1 хода от старта t1s=1
  for i=cl,0,-1 do cx[i],cy[i] = x+dx[ti[i]],y+dy[ti[i]] end -- массив координат клеток на расстоянии 1 хода от старта t1s=1
  
  -- logging max board 15x15 - xy stored in 1 byte
  local lshift,pB,buf_size,fname,name_out,mode_out,f_out,obuf = bit.lshift
  if bx>15 or by>15 then log=false end
  if log then
    pB,buf_size = 0,0x1000000
    fname = win.GetEnv"TEMP"..logname 
    name_out = win.Utf8ToUtf16(fname).."\0"
    mode_out = "\119\0\98\0\0" -- win.Utf8ToUtf16("wb").."\0"
    f_out=assert(C._wfopen(ffi.cast("wchar_t*", name_out), ffi.cast("wchar_t*", mode_out)))
    if   f_out==NULL
    then log=false print("Can't create a "..logname)
    else obuf = ffi.new("unsigned char[?]",buf_size)
    end
  end
  
  ::START::
  if log then if pB<buf_size then obuf[pB]=lshift(x+1,4)+y+1 pB=pB+1 else C.fwrite(obuf,1,pB,f_out) obuf[0]=lshift(x+1,4)+y+1 pB=1 end end -- logging
  t1v=around(x,y)+1 -- указатель, хранящий количество векторов на доступные для хода клетки, указывает на активный (последний) вектор
  ffi_copy(Tree[t1s]+1,ti,t1v) -- записываем вектора в дерево со смещением 1
  Tree[t1s][0]=t1v -- сохраняем указатель на активный (последний) вектор
  if t1v>0 then
    v=Tree[t1s][t1v] x2,y2 = x+dx[v],y+dy[v] -- получаем вектор и координаты следующей клетки
    if ret and x2==cx[cn] and y2==cy[cn] and t1s<full1 then -- вектор указывает на клетку финиша?
      t1v=t1v-1 Tree[t1s][0]=t1v -- перемещаем указатель на предыдущий вектор
      if t1v==0 then goto ROLLBACK else v=Tree[t1s][t1v] x2,y2 = x+dx[v],y+dy[v] end -- больше векторов нет?
    end
    t00[x][y],t01[x][y] = v,t1s x,y = x2,y2 fw,t1s = fw+1,t1s+1 -- переходим на следующую клетку
    goto START -- следующий ход
  end
  if t1s==full and (not ret or x==cx[cn] and y==cy[cn]) then t01[x][y]=t1s goto FINISH end -- последняя клетка?
  ::ROLLBACK::
  repeat -- откат
    t1s=t1s-1 -- откатываем последний неудачный ход
    if t1s<0 then -- достигнута клетка старта?
      if ret -- маршрут замкнутый?
      then if cn<cl then cn=cn+1 else cn,ret = 0,false end init() goto START -- выбираем другую клетку для финиша
      else goto FINISH -- все пути испробованы, путь не найден
      end
    end
    t00[x][y],t01[x][y] = -1,-1 -- освобождаем клетку x,y
    t1v=Tree[t1s][0] -- восстанавливаем указатель на приведший на неё вектор
    v=Tree[t1s][t1v] x,y = x-dx[v],y-dy[v] rb=rb+1 -- получаем вектор и возвращаемся на клетку с которой пришли
    if log then if pB<buf_size then obuf[pB]=lshift(x+1,4)+y+1 pB=pB+1 else C.fwrite(obuf,1,pB,f_out) obuf[0]=lshift(x+1,4)+y+1 pB=1 end end -- logging
    t1v=t1v-1 Tree[t1s][0]=t1v -- выбираем другой вектор хода
  until t1v>0
  v=Tree[t1s][t1v] x2,y2 = x+dx[v],y+dy[v] -- получаем вектор и координаты следующей клетки
  if ret and x2==cx[cn] and y2==cy[cn] then -- вектор указывает на клетку финиша?
    t1v=t1v-1 Tree[t1s][0]=t1v -- перемещаем указатель на предыдущий вектор
    if t1v==0 then goto ROLLBACK else v=Tree[t1s][t1v] x2,y2 = x+dx[v],y+dy[v] end -- больше векторов нет?
  end
  t00[x][y],t01[x][y] = v,t1s x,y = x2,y2 fw,t1s = fw+1,t1s+1 -- переходим на следующую клетку
  goto START -- следующий ход
  ::FINISH::
  if log then if pB>0 then C.fwrite(obuf,1,pB,f_out) pB=0 end C.fclose(f_out) end -- logging
end

::RESULTS::
ttime = math.floor((far.FarClock()-ttime)/1000)/1000
-- Вывод результатов на экран и в %TEMP%\ChessKnight.txt
local function chk(x,y) for i=0,7 do if x+dx[i]==x0 and y+dy[i]==y0 then return true end end return false end
bx,by,x0,y0,full = bx+1,by+1,x0+1,y0+1,full+1 -- align from 0 to 1
local s0="Board: "..bx.."x"..by.."\nHoles: "..holes_show().."\nStart: "..string.format(fbx,x0)..string.format(fby,y0).."\nClosed path: "..(ret0 and "yes" or "no").."\nLogging: "..(log and "yes" or "no")
s0=s0.."\n\nSolution: "..(t1s+1==full and (not ret0 or ret0 and chk(x+1,y+1)) and "found " or "not found ").."\nVisited squares: "..(t1s+1).."/"..full.."\nTime: "..ttime.." s\n"
local s1="\nPath: "..string.format(fbx,x0)..string.format(fby,y0)
x2,y2 = x0,y0
for i=0,t1s-1 do x2,y2 = x2+dx[Tree[i][Tree[i][0]]],y2+dy[Tree[i][Tree[i][0]]] s1=s1.." "..string.format(fbx,x2)..string.format(fby,y2) end
t1s,s1 = t1s+1,s1.."\n"
local s2,sf = "\n",#tostring(full)
for y=by,1,-1 do for x=1,bx do local dd=t01[x-1][y-1]+1 s2=s2..string.format((dd==1 or dd==t1s) and "[%"..sf.."d]" or " %"..sf.."d ",dd) end s2=s2.."\n" end
local s3="\n   Moves: "..(fw+rb).."\n Forward: "..fw.."\nRollback: "..rb
local h=io.open(temp..txtname,"wb") h:write(title.."\n\n"..s0..s1..s2..s3) h:close()

local MessageX=require"MessageX"

local function fine(x)
  s0=string.find(s0,"not found") and string.gsub(s0," not found ","<#c4>%1<#rr>") or string.gsub(s0," found ","<#a2>%1<#rr>")
  if x then
    s2=string.gsub(s2,"%[(.-)%]","<#f1> %1 <#rr>")
    s2=string.gsub(s2,string.rep(" ",sf).."0 ","<#ec>%1<#rr>")
  end
end

local rr=far.AdvControl"ACTL_GETFARRECT"
local Width,Height = rr.Right-rr.Left-3,rr.Bottom-rr.Top-15

local hs1,ws2 = math.ceil((#s1-1)/Width)+by+1<=Height,(#s2-1)/by-1<=Width
if hs1 and ws2 then if MessageX then fine(1) MessageX(s0..s1..s2..s3,title,nil,"c") else far.Message(s0..s1..s2..s3,title) end
elseif by<=Height and ws2 then if MessageX then fine(1) MessageX(s0..s2..s3,title,nil,"c") else far.Message(s0..s2..s3,title) end
else if MessageX then fine() MessageX(s0..s3,title,nil,"c") else far.Message(s0..s3,title) end
end
