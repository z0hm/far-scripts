-- ChessKnight.lua
-- v0.9.0.2
-- Bypassing the case of a chessboard arbitrary size, visited previously squares and squares with holes for moves are not available.
-- ![Chess Knight](http://i.piccy.info/i9/3816fa76158b77498e41371e849e6637/1627210911/17158/1436778/2021_07_25_131624.png)
-- Launch: in cmdline Far.exe: lua:@ChessKnight.lua

-- ����� ���� ��������� ����� ������������� �������, ���������� ����� ������ � ������ � ������ ��� ����� ����������.
local log = 0 -- logging in %TEMP%\ChessKnight.log, max board 15x15, 1 move = 1 byte storing xy
local ret0 = 0 -- =0 ��� ������������� �������� � ������ ������, =1 � ��������� (��������� ����)

local ffi = require"ffi"
local C=ffi.C
ffi.cdef"typedef uint8_t Tree[9]"

local F = far.Flags
local title="Chess Knight"
local uuid=win.Uuid"F625937B-B79A-4D58-92B7-9B40BC374F21"
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
local full=bx*by-#holes -- ���������� ������ ��� �����
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
if ret0 and math.fmod(full,2)==1 then
  local x,y = math.floor((bx+1)/2),math.floor((by+1)/2) -- ����� �����
  if x0==x and y0==y then -- ����� � ������ �����?
    if holes_check(bx,by) then far.Message("For a closed path, the number of squares must be even, add"..(#holes==0 and "" or "/remove").." a hole.",title) goto ANSWER else table.insert(holes,{bx,by}) end
  else table.insert(holes,{x,y}) console()
  end
else console()
end
full=bx*by-#holes -- ���������� ������ ��� �����
local ttime=far.FarClock()
-- {dx,dy} - ������ ����
-- ������� ���������� �������� � ������� ���������� ��������� ������ ������ ��� ���� ����� ������ � ���������� ����������� ��������� ��� �������� ��������
--local dx=ffi.new("int8_t[8]",{-1,-2,-2,-1, 1, 2, 2, 1})
--local dy=ffi.new("int8_t[8]",{ 2, 1,-1,-2,-2,-1, 1, 2})
local dx=ffi.new("int8_t[8]",{-1,-1, 2,-2, 1, 1,-2, 2})
local dy=ffi.new("int8_t[8]",{ 2,-2, 1, 1,-2, 2,-1,-1})
-- ������ ������ �����, ��������� ������ �������� -1, ���� ������ ���� � �� 0-7, ���� ���� 8
local function array(st,...) st=st..string.rep('[$]',#{...}) local array_ct=ffi.typeof(st,...) return array_ct({{ -1 }}) end
local t00=array('int8_t' ,bx,by) -- ���� �������� � ������
local t01=array('int16_t',bx,by) -- ���� ��������� �����
for _,v in ipairs(holes) do t00[v[1]-1][v[2]-1]=8 end  -- ����������� ���� 0 based

local Tree=ffi.new("Tree[?]",full) -- ������, ���������� ������� ��������� �����
bx,by,x0,y0,full = bx-1,by-1,x0-1,y0-1,full-1 -- align from 1 to 0 based

local t1s,t1v,x,y -- ����� �������� ����, ��������� (�������) ������, ���������� ������� ������
local function init() t1s,t1v,x,y = 0,0,x0,y0 end -- �������������
init()

local cx=ffi.new("int8_t[8]",{-1}) -- ������ � x ������������ ������ 1-�� ���� (������)
local cy=ffi.new("int8_t[8]",{-1}) -- ������ � y ������������ ������ 1-�� ���� (������)
local ti=ffi.new("int8_t[8]",{-1}) -- ������ � ��������� �������� �� ������, ��������� ��� ���� � ������ x,y
local ta=ffi.new("int8_t[8]",{-1}) -- ������ � ����������� �������� � ��������� ��� ���� ������
local function around(x,y)-- ��������� ����������� ������ ������ ������ x,y
  local tl=-1
  for i=7,0,-1 do
    local x2,y2 = x+dx[i],y+dy[i]
    if x2>=0 and x2<=bx and y2>=0 and y2<=by and t00[x2][y2]<0 then
      tl=tl+1
      local a,v = 0,i<4 and i+4 or i-4 -- ��������������� ������
      for j=7,0,-1 do
        if i==v then goto continue end -- ��������� ������ � ������� ������
        local x3,y3 = x2+dx[j],y2+dy[j]
        if x3>=0 and x3<=bx and y3>=0 and y3<=by and t00[x3][y3]<0 then a=a+1 end
        ::continue::
      end
      ta[tl],ti[tl] = a,i
    end
  end
  -- ��������� ������� �� �������� ���������� �������� � ������� ������, ����������� ��������� ������ ������ � ���������� ����������� ������
  -- �������� ��������� ���������� ���������� ��������, ����������� ������������ ��������� � �� �������� ����������
  local l=tl-1
  if l>=0 then
    for j=l,0,-1 do
      local b=true
      for i=l,0,-1 do
        local i1=i+1
        if ta[i]<ta[i1] then
          b,ta[i],ti[i],ta[i1],ti[i1] = false,ta[i1],ti[i1],ta[i],ti[i]
        end
      end
      if b then break end
    end
  end
  return tl
end

local cn,cl = 0,around(x,y) -- ������ ������ ������, ���������� ������ �� ���������� 1 ���� �� ������ t1s=1
for i=cl,0,-1 do cx[i],cy[i] = x+dx[ti[i]],y+dy[ti[i]] end -- ������ ��������� ������ �� ���������� 1 ���� �� ������ t1s=1

local fw,rb,ret,full1,v,x2,y2 = 1,0,ret0,full-1 -- ��������: ����� �����, ��������� (�������)
if ret and math.fmod(full,2)==0 then ret=false end

-- logging max board 15x15 - xy stored in 1 byte
local lshift,pB,buf_size,fname,name_out,mode_out,f_out,obuf = bit.lshift
if bx>15 or by>15 then log=false end
if log then
  pB,buf_size = 0,0x1000000
  fname = win.GetEnv"TEMP".."\\ChessKnight.log" 
  name_out = win.Utf8ToUtf16(fname).."\0"
  mode_out = "\119\0\98\0\0" -- win.Utf8ToUtf16("wb").."\0"
  f_out=assert(C._wfopen(ffi.cast("wchar_t*", name_out), ffi.cast("wchar_t*", mode_out)))
  obuf = ffi.new("unsigned char[?]",buf_size)
end

::START::
if log then if pB<buf_size then obuf[pB] = lshift(x+1,4)+y+1 pB=pB+1 else C.fwrite(obuf,1,pB,f_out) pB=0 obuf[pB] = lshift(x+1,4)+y+1 pB=pB+1 end end -- logging
t1v=around(x,y)+1 -- ���������, �������� ���������� �������� �� ��������� ��� ���� ������, ��������� �� �������� (���������) ������
ffi.copy(Tree[t1s]+1,ti,t1v) -- ���������� ������� � ������ �� ��������� 1
Tree[t1s][0]=t1v -- ��������� ��������� �� �������� (���������) ������
if t1v>0 then
  v=Tree[t1s][t1v] x2,y2 = x+dx[v],y+dy[v] -- �������� ������ � ���������� ��������� ������
  if ret and x2==cx[cn] and y2==cy[cn] and t1s<full1 then -- ������ ��������� �� ������ ������?
    t1v=t1v-1 Tree[t1s][0]=t1v -- ���������� ��������� �� ���������� ������
    if t1v==0 then goto ROLLBACK else v=Tree[t1s][t1v] x2,y2 = x+dx[v],y+dy[v] end -- ������ �������� ���?
  end
  t00[x][y],t01[x][y] = v,t1s x,y = x2,y2 fw,t1s = fw+1,t1s+1 -- ��������� �� ��������� ������
  goto START -- ��������� ���
end
if t1s==full and (not ret or x==cx[cn] and y==cy[cn]) then t01[x][y]=t1s goto FINISH end -- ��������� ������?
::ROLLBACK::
repeat -- �����
  t1s=t1s-1 -- ���������� ��������� ��������� ���
  if t1s<0 then -- ���������� ������ ������?
    if ret -- ������� ���������?
    then if cn<cl then cn=cn+1 else cn,ret = 0,false end init() goto START -- �������� ������ ������ ��� ������
    else goto FINISH -- ��� ���� �����������, ���� �� ������
    end
  end
  t00[x][y],t01[x][y] = -1,-1 -- ����������� ������ x,y
  t1v=Tree[t1s][0] -- ��������������� ��������� �� ��������� �� �� ������
  v=Tree[t1s][t1v] x,y = x-dx[v],y-dy[v] rb=rb+1 -- �������� ������ � ������������ �� ������ � ������� ������
  if log then if pB<buf_size then obuf[pB] = lshift(x+1,4)+y+1 pB=pB+1 else C.fwrite(obuf,1,pB,f_out) pB=0 obuf[pB] = lshift(x+1,4)+y+1 pB=pB+1 end end -- logging
  t1v=t1v-1 Tree[t1s][0]=t1v -- �������� ������ ������ ����
until t1v>0
v=Tree[t1s][t1v] x2,y2 = x+dx[v],y+dy[v] -- �������� ������ � ���������� ��������� ������
if ret and x2==cx[cn] and y2==cy[cn] then -- ������ ��������� �� ������ ������?
  t1v=t1v-1 Tree[t1s][0]=t1v -- ���������� ��������� �� ���������� ������
  if t1v==0 then goto ROLLBACK else v=Tree[t1s][t1v] x2,y2 = x+dx[v],y+dy[v] end -- ������ �������� ���?
end
t00[x][y],t01[x][y] = v,t1s x,y = x2,y2 fw,t1s = fw+1,t1s+1 -- ��������� �� ��������� ������
goto START -- ��������� ���
::FINISH::
if log then if pB>0 then C.fwrite(obuf,1,pB,f_out) pB=0 end C.fclose(f_out) end -- logging
ttime = math.floor((far.FarClock()-ttime)/1000)/1000

-- ����� ����������� �� ����� � � ��� � %TEMP%
bx,by,x0,y0,full = bx+1,by+1,x0+1,y0+1,full+1 -- align from 0 to 1
local s0="Board: "..bx.."x"..by.."\nHoles: "..holes_show().."\nStart: "..string.format(fbx,x0)..string.format(fby,y0).."\nClosed path: "..(ret0 and "yes" or "no").."\nLogging: "..(log and "yes" or "no")
s0=s0.."\n\nSolution: "..(ret==ret0 and t1s+1==full and "found " or "not found ").."\nVisited squares: "..(t1s+1).."/"..full.."\nTime: "..ttime.." s\n"
local s1="\nPath: "..string.format(fbx,x0)..string.format(fby,y0)
x2,y2 = x0,y0
for i=0,t1s-1 do x2,y2 = x2+dx[Tree[i][Tree[i][0]]],y2+dy[Tree[i][Tree[i][0]]] s1=s1.." "..string.format(fbx,x2)..string.format(fby,y2) end
t1s,s1 = t1s+1,s1.."\n\n"
local s2,sf = "",#tostring(full)
for y=by,1,-1 do for x=1,bx do local dd=t01[x-1][y-1]+1 s2=s2..string.format((dd==1 or dd==t1s) and "[%"..sf.."d]" or " %"..sf.."d ",dd) end s2=s2.."\n" end
local s3="\n   Moves: "..(fw+rb).."\n Forward: "..fw.."\nRollback: "..rb
local h=io.open(win.GetEnv"TEMP".."\\ChessKnight.txt","wb") h:write(title.."\n\n"..s0..s1..s2..s3) h:close()
local MessageX=require"MessageX"
if MessageX then
  s0=string.find(s0,"not found") and string.gsub(s0," not found ","<#c4>%1<#rr>") or string.gsub(s0," found ","<#a2>%1<#rr>")
  s2=string.gsub(s2,"%[(.-)%]","<#f1> %1 <#rr>")
  s2=string.gsub(s2,string.rep(" ",sf).."0 ","<#ec>%1<#rr>")
  MessageX(s0..s1..s2..s3,title,nil,"c")
else far.Message(s0..s1..s2..s3,title)
end
