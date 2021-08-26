// ChessKnight.c
// v0.9.2.1
// For fast find solution, put the compiled ChessKnight.exe to one folder with ChessKnight.lua

#include <stdint.h>
#include <stdio.h>

char *getenv(const char *name);
char *strcat(char *dest, const char *source);
char *strcpy(char *dest, const char *source);

const char *pTemp;
const char *logname="\\ChessKnight.log";
const char *txtname="\\ChessKnight.txt";
uint8_t status;
uint8_t bx; // ширина доски
uint8_t by; // высота доски
uint8_t x00; // X координата старта
uint8_t y00; // Y координата старта
uint8_t ret0; // замкнутый путь (0/1)
uint8_t log0; // вывод лога (0/1)
uint8_t x,y; // номер текущего хода, последний (текущий) вектор, координаты текущей клетки
uint32_t fw; // счётчик ходов вперёд
uint32_t rb; // счётчик возвратов (откатов)
int16_t t1s; // номер хода
int8_t t1v; // указатель на текущий вектор
const uint32_t buf_size=0x10000000; // размер кэширующего буфера в памяти для последующей записи лога на диск
unsigned char obuf[0x10000000];
// {dx,dy} - вектор хода
// порядок следования векторов в массиве определяет приоритет выбора клетки для хода среди клеток с одинаковым количеством доступных для движения векторов
int8_t dx[8]={-1,-1, 2,-2, 1, 1,-2, 2};
int8_t dy[8]={ 2,-2, 1, 1,-2, 2,-1,-1};
uint8_t ti[8]; // массив с индексами векторов на клетки, доступные для хода с клетки x,y
uint8_t ta[8]; // массив с количеством векторов у доступных для хода клеток
uint8_t ta8,ta7,ta6,ta5,ta4,ta3,ta2,ta1,ta0;
uint8_t ti8,ti7,ti6,ti5,ti4,ti3,ti2,ti1,ti0;
// 5 6 3 2 1 1 -- 13-14s
// сортируем вектора по убыванию количества векторов у целевых клеток, обеспечивая приоритет обхода клеток с наименьшим количеством входов
// алгоритм сохраняет очерёдность одинаковых значений, обеспечивая неизменность маршрутов и их конечное количество
//int8_t around(int8_t x,int8_t y)
//{
//  int8_t tl=-1;
//  for(int8_t i=7; i>=0; i--)
//  {
//    int8_t x1=x+dx[i];
//    int8_t y1=y+dy[i];
//    if(x1>=0 && x1<=bx && y1>=0 && y1<=by && t00[x1][y1]<0)
//    {
//      tl++;
//      uint8_t a=0;
//      for(int8_t j=7; j>=0; j--)
//      {
//        int8_t x2=x1+dx[j];
//        int8_t y2=y1+dy[j];
//        if(x2>=0 && x2<=bx && y2>=0 && y2<=by && t00[x2][y2]<0){a++;}
//      }
//      ta[tl]=a; ti[tl]=i;
//      if(tl>0)
//      {
//        for(int8_t i1=tl; i1>0; i1--)
//        {
//          int8_t i0=i1-1;
//          if(ta[i1]>ta[i0])
//          {
//            uint8_t tmp;
//            tmp=ta[i0]; ta[i0]=ta[i1]; ta[i1]=tmp;
//            tmp=ti[i0]; ti[i0]=ti[i1]; ti[i1]=tmp;
//          }
//          else break;
//        }
//      }
//    }
//  }
//  return tl;
//}

