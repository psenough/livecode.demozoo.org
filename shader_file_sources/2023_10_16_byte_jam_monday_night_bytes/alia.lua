rand=math.random
sin=math.sin
cos=math.cos
abs=math.abs
min=math.min
max=math.max

t=0
-- Hi to aldroid! And Suule, jtruk 
-- and nusan!

for i=0,15 do
 poke(16320+i*3+0,i*4)
 poke(16320+i*3+1,i*16)
 poke(16320+i*3+2,i*4)
end
vbank(1)
for i=0,7 do
 poke(16320+i*3+0,i*32)
 poke(16320+i*3+1,i*32)
 poke(16320+i*3+2,i*32)
end
for i=8,15 do
 poke(16320+i*3+0,i*16)
 poke(16320+i*3+1,i*8+128/4)
 poke(16320+i*3+2,i*4)
end

vbank(0)
for y=0,145 do
 for x=0,239 do
  local c=rand()*16
  line(x,y,x+rand()*c/2-c/4,y-rand()*c/2,(c/16)^2*16)
 end
end

r={}
for i=1,10 do
 r[i]={
  x=rand()*240,y=rand()*136,
  dx=rand()*2-1,dy=rand()-1
 }
end
c={
 x=rand()*240,y=rand()*136,
 dx=rand()*2-1,dy=rand()-1
}

function TIC()
 t=t+1
 vbank(0)
 poke(0x3FFa,t%136-68)
 
 vbank(1)
 cls()
 for i=1,#r do
  local r=r[i]
  local y=r.y-abs(sin(t/5+i)*4)
  local y2=r.y-abs(sin(t/5+i+.8)*4)
  
  elli(r.x+1,r.y+2,6,8,1)
  elli(r.x-r.dx/2-4,y2+4,1,2,5)
  elli(r.x-r.dx/2+4,y2+4,1,2,5)
  elli(r.x,y,5,8,4)
  circ(r.x-r.dx,y+4,2,7)
  
  elli(r.x+r.dx+2,y2-12,1,4,6)
  elli(r.x+r.dx-2,y2-12,1,4,6)
  circ(r.x+r.dx,y2-8,3,5)
  
  
  r.x=r.x+r.dx
  r.y=r.y+r.dy
  if r.x<-10 then r.x=250 end
  if r.y<-10 then r.y=146 end
  if r.x>250 then r.x=-10 end
  if r.y>146 then r.y=-10 end
  if rand()<0.01 then
  	r.dx=rand()*2-1 r.dy=rand()-1
  end
 end
 
 
 elli(c.x+1,c.y+5,5,10,1)
 elli(c.x+1-c.dx*5,c.y+14,5,10,1)
 
 local y=c.y+abs(sin(t/6)*4)
 elli(c.x-3,y+3,1,3,10)
 elli(c.x+3,y+3,1,3,10)
 local y2
 circ(c.x+c.dx,y-6,4,14)
 elli(c.x+c.dx-3,y-8,1,2,12)
 elli(c.x+c.dx+3,y-8,1,2,12)
 for i=0,4 do
  y2=c.y-(c.dy-1)*i*2+abs(sin(t/6+i/3)*2)
 	circ(c.x-c.dx*i,
   y2,
   4,12+(i%2)*3)
 end
 local x2=c.x-c.dx*4
 elli(x2-3,y2+3,1,3,10)
 elli(x2+3,y2+3,1,3,10)
 
 for i=0,10 do
  circ(x2+cos(t/10+i/4)*.4*i,y2-4-i,1,(i%2)*4+10)
 end
 
 c.x=c.x+c.dx
 c.y=c.y+c.dy
 if c.x<-10 then c.x=250 end
 if c.y<-10 then c.y=146 end
 if c.x>250 then c.x=-10 end
 if c.y>146 then c.y=-10 end
 if rand()<0.01 then
  c.dx=rand()*2-1 c.dy=rand()-1
 end
 
 print("til bnuydon come",20,122,1,0,2)
 print("til bnuydon come",20,120,7,0,2)
end
