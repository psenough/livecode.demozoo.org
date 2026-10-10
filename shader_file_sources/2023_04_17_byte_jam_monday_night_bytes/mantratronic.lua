--[[
             mantra here
     gonna try some kaleidoscopes
       and even funkier colours

              greets to
              
mrsynackster     kii               alia

dave84          jtruk             nusan
                 ^
aldroid         tobach        superogue

lynn           reality          and you
--]]

m=math
r=m.random
cs={}
nc=50
ffth={}
p1={x=0,y=0}
p2={x=119,y=0}
p3={x=119,y=67}
p4={x=0,y=67}
bh=0
bass=0
mode=0
reps=0

function circs()
for i=1,nc do
cs[i]={x=r(240),y=r(136),s=2+r(20),c=1+r(14)}
end
end

function BOOT()
circs()
for i=0,255 do
ffth[i]=0
end
end

-- some fun colours
function BDR(l)
if l~=0 then return end
vbank(0)
for i=0,15 do
rt=(m.sin((t+i*20)/50)+1)/2
gt=(m.sin((t+i*20)/60)+1)/2
bt=(m.sin((t+i*20)/70)+1)/2
poke(0x3fc0+i*3, rt*255)
poke(0x3fc0+i*3+1, gt*255)
poke(0x3fc0+i*3+2, bt*255)
end
vbank(1)
for i=0,15 do
rt=(m.sin((t+i*20)/50)+1)/2
gt=(m.sin((t+i*20)/60)+1)/2
bt=(m.sin((t+i*20)/70)+1)/2
poke(0x3fc0+i*3, rt*255)
poke(0x3fc0+i*3+1, gt*255)
poke(0x3fc0+i*3+2, bt*255)
end
end

function happyface(x,y,s,c)
 circ(x,y,s,c)
 circ(x-s/3,y-s/3,s/8,0)
 circ(x+s/3,y-s/3,s/8,0)
 for i=0,16 do
  circ(x+s/2*m.sin(i/8-1),y+s/2*m.cos(i/8-1),s/16,0)
 end
end

function TIC()t=time()//32

for i=0,255 do
 ffth[i]=ffth[i]+fft(i)
end

bh = bh * 0.995
bass=0
for i=0,7 do
bass = bass+fft(i)
end

-- beat detect, kinda
if bh*2 < bass then
 bh = bass
 mode = mode+1
 mode = mode%5+1
 
 if mode == 0 then
  reps = reps+1
 end
end

-- get something on screen time
vbank(0)
cls(1)

if reps%3 == 0 then
 for i=1,nc do
  happyface((cs[i].x+ffth[i]*i/nc*100)%240,cs[i].y,cs[i].s,cs[i].c)
 end
 
 --wtf
 print("FIELDFX",t%40,t%59,0,true,2)
 print(" 2024  ",t%40,t%59+10,0,true,2)
 print("+Every",t%40,t%59+20,0,true,2)
 print("Monday",t%40,t%59+30,0,true,2)
elseif reps%3 == 1 then
 for i=1,nc do
  happyface(cs[i].x,(cs[i].y+ffth[i]*i/nc*100)%136,cs[i].s,cs[i].c)
 end
else
 for i=1,nc do
  happyface(cs[i].x,(cs[i].y+ffth[i]*i/nc*100)%136,cs[i].s,cs[i].c)
 end