int main(int argc, char *argv[])
{
  pTemp=getenv("TEMP");
  int tmp;
  if(argc==1){printf("\nArgumets: bx by x0 y0 ret log hx hy...\n Example: ChessKnight.exe 7 7 1 1 1 0 4 4 4 3 4 2\nMax board size 127x127\nMax logging board size 15x15\nSee ChessKnight.log in %%TEMP%%\n"); return 1;}
  if(argc>=2){sscanf(argv[1], "%d", &tmp); bx   = tmp & 127;}else{bx   = 8;}
  if(argc>=3){sscanf(argv[2], "%d", &tmp); by   = tmp & 127;}else{by   = 8;}
  if(argc>=4){sscanf(argv[3], "%d", &tmp); x00  = tmp & 127;}else{x00  = 1;}
  if(argc>=5){sscanf(argv[4], "%d", &tmp); y00  = tmp & 127;}else{y00  = 1;}
  if(argc>=6){sscanf(argv[5], "%d", &tmp); ret0 = tmp &   1;}else{ret0 = 0;}
  if(argc>=7){sscanf(argv[6], "%d", &tmp); log0 = tmp &   1;}else{log0 = 0;}
  uint8_t ret=ret0;
  int8_t  t00[bx][by]; // слой векторов с дырами
  int16_t t01[bx][by]; // слой нумерации ходов
  printf("Looking for a solution...\n");
  printf("\nBoard size: %dx%d, ret %d, log %d", bx, by, ret0, log0);
  if(argc>7){printf("\nHoles:"); for(uint8_t i=0; i<argc-7; i++,i++){if(i>1) printf(","); printf(" h%d %s %s", i>>1, argv[i+7], argv[i+8]);}}
  int16_t full = argc>7 ? bx*by-((argc-7)>>1) : bx*by;
  if(ret!=0 && (full & 1)!=0){ret=0;}
  uint8_t Tree[full][8]; // дерево, содержащее вектора возможных ходов
  uint8_t tv[full]; // активный (последний) вектор
  bx--; by--; x00--; y00--; full--; // align from 1 to 0 based
  for(uint8_t x=0; x<=full; x++){tv[x]=0xFF; for(uint8_t y=0; y<=7; y++){Tree[x][y]=0xFF;}} // инициализация Tree {{0xFF}}
  if(ret!=ret0 || (log0!=0 && (bx>15 || by>15)))
  {
    printf("\nUse:");
    if(ret!=ret0){printf(" ret %d", ret);}
    if(log0!=0 && (bx>15 || by>15)){log0=0; if(ret!=ret0){printf(",");} printf(" log %d", log0);}
  }
  printf("\n Start: %d %d", x00+1, y00+1);
  for(uint8_t x=0; x<=bx; x++){for(uint8_t y=0; y<=by; y++){t00[x][y]=-1; t01[x][y]=-1;}} // инициализация t00, t01 {{-1}}
  // расставляем дыры
  if(argc>7)
  {
    uint8_t x,y;
    for(uint8_t i=7; i<argc; i++,i++)
    {
      sscanf(argv[i  ], "%d", &tmp); x = tmp & 127;
      sscanf(argv[i+1], "%d", &tmp); y = tmp & 127;
      t00[x-1][y-1] = 8;
    }
  }
  
  t1s=0; x=x00; y=y00; // инициализация
  
  int8_t cx[8]; // массив с x координатами клеток 1-го хода (финиша)
  int8_t cy[8]; // массив с y координатами клеток 1-го хода (финиша)
  uint8_t cn=0; // индекс клетки финиша, количество клеток на расстоянии 1 хода от старта

  //int8_t cl=around(x,y); // индекс клетки финиша, количество клеток на расстоянии 1 хода от старта
  int8_t cl=-1;
  for(uint8_t i=0; i<=7; i++)
  {
    int8_t x1=x+dx[i];
    int8_t y1=y+dy[i];
    if(x1>=0 && x1<=bx && y1>=0 && y1<=by && t00[x1][y1]<0)
    {
      cl++;
      uint8_t a=0;
      for(uint8_t j=0; j<=7; j++)
      {
        int8_t x2=x1+dx[j];
        int8_t y2=y1+dy[j];
        if(x2>=0 && x2<=bx && y2>=0 && y2<=by && t00[x2][y2]<0){a++;}
      }
      ta[cl]=a; ti[cl]=i;
      if(cl>0)
      {
        for(int8_t i1=cl; i1>0; i1--)
        {
          int8_t i0=i1-1;
          if(ta[i1]>ta[i0])
          {
            uint8_t tmp;
            tmp=ta[i0]; ta[i0]=ta[i1]; ta[i1]=tmp;
            tmp=ti[i0]; ti[i0]=ti[i1]; ti[i1]=tmp;
          }
          else break;
        }
      }
    }
  }
  for(uint8_t i=0; i<=cl; i++)
  {
    cx[i]=x+dx[ti[i]];
    cy[i]=y+dy[ti[i]];
  } // массив координат клеток на расстоянии 1 хода от старта t1s=1
  
  // logging max board 15x15 - xy stored in 1 byte
  uint32_t bsz=0;
  FILE *f_out;
  if(log0!=0)
  {
    char pPath[512];
    strcpy(pPath, pTemp);
    f_out=fopen(strcat(pPath, logname),"wb");
    if(f_out==NULL){printf("Error: can't open the file\n"); return 1;} // exit
  }

  fw=1; rb=0;
  int16_t full1=full-1; // предпоследний ход

  START:
  {
    if(log0!=0){if(bsz==buf_size){fwrite(obuf,1,bsz,f_out); bsz=0;} obuf[bsz]=((x+1)<<4)+y+1; bsz++;} // logging
    //t1v=around(x,y)+1; // указатель, хранящий количество векторов на доступные для хода клетки, указывает на активный (последний) вектор
    t1v=-1;
    // разворачивание 2-x вложенных циклов + распараллеливание
    //int8_t dx[8]={-1,-1, 2,-2, 1, 1,-2, 2};
    //int8_t dy[8]={ 2,-2, 1, 1,-2, 2,-1,-1};
    {
      int8_t x8=x-1;
      int8_t y8=y+2;
      uint8_t xx=(x8>=0) && (x8<=bx);
      uint8_t yy=(y8>=0) && (y8<=by);
      if((xx>0) && (yy>0) && (t00[x8][y8]<0))
      {
        int8_t x8m1=x8-1;
        int8_t x8m2=x8-2;
        int8_t x8p1=x8+1;
        int8_t x8p2=x8+2;
        int8_t y8m1=y8-1;
        int8_t y8m2=y8-2;
        int8_t y8p1=y8+1;
        int8_t y8p2=y8+2;
        uint8_t xm1=(x8m1>=0) && (x8m1<=bx);
        uint8_t xm2=(x8m2>=0) && (x8m2<=bx);
        uint8_t xp1=(x8p1>=0) && (x8p1<=bx);
        uint8_t xp2=(x8p2>=0) && (x8p2<=bx);
        uint8_t ym1=(y8m1>=0) && (y8m1<=by);
        uint8_t ym2=(y8m2>=0) && (y8m2<=by);
        uint8_t yp1=(y8p1>=0) && (y8p1<=by);
        uint8_t yp2=(y8p2>=0) && (y8p2<=by);
        uint8_t a=0;
        if((xm2>0) && (yp1>0) && (t00[x8m2][y8p1]<0)){a++;}
        if((xm2>0) && (ym1>0) && (t00[x8m2][y8m1]<0)){a++;}
        if((xm1>0) && (yp2>0) && (t00[x8m1][y8p2]<0)){a++;}
        if((xm1>0) && (ym2>0) && (t00[x8m1][y8m2]<0)){a++;}
        if((xp1>0) && (ym2>0) && (t00[x8p1][y8m2]<0)){a++;}
        if((xp1>0) && (yp2>0) && (t00[x8p1][y8p2]<0)){a++;}
        if((xp2>0) && (yp1>0) && (t00[x8p2][y8p1]<0)){a++;}
        if((xp2>0) && (ym1>0) && (t00[x8p2][y8m1]<0)){a++;}
        t1v++; //ta[t1v]=a; ti[t1v]=0;
        ta0=a; ti0=0;
      }
    }
    //int8_t dx[8]={-1,-1, 2,-2, 1, 1,-2, 2};
    //int8_t dy[8]={ 2,-2, 1, 1,-2, 2,-1,-1};
    {
      int8_t x8=x-1;
      int8_t y8=y-2;
      uint8_t xx=(x8>=0) && (x8<=bx);
      uint8_t yy=(y8>=0) && (y8<=by);
      if((xx>0) && (yy>0) && (t00[x8][y8]<0))
      {
        int8_t x8m1=x8-1;
        int8_t x8m2=x8-2;
        int8_t x8p1=x8+1;
        int8_t x8p2=x8+2;
        int8_t y8m1=y8-1;
        int8_t y8m2=y8-2;
        int8_t y8p1=y8+1;
        int8_t y8p2=y8+2;
        uint8_t xm1=(x8m1>=0) && (x8m1<=bx);
        uint8_t xm2=(x8m2>=0) && (x8m2<=bx);
        uint8_t xp1=(x8p1>=0) && (x8p1<=bx);
        uint8_t xp2=(x8p2>=0) && (x8p2<=bx);
        uint8_t ym1=(y8m1>=0) && (y8m1<=by);
        uint8_t ym2=(y8m2>=0) && (y8m2<=by);
        uint8_t yp1=(y8p1>=0) && (y8p1<=by);
        uint8_t yp2=(y8p2>=0) && (y8p2<=by);
        uint8_t a=0;
        if((xm2>0) && (yp1>0) && (t00[x8m2][y8p1]<0)){a++;}
        if((xm2>0) && (ym1>0) && (t00[x8m2][y8m1]<0)){a++;}
        if((xm1>0) && (yp2>0) && (t00[x8m1][y8p2]<0)){a++;}
        if((xm1>0) && (ym2>0) && (t00[x8m1][y8m2]<0)){a++;}
        if((xp1>0) && (ym2>0) && (t00[x8p1][y8m2]<0)){a++;}
        if((xp1>0) && (yp2>0) && (t00[x8p1][y8p2]<0)){a++;}
        if((xp2>0) && (yp1>0) && (t00[x8p2][y8p1]<0)){a++;}
        if((xp2>0) && (ym1>0) && (t00[x8p2][y8m1]<0)){a++;}
        t1v++; //ta[t1v]=a; ti[t1v]=1;
        if     (t1v==0){ta0=a; ti0=1;}
        else if(t1v==1){ta1=a; ti1=1;}
        if((t1v>0) && (ta1>ta0)){ta8=ta1; ti8=ti1; ta1=ta0; ti1=ti0; ta0=ta8; ti0=ti8;}
      }
    } 
    //int8_t dx[8]={-1,-1, 2,-2, 1, 1,-2, 2};
    //int8_t dy[8]={ 2,-2, 1, 1,-2, 2,-1,-1};
    {
      int8_t x8=x+2;
      int8_t y8=y+1;
      uint8_t xx=(x8>=0) && (x8<=bx);
      uint8_t yy=(y8>=0) && (y8<=by);
      if((xx>0) && (yy>0) && (t00[x8][y8]<0))
      {
        int8_t x8m1=x8-1;
        int8_t x8m2=x8-2;
        int8_t x8p1=x8+1;
        int8_t x8p2=x8+2;
        int8_t y8m1=y8-1;
        int8_t y8m2=y8-2;
        int8_t y8p1=y8+1;
        int8_t y8p2=y8+2;
        uint8_t xm1=(x8m1>=0) && (x8m1<=bx);
        uint8_t xm2=(x8m2>=0) && (x8m2<=bx);
        uint8_t xp1=(x8p1>=0) && (x8p1<=bx);
        uint8_t xp2=(x8p2>=0) && (x8p2<=bx);
        uint8_t ym1=(y8m1>=0) && (y8m1<=by);
        uint8_t ym2=(y8m2>=0) && (y8m2<=by);
        uint8_t yp1=(y8p1>=0) && (y8p1<=by);
        uint8_t yp2=(y8p2>=0) && (y8p2<=by);
        uint8_t a=0;
        if((xm2>0) && (yp1>0) && (t00[x8m2][y8p1]<0)){a++;}
        if((xm2>0) && (ym1>0) && (t00[x8m2][y8m1]<0)){a++;}
        if((xm1>0) && (yp2>0) && (t00[x8m1][y8p2]<0)){a++;}
        if((xm1>0) && (ym2>0) && (t00[x8m1][y8m2]<0)){a++;}
        if((xp1>0) && (ym2>0) && (t00[x8p1][y8m2]<0)){a++;}
        if((xp1>0) && (yp2>0) && (t00[x8p1][y8p2]<0)){a++;}
        if((xp2>0) && (yp1>0) && (t00[x8p2][y8p1]<0)){a++;}
        if((xp2>0) && (ym1>0) && (t00[x8p2][y8m1]<0)){a++;}
        t1v++; //ta[t1v]=a; ti[t1v]=2;
        if     (t1v==0){ta0=a; ti0=2;}
        else if(t1v==1){ta1=a; ti1=2;}
        else if(t1v==2){ta2=a; ti2=2;}
        if((t1v>1) && (ta2>ta1)){ta8=ta2; ti8=ti2; ta2=ta1; ti2=ti1; ta1=ta8; ti1=ti8;}
        if((t1v>0) && (ta1>ta0)){ta8=ta1; ti8=ti1; ta1=ta0; ti1=ti0; ta0=ta8; ti0=ti8;}
      }
    }
    //int8_t dx[8]={-1,-1, 2,-2, 1, 1,-2, 2};
    //int8_t dy[8]={ 2,-2, 1, 1,-2, 2,-1,-1};
    {
      int8_t x8=x-2;
      int8_t y8=y+1;
      uint8_t xx=(x8>=0) && (x8<=bx);
      uint8_t yy=(y8>=0) && (y8<=by);
      if((xx>0) && (yy>0) && (t00[x8][y8]<0))
      {
        int8_t x8m1=x8-1;
        int8_t x8m2=x8-2;
        int8_t x8p1=x8+1;
        int8_t x8p2=x8+2;
        int8_t y8m1=y8-1;
        int8_t y8m2=y8-2;
        int8_t y8p1=y8+1;
        int8_t y8p2=y8+2;
        uint8_t xm1=(x8m1>=0) && (x8m1<=bx);
        uint8_t xm2=(x8m2>=0) && (x8m2<=bx);
        uint8_t xp1=(x8p1>=0) && (x8p1<=bx);
        uint8_t xp2=(x8p2>=0) && (x8p2<=bx);
        uint8_t ym1=(y8m1>=0) && (y8m1<=by);
        uint8_t ym2=(y8m2>=0) && (y8m2<=by);
        uint8_t yp1=(y8p1>=0) && (y8p1<=by);
        uint8_t yp2=(y8p2>=0) && (y8p2<=by);
        uint8_t a=0;
        if((xm2>0) && (yp1>0) && (t00[x8m2][y8p1]<0)){a++;}
        if((xm2>0) && (ym1>0) && (t00[x8m2][y8m1]<0)){a++;}
        if((xm1>0) && (yp2>0) && (t00[x8m1][y8p2]<0)){a++;}
        if((xm1>0) && (ym2>0) && (t00[x8m1][y8m2]<0)){a++;}
        if((xp1>0) && (ym2>0) && (t00[x8p1][y8m2]<0)){a++;}
        if((xp1>0) && (yp2>0) && (t00[x8p1][y8p2]<0)){a++;}
        if((xp2>0) && (yp1>0) && (t00[x8p2][y8p1]<0)){a++;}
        if((xp2>0) && (ym1>0) && (t00[x8p2][y8m1]<0)){a++;}
        t1v++; //ta[t1v]=a; ti[t1v]=3;
        if     (t1v==0){ta0=a; ti0=3;}
        else if(t1v==1){ta1=a; ti1=3;}
        else if(t1v==2){ta2=a; ti2=3;}
        else if(t1v==3){ta3=a; ti3=3;}
        if((t1v>2) && (ta3>ta2)){ta8=ta3; ti8=ti3; ta3=ta2; ti3=ti2; ta2=ta8; ti2=ti8;}
        if((t1v>1) && (ta2>ta1)){ta8=ta2; ti8=ti2; ta2=ta1; ti2=ti1; ta1=ta8; ti1=ti8;}
        if((t1v>0) && (ta1>ta0)){ta8=ta1; ti8=ti1; ta1=ta0; ti1=ti0; ta0=ta8; ti0=ti8;}
      }
    }
    //int8_t dx[8]={-1,-1, 2,-2, 1, 1,-2, 2};
    //int8_t dy[8]={ 2,-2, 1, 1,-2, 2,-1,-1};
    {
      int8_t x8=x+1;
      int8_t y8=y-2;
      uint8_t xx=(x8>=0) && (x8<=bx);
      uint8_t yy=(y8>=0) && (y8<=by);
      if((xx>0) && (yy>0) && (t00[x8][y8]<0))
      {
        int8_t x8m1=x8-1;
        int8_t x8m2=x8-2;
        int8_t x8p1=x8+1;
        int8_t x8p2=x8+2;
        int8_t y8m1=y8-1;
        int8_t y8m2=y8-2;
        int8_t y8p1=y8+1;
        int8_t y8p2=y8+2;
        uint8_t xm1=(x8m1>=0) && (x8m1<=bx);
        uint8_t xm2=(x8m2>=0) && (x8m2<=bx);
        uint8_t xp1=(x8p1>=0) && (x8p1<=bx);
        uint8_t xp2=(x8p2>=0) && (x8p2<=bx);
        uint8_t ym1=(y8m1>=0) && (y8m1<=by);
        uint8_t ym2=(y8m2>=0) && (y8m2<=by);
        uint8_t yp1=(y8p1>=0) && (y8p1<=by);
        uint8_t yp2=(y8p2>=0) && (y8p2<=by);
        uint8_t a=0;
        if((xm2>0) && (yp1>0) && (t00[x8m2][y8p1]<0)){a++;}
        if((xm2>0) && (ym1>0) && (t00[x8m2][y8m1]<0)){a++;}
        if((xm1>0) && (yp2>0) && (t00[x8m1][y8p2]<0)){a++;}
        if((xm1>0) && (ym2>0) && (t00[x8m1][y8m2]<0)){a++;}
        if((xp1>0) && (ym2>0) && (t00[x8p1][y8m2]<0)){a++;}
        if((xp1>0) && (yp2>0) && (t00[x8p1][y8p2]<0)){a++;}
        if((xp2>0) && (yp1>0) && (t00[x8p2][y8p1]<0)){a++;}
        if((xp2>0) && (ym1>0) && (t00[x8p2][y8m1]<0)){a++;}
        t1v++; //ta[t1v]=a; ti[t1v]=4;
        if     (t1v==0){ta0=a; ti0=4;}
        else if(t1v==1){ta1=a; ti1=4;}
        else if(t1v==2){ta2=a; ti2=4;}
        else if(t1v==3){ta3=a; ti3=4;}
        else if(t1v==4){ta4=a; ti4=4;}
        if((t1v>3) && (ta4>ta3)){ta8=ta4; ti8=ti4; ta4=ta3; ti4=ti3; ta3=ta8; ti3=ti8;}
        if((t1v>2) && (ta3>ta2)){ta8=ta3; ti8=ti3; ta3=ta2; ti3=ti2; ta2=ta8; ti2=ti8;}
        if((t1v>1) && (ta2>ta1)){ta8=ta2; ti8=ti2; ta2=ta1; ti2=ti1; ta1=ta8; ti1=ti8;}
        if((t1v>0) && (ta1>ta0)){ta8=ta1; ti8=ti1; ta1=ta0; ti1=ti0; ta0=ta8; ti0=ti8;}
      }
    }
    //int8_t dx[8]={-1,-1, 2,-2, 1, 1,-2, 2};
    //int8_t dy[8]={ 2,-2, 1, 1,-2, 2,-1,-1};
    {
      int8_t x8=x+1;
      int8_t y8=y+2;
      uint8_t xx=(x8>=0) && (x8<=bx);
      uint8_t yy=(y8>=0) && (y8<=by);
      if((xx>0) && (yy>0) && (t00[x8][y8]<0))
      {
        int8_t x8m1=x8-1;
        int8_t x8m2=x8-2;
        int8_t x8p1=x8+1;
        int8_t x8p2=x8+2;
        int8_t y8m1=y8-1;
        int8_t y8m2=y8-2;
        int8_t y8p1=y8+1;
        int8_t y8p2=y8+2;
        uint8_t xm1=(x8m1>=0) && (x8m1<=bx);
        uint8_t xm2=(x8m2>=0) && (x8m2<=bx);
        uint8_t xp1=(x8p1>=0) && (x8p1<=bx);
        uint8_t xp2=(x8p2>=0) && (x8p2<=bx);
        uint8_t ym1=(y8m1>=0) && (y8m1<=by);
        uint8_t ym2=(y8m2>=0) && (y8m2<=by);
        uint8_t yp1=(y8p1>=0) && (y8p1<=by);
        uint8_t yp2=(y8p2>=0) && (y8p2<=by);
        uint8_t a=0;
        if((xm2>0) && (yp1>0) && (t00[x8m2][y8p1]<0)){a++;}
        if((xm2>0) && (ym1>0) && (t00[x8m2][y8m1]<0)){a++;}
        if((xm1>0) && (yp2>0) && (t00[x8m1][y8p2]<0)){a++;}
        if((xm1>0) && (ym2>0) && (t00[x8m1][y8m2]<0)){a++;}
        if((xp1>0) && (ym2>0) && (t00[x8p1][y8m2]<0)){a++;}
        if((xp1>0) && (yp2>0) && (t00[x8p1][y8p2]<0)){a++;}
        if((xp2>0) && (yp1>0) && (t00[x8p2][y8p1]<0)){a++;}
        if((xp2>0) && (ym1>0) && (t00[x8p2][y8m1]<0)){a++;}
        t1v++; //ta[t1v]=a; ti[t1v]=5;
        if     (t1v==0){ta0=a; ti0=5;}
        else if(t1v==1){ta1=a; ti1=5;}
        else if(t1v==2){ta2=a; ti2=5;}
        else if(t1v==3){ta3=a; ti3=5;}
        else if(t1v==4){ta4=a; ti4=5;}
        else if(t1v==5){ta5=a; ti5=5;}
        if((t1v>4) && (ta5>ta4)){ta8=ta5; ti8=ti5; ta5=ta4; ti5=ti4; ta4=ta8; ti4=ti8;}
        if((t1v>3) && (ta4>ta3)){ta8=ta4; ti8=ti4; ta4=ta3; ti4=ti3; ta3=ta8; ti3=ti8;}
        if((t1v>2) && (ta3>ta2)){ta8=ta3; ti8=ti3; ta3=ta2; ti3=ti2; ta2=ta8; ti2=ti8;}
        if((t1v>1) && (ta2>ta1)){ta8=ta2; ti8=ti2; ta2=ta1; ti2=ti1; ta1=ta8; ti1=ti8;}
        if((t1v>0) && (ta1>ta0)){ta8=ta1; ti8=ti1; ta1=ta0; ti1=ti0; ta0=ta8; ti0=ti8;}
      }
    }
    //int8_t dx[8]={-1,-1, 2,-2, 1, 1,-2, 2};
    //int8_t dy[8]={ 2,-2, 1, 1,-2, 2,-1,-1};
    {
      int8_t x8=x-2;
      int8_t y8=y-1;
      uint8_t xx=(x8>=0) && (x8<=bx);
      uint8_t yy=(y8>=0) && (y8<=by);
      if((xx>0) && (yy>0) && (t00[x8][y8]<0))
      {
        int8_t x8m1=x8-1;
        int8_t x8m2=x8-2;
        int8_t x8p1=x8+1;
        int8_t x8p2=x8+2;
        int8_t y8m1=y8-1;
        int8_t y8m2=y8-2;
        int8_t y8p1=y8+1;
        int8_t y8p2=y8+2;
        uint8_t xm1=(x8m1>=0) && (x8m1<=bx);
        uint8_t xm2=(x8m2>=0) && (x8m2<=bx);
        uint8_t xp1=(x8p1>=0) && (x8p1<=bx);
        uint8_t xp2=(x8p2>=0) && (x8p2<=bx);
        uint8_t ym1=(y8m1>=0) && (y8m1<=by);
        uint8_t ym2=(y8m2>=0) && (y8m2<=by);
        uint8_t yp1=(y8p1>=0) && (y8p1<=by);
        uint8_t yp2=(y8p2>=0) && (y8p2<=by);
        uint8_t a=0;
        if((xm2>0) && (yp1>0) && (t00[x8m2][y8p1]<0)){a++;}
        if((xm2>0) && (ym1>0) && (t00[x8m2][y8m1]<0)){a++;}
        if((xm1>0) && (yp2>0) && (t00[x8m1][y8p2]<0)){a++;}
        if((xm1>0) && (ym2>0) && (t00[x8m1][y8m2]<0)){a++;}
        if((xp1>0) && (ym2>0) && (t00[x8p1][y8m2]<0)){a++;}
        if((xp1>0) && (yp2>0) && (t00[x8p1][y8p2]<0)){a++;}
        if((xp2>0) && (yp1>0) && (t00[x8p2][y8p1]<0)){a++;}
        if((xp2>0) && (ym1>0) && (t00[x8p2][y8m1]<0)){a++;}
        t1v++; //ta[t1v]=a; ti[t1v]=6;
        if     (t1v==0){ta0=a; ti0=6;}
        else if(t1v==1){ta1=a; ti1=6;}
        else if(t1v==2){ta2=a; ti2=6;}
        else if(t1v==3){ta3=a; ti3=6;}
        else if(t1v==4){ta4=a; ti4=6;}
        else if(t1v==5){ta5=a; ti5=6;}
        else if(t1v==6){ta6=a; ti6=6;}
        if((t1v>5) && (ta6>ta5)){ta8=ta6; ti8=ti6; ta6=ta5; ti6=ti5; ta5=ta8; ti5=ti8;}
        if((t1v>4) && (ta5>ta4)){ta8=ta5; ti8=ti5; ta5=ta4; ti5=ti4; ta4=ta8; ti4=ti8;}
        if((t1v>3) && (ta4>ta3)){ta8=ta4; ti8=ti4; ta4=ta3; ti4=ti3; ta3=ta8; ti3=ti8;}
        if((t1v>2) && (ta3>ta2)){ta8=ta3; ti8=ti3; ta3=ta2; ti3=ti2; ta2=ta8; ti2=ti8;}
        if((t1v>1) && (ta2>ta1)){ta8=ta2; ti8=ti2; ta2=ta1; ti2=ti1; ta1=ta8; ti1=ti8;}
        if((t1v>0) && (ta1>ta0)){ta8=ta1; ti8=ti1; ta1=ta0; ti1=ti0; ta0=ta8; ti0=ti8;}
      }
    }
    //int8_t dx[8]={-1,-1, 2,-2, 1, 1,-2, 2};
    //int8_t dy[8]={ 2,-2, 1, 1,-2, 2,-1,-1};
    {
      int8_t x8=x+2;
      int8_t y8=y-1;
      uint8_t xx=(x8>=0) && (x8<=bx);
      uint8_t yy=(y8>=0) && (y8<=by);
      if((xx>0) && (yy>0) && (t00[x8][y8]<0))
      {
        int8_t x8m1=x8-1;
        int8_t x8m2=x8-2;
        int8_t x8p1=x8+1;
        int8_t x8p2=x8+2;
        int8_t y8m1=y8-1;
        int8_t y8m2=y8-2;
        int8_t y8p1=y8+1;
        int8_t y8p2=y8+2;
        uint8_t xm1=(x8m1>=0) && (x8m1<=bx);
        uint8_t xm2=(x8m2>=0) && (x8m2<=bx);
        uint8_t xp1=(x8p1>=0) && (x8p1<=bx);
        uint8_t xp2=(x8p2>=0) && (x8p2<=bx);
        uint8_t ym1=(y8m1>=0) && (y8m1<=by);
        uint8_t ym2=(y8m2>=0) && (y8m2<=by);
        uint8_t yp1=(y8p1>=0) && (y8p1<=by);
        uint8_t yp2=(y8p2>=0) && (y8p2<=by);
        uint8_t a=0;
        if((xm2>0) && (yp1>0) && (t00[x8m2][y8p1]<0)){a++;}
        if((xm2>0) && (ym1>0) && (t00[x8m2][y8m1]<0)){a++;}
        if((xm1>0) && (yp2>0) && (t00[x8m1][y8p2]<0)){a++;}
        if((xm1>0) && (ym2>0) && (t00[x8m1][y8m2]<0)){a++;}
        if((xp1>0) && (ym2>0) && (t00[x8p1][y8m2]<0)){a++;}
        if((xp1>0) && (yp2>0) && (t00[x8p1][y8p2]<0)){a++;}
        if((xp2>0) && (yp1>0) && (t00[x8p2][y8p1]<0)){a++;}
        if((xp2>0) && (ym1>0) && (t00[x8p2][y8m1]<0)){a++;}
        t1v++; //ta[t1v]=a; ti[t1v]=7;
        if     (t1v==0){ta0=a; ti0=7;}
        else if(t1v==1){ta1=a; ti1=7;}
        else if(t1v==2){ta2=a; ti2=7;}
        else if(t1v==3){ta3=a; ti3=7;}
        else if(t1v==4){ta4=a; ti4=7;}
        else if(t1v==5){ta5=a; ti5=7;}
        else if(t1v==6){ta6=a; ti6=7;}
        else if(t1v==7){ta7=a; ti7=7;}
        if((t1v>6) && (ta7>ta6)){ta8=ta7; ti8=ti7; ta7=ta6; ti7=ti6; ta6=ta8; ti6=ti8;}
        if((t1v>5) && (ta6>ta5)){ta8=ta6; ti8=ti6; ta6=ta5; ti6=ti5; ta5=ta8; ti5=ti8;}
        if((t1v>4) && (ta5>ta4)){ta8=ta5; ti8=ti5; ta5=ta4; ti5=ti4; ta4=ta8; ti4=ti8;}
        if((t1v>3) && (ta4>ta3)){ta8=ta4; ti8=ti4; ta4=ta3; ti4=ti3; ta3=ta8; ti3=ti8;}
        if((t1v>2) && (ta3>ta2)){ta8=ta3; ti8=ti3; ta3=ta2; ti3=ti2; ta2=ta8; ti2=ti8;}
        if((t1v>1) && (ta2>ta1)){ta8=ta2; ti8=ti2; ta2=ta1; ti2=ti1; ta1=ta8; ti1=ti8;}
        if((t1v>0) && (ta1>ta0)){ta8=ta1; ti8=ti1; ta1=ta0; ti1=ti0; ta0=ta8; ti0=ti8;}
      }
    }
    //if(t1v>0)
    //{
    //  for(uint8_t i2=t1v; i2>0; i2--)
    //  {
    //    for(int8_t i0=0; i0<i2; i0++)
    //    {
    //      int8_t i1=i0+1;
    //      if(ta[i0]<ta[i1])
    //      {
    //        uint8_t tmp1=ta[i1]; ta[i1]=ta[i0]; ta[i0]=tmp1;
    //        uint8_t tmp2=ti[i1]; ti[i1]=ti[i0]; ti[i0]=tmp2;
    //      }
    //    }
    //  }
    //}
  }
  if(t1v>=0)
  {
    //for(uint8_t i=0; i<=t1v; i++){Tree[t1s][i]=ti[i];} // записываем вектора в дерево со смещением 1
    if(t1v>6){Tree[t1s][7]=ti7;}
    if(t1v>5){Tree[t1s][6]=ti6;}
    if(t1v>4){Tree[t1s][5]=ti5;}
    if(t1v>3){Tree[t1s][4]=ti4;}
    if(t1v>2){Tree[t1s][3]=ti3;}
    if(t1v>1){Tree[t1s][2]=ti2;}
    if(t1v>0){Tree[t1s][1]=ti1;}
    Tree[t1s][0]=ti0; 
    FORWARD:
    {
      // сохраняем указатель на активный (последний) вектор
      tv[t1s]=t1v; uint8_t v=Tree[t1s][t1v]; uint8_t x2=x+dx[v]; uint8_t y2=y+dy[v]; // получаем вектор и координаты следующей клетки
      if(((ret!=0) && (t1s<full1)) && ((x2==cx[cn]) && (y2==cy[cn])))
      { // вектор указывает на клетку финиша?
        t1v--; // перемещаем указатель на предыдущий вектор
        if(t1v<0){goto ROLLBACK;}else{tv[t1s]=t1v; v=Tree[t1s][t1v]; x2=x+dx[v]; y2=y+dy[v];} // получаем вектор и координаты следующей клетки, если векторов больше нет, то
      }
      t00[x][y]=v; t01[x][y]=t1s; x=x2; y=y2; fw++; t1s++; // переходим на следующую клетку
    }
    goto START; // следующий ход
  }
  if((t1s==full) && ((ret==0) || ((x==cx[cn]) && (y==cy[cn])))){t01[x][y]=t1s; status=ret==ret0 ? 1 : 2; goto FINISH;} // последняя клетка?
  ROLLBACK: // откат
  {
    tv[t1s]=0xFF;
    t1s--; // откатываем последний неудачный ход
    if(t1s<0)
    { // достигнута клетка старта?
      if(ret!=0) // маршрут замкнутый?
      {
        if(cn<cl){cn++;}else{cn=0; ret=0;} // резервируем следующую финишную клетку, либо размыкаем путь
        t1s=0; x=x00; y=y00; // инициализация
        goto START; // выбираем другую клетку для финиша
      }
      else{goto FINISH;} // все пути испробованы, путь не найден
    }
    t00[x][y]=-1; t01[x][y]=-1; // освобождаем клетку x,y
    t1v=tv[t1s]; // восстанавливаем указатель на приведший на неё вектор
    uint8_t v=Tree[t1s][t1v]; x-=dx[v]; y-=dy[v]; rb++; // получаем вектор и возвращаемся на клетку с которой пришли
    if(log0!=0){if(bsz==buf_size){fwrite(obuf,1,bsz,f_out); bsz=0;} obuf[bsz]=((x+1)<<4)+y+1; bsz++;} // logging
    t1v--; // перемещаем указатель на предыдущий вектор
  }
  if(t1v<0){goto ROLLBACK;}else{goto FORWARD;} // следующий ход

  FINISH:
  {
    if (log0!=0){if(bsz>0){fwrite(obuf,1,bsz,f_out);} fclose(f_out);} // logging
    
    // экспорт данных для ChessKnight.lua
    char pPath[512];
    strcpy(pPath, pTemp);
    f_out=fopen(strcat(pPath, txtname),"wb");
    if(f_out==NULL){printf("Error: can't open the file\n"); return 1;} // exit
    uint32_t variants=0;
    if(t1s>=0){for(int16_t i=t1s; i>=0; i--){if(tv[i]<=7){variants+=tv[i]+1;}}}else{variants=0;}
    fwrite(&status,1,sizeof(status),f_out); // статус
    fwrite(&x,1,sizeof(x),f_out); // X координата финиша
    fwrite(&y,1,sizeof(y),f_out); // Y координата финиша
    fwrite(&t1s,1,sizeof(t1s),f_out); // количество ходов
    fwrite(&fw,1,sizeof(fw),f_out); // количество ходов вперёд
    fwrite(&rb,1,sizeof(rb),f_out); // количество откатов
    fwrite(&variants,1,sizeof(variants),f_out); // сумма вариантов ходов
    fwrite(t00,1,sizeof(t00),f_out);
    fwrite(t01,1,sizeof(t01),f_out);
    fwrite(Tree,1,sizeof(Tree),f_out);
    fwrite(tv,1,sizeof(tv),f_out);
    fclose(f_out);
    
    printf("\nFinish: %d %d", ++x, ++y);
    printf("\nVisited squares: %d/%d", ++t1s, ++full);
    printf("\n   Moves: %d", fw+rb);
    printf("\n Forward: %d", fw);
    printf("\nRollback: %d", rb);
    printf("\nVariants: %d", variants);
    printf("\n  Status: %d", status);
  }
  return 0; // exit
}
