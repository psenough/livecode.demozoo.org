sin=math.sin
cos=math.cos
min=math.min
max=math.max
rand=math.random

t=0


for i=0,15 do
 local c=(i/14)*200
 for j=0,2 do
  if i==15 then c=j==0 and 255 or 0 end
  vbank(0)
 	poke(16320+i*3+j,c)
  vbank(1)
 	poke(16320+i*3+j,c)
 end
end

bat={x=131,y=50}
batasp=bat.x/bat.y

function makebat()
 --cls()
 clip(0,0,bat.x,bat.y)
 local y=45
 local w=sin(t/10)*4
 local h=sin(t/10+1)*2
 local b=sin(t/10+.5)*4
 
 elli(40,y+w-2,40,30,14)
 elli(90,y+w-2,40,30,14)
 elli(40,y+w,40,30,4)
 elli(90,y+w,40,30,4)
 
 elli(20,y+w+10,30,20,0)
 elli(110,y+w+10,30,20,0)
 elli(65,y+w+10,30,20,0)
 
 circ(65,y+b-12,12,6)
 
 elli(61,y+h-38,3,4,14)
 elli(61,y+h-36,3,4,5)
 elli(69,y+h-38,3,4,14)
 elli(69,y+h-36,3,4,5)
 
 circ(65,y+h-30,8,14)
 circ(65,y+h-28,8,8)
 circ(62,y+h-30,2,15)
 circ(68,y+h-30,2,15)
 
 clip()
end

function drawbat(x,y,s)
 local sx=s/2
 local sy=s/(2*batasp)
 local p0={x=-sx+x,y=-sy+y}
 local p1={x=sx+x,y=-sy+y}
 local p2={x=-sx+x,y=sy+y}
 local p3={x=sx+x,y=sy+y}
 
 ttri(
  p0.x,p0.y,
  p1.x,p1.y,
  p2.x,p2.y,
  0,0,
  bat.x,0,
  0,bat.y,
  2,0)
 ttri(
  p1.x,p1.y,
  p2.x,p2.y,
  p3.x,p3.y,
  bat.x,0,
  0,bat.y,
  bat.x,bat.y,
  2,0)
end

bats={}
for i=1,20 do 
 bats[i]={x=rand()*240,y=rand()*136,s=i*4+20}
end

clouds={}
for i=1,50 do
 clouds[i]={
  x=rand()*300-30,y=rand()^2*80,
  dx=rand()*2-2}
end
cpts={}
for i=1,10 do
 cpts[i]={x=rand()*40-20,y=rand()*20-10,s=rand()*5+5}
 cpts[i].col=(-cpts[i].y/20+.5)*10+3
end

xs={}
for i=1,20 do
 local y=rand()
 xs[i]={x=rand()*300,y=100+y*40,s=y*15+5,
  dx=y+1,col=y*10+3}
end

function TIC()
 -- GREETZ to lynn, suule, truck
 -- and ofc aldroid + violet <3
 -- plus all the cats out there

 vbank(0)
 cls()
 makebat()
 
 vbank(1)
 cls()
 for i=1,#bats do
 	drawbat(
   bats[i].x+sin(t/30+i)*40,
   bats[i].y+sin(t/37.35+i)*25,
   bats[i].s)
 end
 
 vbank(0)
 cls()
 
 --print("stay on the path",0,50,15,0,2)
 local ex=sin(t/30)^5*40
 local ex2=cos(t/30)^5*20
 elli(60+ex,80,50,20,15)
 elli(60+ex+ex2,80,10,50,0)
 elli(180+ex,80,50,20,15)
 elli(180+ex+ex2,80,10,50,0)
 rect(0,100,240,36,1)
 
 rect(80,50,80,60,1)
 
 rect(80,30,20,20,1)
 tri(
  80,30,100,30,90,10,1)
 rect(140,30,20,20,1)
 tri(
  140,30,160,30,150,10,1)
 
 circ(120,85,5,2)
 rect(115,85,11,20,2)
 rect(90,80,10,13,2)
 rect(140,80,10,13,2)
 
 for i=1,#clouds do
  local c=clouds[i]
  for j=1,#cpts do
   elli(
    c.x+cpts[j].x,
    c.y+cpts[j].y,
    cpts[j].s*1.2,
    cpts[j].s,
    cpts[j].col)
  end
  c.x=c.x+c.dx
  if c.x<-30 then c.x=300 end
 end
 
 for i=1,#xs do
  local x=xs[i]
  rect(x.x-1,x.y-x.s/2,2,x.s*1.5,x.col)
  rect(x.x-x.s/2,x.y-1,x.s,2,x.col)
  x.x=x.x-x.dx
  if x.x<-30 then x.x=270 end
 end
 t=t+1
end

function BDR(y)
 vbank(0)
 for i=0,2 do
	 poke(16320+i,75-y/2)
	 poke(16320+i+3,y/2)
	end
 --poke(0x3FF9,sin(t/20-y/20)*20)
 --poke(0x3FFa,sin(t/20-y/20)*20)
end