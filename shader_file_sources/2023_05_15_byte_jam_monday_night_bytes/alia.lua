sin=math.sin
cos=math.cos
pi=math.pi
rand=math.random
abs=math.abs
sign=math.sign
min=math.min
max=math.max

f={}
for i=1,20 do
 f[i]={
  x=rand()*240,
  y=rand()*136,
  dx=rand()*4-2,
  dy=rand()*4-2
 }
end

function bub(x,y,r)
 circb(x,y,r-1,13)
 circb(x,y,r,12)
 circ(x-r*.4,y-r*.4,r/6,12)
end

cls()
ft=0
function TIC()
 for i=0,10 do
  ft=ft+fft(i)
 end
 t=time()//100
 vbank(1)
 local x0=sin(t/2.57)*3
 local y0=sin(t/7.57)*3
 local x1=sin(t/8.24)*3
 local y1=sin(t/9.234)*3
 local x2=sin(t/5.438)*3
 local y2=sin(t/3.357)*3
 ttri(
  0,0,
  480,0,
  0,272,
  x0,y0,
  480+x1,y1,
  x2,272+y2,
  2)
 memcpy(0x4000,0,16320)
 --cls()
 vbank(0)
 memcpy(0,0x4000,16320)
 --cls()
 for j=0,3 do
 	for i=0,20 do
 	 circ(
    j*80+sin(i/3+t/5+j)*10,
    i*6.8,
    10+sin(i/3+ft/15)*5,
    5+(i/2+j+t/4)%3)--5-7
 	end
 end
 vbank(1)
 --cls()
 local ax=sin(t/8.138)*120+120
 local ay=sin(t/7.346)*68+68
 --circ(ax,ay,5,12)
 for i=1,#f do
  local fi=f[i]
  local dx=fi.x-ax
  local dy=fi.y-ay
  local l=((dx*dx)+(dy*dy))^.5
  
  --for i=0,4 do
   --circ(
    --fi.x+fi.dx*i*2,
    --fi.y+fi.dy*i*2,
    --i==0 and 5 or 3+i/2,
    --sin(fi.x/4)+sin(fi.y/4)+3)--2-4
  --end
  tri(
   fi.x+fi.dx*4,fi.y+fi.dy*4,
   fi.x+fi.dy*2,fi.y+fi.dx*4,
   fi.x-fi.dy*2,fi.y-fi.dx*4,
   sin(fi.x/24)+sin(fi.y/24)+3)
  tri(
   fi.x-fi.dx*8,fi.y-fi.dy*8,
   fi.x+fi.dy*2,fi.y+fi.dx*4,
   fi.x-fi.dy*2,fi.y-fi.dx*4,
   sin(fi.x/20)+sin(fi.y/20)+3)
  fi.x=(fi.x+fi.dx)%240
  fi.y=(fi.y+fi.dy)%136
  --fi.dx=fi.dx+fi.dy*sin(fi.x/19+sin(fi.y/17))/20
  --fi.dx=min(abs(fi.dx),3)*(fi.dx>0 and 1 or -1)
  --fi.dy=min(abs(fi.dy),3)*(fi.dy>0 and 1 or -1)
  --fi.dy=fi.dy+fi.dx*sin(fi.x/23+sin(fi.y/20))/20
		fi.dx=fi.dx-dx*(1/(l+1))/40
  fi.dy=fi.dy-dy*(1/(l+1))/40
  f[i]=fi
 end
 
 for i=0,20 do
  bub(
   (i*12+sin(t/16)*20)%260-10,
   (-t*(sin(i)+2)+sin(i*23143.35)*248)%156-10,
   10)
 end
end

function SCN(y)
 vbank(0)
 for x=0,239 do
  local p=pix(x,y)+(rand()*1.1)
  p=p>10 and 0 or p
  p=p<5 and 0 or p
  pix(x,y,p)
 end
 --vbank(1)
 --poke(0x3FF9,sin(y/20+t/4)*8//1)
 --poke(0x3FFa ,sin(y/20+t/4)*8//1)
end