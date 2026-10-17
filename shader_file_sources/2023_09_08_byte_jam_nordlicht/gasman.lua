bk={}
pal={}
for i=0,47 do
 pal[i+1]=peek(16320+i)
end

ffthist={}
for i=0,255 do
 ffthist[i]=0
end

amp=0

function bgpix(x,y,v)
 bk[y*240+x]=v
end

function BDR(y)
 mode=t//3456%3
 v1=128+64*math.sin((y-t/34)/4)
 v2=128+64*math.sin((y+t/34)/4)
 if mode==0 then
  poke(16323,v1)
  poke(16324,0)
  poke(16325,v2)
 elseif mode==1 then
  poke(16323,v2)
  poke(16324,v1)
  poke(16325,0)
 else
  poke(16323,0)
  poke(16324,v2)
  poke(16325,v1)
 end
end

function hypnotoad(x,y)
 r=math.sqrt(x*x+y*y)
 tr=3*math.sin(t/678+r/28)
 a=(math.atan2(x,y)+tr)*8/math.pi//1
 rf=(r/24+tz)//1

 bgpix(x+120,y+68,(a%2)~(rf%2))
end

function interference(x,y)
 x0=x+20*math.sin(t/269)
 y0=y+20*math.sin(t/369)
 x1=x-20*math.sin(t/269)
 y1=y-20*math.sin(t/369)

 r0=math.sqrt(x0*x0+y0*y0)//8%2
 r1=math.sqrt(x1*x1+y1*y1)//8%2

 bgpix(x+120,y+68,r0~r1)
end

-- yes folks, we're doing
-- all the classics tonight
function rotozoom(x,y)
 x1=x*math.cos(t/444)+y*math.sin(t/444)
 y1=y*math.cos(t/444)-x*math.sin(t/444)
 s=1+0.9*math.sin(t/555)
 x2=x1*s
 y2=y1*s

 bgpix(x+120,y+68,(x2//32%2)~(y2//32%2))
end

function tunnel(x,y)
 r=math.sqrt(x*x+y*y)
 rf=200/(r+5)
 a=(math.atan2(x,y))*8/math.pi//1
 
 bgpix(x+120,y+68,(a%2)~((rf+t/123)//1%2))
end

frame=0
function TIC()
ffthist[frame]=fft(1)
frame=(frame+1)%256

ca=math.cos(.05)
sa=math.sin(.05)

t=time()

tz=t/267

fxn=t//2345%4
if fxn==0 then
 fx=interference
elseif fxn==1 then
 fx=hypnotoad
elseif fxn==2 then
 fx=rotozoom
else
 fx=tunnel
end

for y=-68,68 do
 for x=-120,120 do
  x1=x*0.95
  y1=y*0.95
  x2=x1*ca+y1*sa
  y2=y1*ca-x1*sa
  p=pix(x2+120,y2+68)
  if p>1 then
   p=p-1
   bk[(y+68)*240+x+120]=p
  else
   bk[(y+68)*240+x+120]=-1
   fx(x,y)
  end
 end
end

-- HELL YEAH I FIXED IT!!!!!

for y=0,68+68 do
 for x=0,240 do
  v=bk[y*240+x]
  if v>-1 then
   pix(x,y,v)
  end
 end
end

 fftval1=fft(1)
 fftval2=fft(2)
 fftval3=fft(3)
 for x=0,239 do
  v=8*fftval1*math.sin(x/8)
   +8*fftval2*math.sin(x/16)
   +8*fftval3*math.sin(x/32)
  pix(x,64+v,8)
  pix(120+v,x,8)
 end

print("triace   messy   ektr0",0,0,14,true)

amp=8*(1+math.sin(t/67))

s=3+fft(0)*8

t1={123,135,146}
t2={234,246,268}

 circ(
  math.random(0,239),
  math.random(0,137),
  math.random(2,10),
  math.random(0,16)
 )

for n=0,2 do
 d=math.sin((n+t/1234)*math.pi*2/3)
 a=t/(t1[n+1])
 b=t/(t2[n+1])

 for x0=-24,24 do
  for y0=-4,4 do
   if pix(x0+24+n*48,y0+4)==14 then
    z0=0
    y1=y0
    x1=x0*math.cos(a)+z0*math.sin(a)
    z1=z0*math.cos(a)-x0*math.sin(a)
    x=x1*math.cos(b)+y0*math.sin(b)
    y=y1*math.cos(b)-x0*math.sin(b)
    circ(
     120+60*d +s*x,
     67+s*y,
     2,10-n)
   end
  end
 end

 rect(0,120,240,18,0)
 dy0=fft(1)*2
 dy1=fft(2)*2
 dy2=fft(3)*2
 tx=240-(t/24)%480

 line(0,132,240,132,15)
 line(0,135,240,135,15)
 for x=0,240,10 do
  line(x+4,131,x,137,15)
 end
end

 circ(tx+70,127+dy0,6,14)
 circ(tx+90,127+dy0,6,14)
 circ(tx+120,127+dy1,6,14)
 circ(tx+140,127+dy1,6,14)
 circ(tx+170,127+dy2,6,14)
 circ(tx+190,127+dy2,6,14)
 circ(tx+25,129+dy0,4,14)
 circ(tx+45,129+dy0,4,14)
 rect(tx+20,122+dy0,30,6,13)
 rect(tx+20,115+dy0,5,8,13)
 rect(tx+19,114+dy0,7,2,13)
 rect(tx+30,118+dy0,5,8,13)
 circ(tx+25,115-(t/100%10),3-(t/500%2),12)

 rect(tx+60,120+dy0,40,10,2)
 rect(tx+110,120+dy1,40,10,2)
 rect(tx+160,120+dy2,40,10,2)

 line(tx+50,128+dy0,tx+59,128+dy0,13)
 line(tx+100,128+dy0,tx+109,128+dy1,13)
 line(tx+150,128+dy1,tx+159,128+dy2,13)

 print("ektr0",tx+63,122+dy0,3)
 print("triace",tx+113,122+dy1,4)
 print("messy",tx+163,122+dy2,5)


end