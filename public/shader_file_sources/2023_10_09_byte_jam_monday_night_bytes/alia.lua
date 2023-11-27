sin=math.sin
cos=math.cos
min=math.min
max=math.max
pi=math.pi
abs=math.abs
rand=math.random

t=0

for i=0,47 do
 poke(16320+i,i%3*i*5)
end

cls()

f={}
for i=1,30 do
 f[i]={x=rand()*260-10,y=rand()*136,
  l=rand()>0.5,s=rand()*3+5}
end

xbase=120

function fishy()
 for i=1,#f do
  local f=f[i]
  l=f.x+(f.l and f.s or -f.s)*1.5
  r=f.x+(f.l and -f.s or f.s)
  tri(
   f.x,f.y+3,
   f.x,f.y-3,
   r,f.y,
   8+(t/10+i)%4)
  tri(
   f.x,f.y+3,
   f.x,f.y-3,
   (f.x/2+l/2),f.y,
   8+(t/10+i+1)%4)
  tri(
   l,f.y+3,
   l,f.y-3,
   f.x/2+l/2,f.y,
   8+(t/10+i+1)%4)
  
  f.x=((f.x+(f.l and -1 or 1)+10)%260)-10
  f.y=f.y+sin(i+t/15)/2
 end
end

function TIC()
 vbank(0)
 local s=sin(t/41)^7*65+65
 local x=sin(t/40)*s
 local y=cos(t/40)*s
 circ(120+x,68+y,8,(-t*.4)%14+1)
 x=sin(t/40+pi)*s
 y=cos(t/40)*s
 circ(120+x,68+y,8,(-t*.4)%14+1)
 
 if t%3==0 then 
  memcpy(0x4000,16320+3,45)
  memcpy(16320+3,0x4003,42)
  memcpy(16320+42,0x4000,3)
 end
 
 vbank(1)
 cls()
 x=120+sin(t/16)^3*30
 y=68+cos(t/8)*20
 local x2=120+sin(t/16-.3)^3*30
 local y2=68+cos(t/8-.3)*20
 local x3=120+sin(t/16-.2)^3*30
 local y3=68+cos(t/8-.2)*20
 
 rect(x-20,y,40,80,3)
 rect(x-20,y+45,40,5,2)
 --ears. Gotta have cat ears
 elli(x-25,y-33,15,22,3)
 elli(x-25,y-33,12,19,2)
 elli(x+25,y-33,15,22,3)
 elli(x+25,y-33,12,19,2)
 
 circ(x,y+110,60,3)
 elli(x,y+2,50,40,2)
 elli(x,y,50,40,3)
 circ(x-20,y-12,15,12)
 circ(x+20,y-12,15,12)
 circ(x2-20,y2-12,5,15)
 circ(x3+20,y3-12,5,15)
 
 elli(x,y+17,25,12,12)
 rect(x-25,y+5,52,12,3)
 elli(x-12,y+27,1,7,12)
 --elli(x+12,y+25,2,7,12)
 
 circ(x3,y3+52,5,4)
 line(x3,y3+52,x3,y3+57,14)
 
 --print("seafood steve",0,105,15,0,3)
 --print("they're all about the fish",80,122,15,0,1)
 for i=0,11 do
  local c=i==11 and 12 or 15-i
 	print("seafood steve",sin(t/8+i/2)*4,115-i+cos(t/8+i/2)*4,c,0,3)
 	print("they're all about the fish",80+cos(t/8+i/2)*2,133-i+sin(t/8+i/2)*2,c,0,1)
 end
 fishy()
	t=t+1
end