end
if mode == 0 then
vbank(1)
cls()
elseif mode == 1 then 
-- ok now the hard bit
vbank(1)
cls(1)
ttri(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(p1.x,p1.y,p4.x,p4.y,p3.x,p3.y,
     p1.x,p1.y,p4.x,p4.y,p3.x,p3.y,
     2,-1)
ttri(p1.x,135-p1.y,p2.x,135-p2.y,p3.x,135-p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(p1.x,135-p1.y,p4.x,135-p4.y,p3.x,135-p3.y,
     p1.x,p1.y,p4.x,p4.y,p3.x,p3.y,
     2,-1)
ttri(239-p1.x,p1.y,239-p2.x,p2.y,239-p3.x,p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(239-p1.x,p1.y,239-p4.x,p4.y,239-p3.x,p3.y,
     p1.x,p1.y,p4.x,p4.y,p3.x,p3.y,
     2,-1)
ttri(239-p1.x,135-p1.y,239-p2.x,135-p2.y,239-p3.x,135-p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(239-p1.x,135-p1.y,239-p4.x,135-p4.y,239-p3.x,135-p3.y,
     p1.x,p1.y,p4.x,p4.y,p3.x,p3.y,
     2,-1)
vbank(0)
cls(0)
elseif mode == 2 then 
vbank(1)
cls(1)
ttri(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(p1.x,p1.y,p4.x,p4.y,p3.x,p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(p1.x,135-p1.y,p2.x,135-p2.y,p3.x,135-p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(p1.x,135-p1.y,p4.x,135-p4.y,p3.x,135-p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1.x,p1.y,240-p2.x,p2.y,240-p3.x,p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1.x,p1.y,240-p4.x,p4.y,240-p3.x,p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1.x,135-p1.y,240-p2.x,135-p2.y,240-p3.x,135-p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1.x,135-p1.y,240-p4.x,135-p4.y,240-p3.x,135-p3.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
vbank(0)
cls(0)
elseif mode == 3 then 
vbank(1)
cls(1)
p1a={x=((p1.x-119)/(bass+.1))+119,y=((p1.y-67)/bass+.1)+67}
p2a={x=((p2.x-119)/(bass+.1))+119,y=((p2.y-67)/bass+.1)+67}
p3a={x=((p3.x-119)/(bass+.1))+119,y=((p3.y-67)/bass+.1)+67}
p4a={x=((p4.x-119)/(bass+.1))+119,y=((p4.y-67)/bass+.1)+67}
ttri(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     p1a.x,p1a.y,p2a.x,p2a.y,p3a.x,p3a.y,
     2,-1)
ttri(p1.x,p1.y,p4.x,p4.y,p3.x,p3.y,
     p1a.x,p1a.y,p2a.x,p2a.y,p3a.x,p3a.y,
     2,-1)
ttri(p1.x,135-p1.y,p2.x,135-p2.y,p3.x,135-p3.y,
     p1a.x,p1a.y,p2a.x,p2a.y,p3a.x,p3a.y,
     2,-1)
ttri(p1.x,135-p1.y,p4.x,135-p4.y,p3.x,135-p3.y,
     p1a.x,p1a.y,p2a.x,p2a.y,p3a.x,p3a.y,
     2,-1)
ttri(240-p1.x,p1.y,240-p2.x,p2.y,240-p3.x,p3.y,
     p1a.x,p1a.y,p2a.x,p2a.y,p3a.x,p3a.y,
     2,-1)
ttri(240-p1.x,p1.y,240-p4.x,p4.y,240-p3.x,p3.y,
     p1a.x,p1a.y,p2a.x,p2a.y,p3a.x,p3a.y,
     2,-1)
ttri(240-p1.x,135-p1.y,240-p2.x,135-p2.y,240-p3.x,135-p3.y,
     p1a.x,p1a.y,p2a.x,p2a.y,p3a.x,p3a.y,
     2,-1)
ttri(240-p1.x,135-p1.y,240-p4.x,135-p4.y,240-p3.x,135-p3.y,
     p1a.x,p1a.y,p2a.x,p2a.y,p3a.x,p3a.y,
     2,-1)
vbank(0)
cls(0)
elseif mode == 4 then 
vbank(1)
cls(1)
p1a={x=((p1.x-119)/(bass+.1))+119,y=((p1.y-67)/bass+.1)+67}
p2a={x=((p2.x-119)/(bass+.1))+119,y=((p2.y-67)/bass+.1)+67}
p3a={x=((p3.x-119)/(bass+.1))+119,y=((p3.y-67)/bass+.1)+67}
p4a={x=((p4.x-119)/(bass+.1))+119,y=((p4.y-67)/bass+.1)+67}
ttri(p1a.x,p1a.y,p2a.x,p2a.y,p3a.x,p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(p1a.x,p1a.y,p4a.x,p4a.y,p3a.x,p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(p1a.x,135-p1a.y,p2a.x,135-p2a.y,p3a.x,135-p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(p1a.x,135-p1a.y,p4a.x,135-p4a.y,p3a.x,135-p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1a.x,p1a.y,240-p2a.x,p2a.y,240-p3a.x,p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1a.x,p1a.y,240-p4a.x,p4a.y,240-p3a.x,p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1a.x,135-p1a.y,240-p2a.x,135-p2a.y,240-p3a.x,135-p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1a.x,135-p1a.y,240-p4a.x,135-p4a.y,240-p3.x,135-p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
vbank(0)
cls(0)
elseif mode == 5 then 
vbank(1)
cls(1)
p1a={x=((p1.x-119)/(bass+.1))+119,y=((p1.y-67)/bass+.1)+67}
p2a={x=((p2.x-119)/(bass+.1))+119,y=((p2.y-67)/bass+.1)+67}
p3a={x=((p3.x-119)/(bass+.1))+119,y=((p3.y-67)/bass+.1)+67}
p4a={x=((p4.x-119)/(bass+.1))+119,y=((p4.y-67)/bass+.1)+67}
ttri(p1a.x,p1a.y,p2a.x,p2a.y,p3a.x,p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(p1a.x,p1a.y,p4.x,p4.y,p3a.x,p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(p1a.x,135-p1a.y,p2a.x,135-p2a.y,p3a.x,135-p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(p1a.x,135-p1a.y,p4.x,135-p4.y,p3a.x,135-p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1a.x,p1a.y,240-p2a.x,p2a.y,240-p3a.x,p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1a.x,p1a.y,240-p4.x,p4.y,240-p3a.x,p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1a.x,135-p1a.y,240-p2a.x,135-p2a.y,240-p3a.x,135-p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
ttri(240-p1a.x,135-p1a.y,240-p4.x,135-p4.y,240-p3.x,135-p3a.y,
     p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
     2,-1)
vbank(0)
cls(0)
end
end
