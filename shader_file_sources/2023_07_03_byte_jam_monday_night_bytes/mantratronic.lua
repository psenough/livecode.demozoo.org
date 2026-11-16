-- mantra here
-- going to try a feedback effect

-- thanks to raccoonviolet for 
-- doing this on short notice!

--                   ^
-- gl & hf to nico, tobach and alia

bass=0
mids=0
treb=0
first=true
m=math
s=m.sin
c=m.cos
tau=m.pi*2

text={"FIELDFX","MONDAY", "GOOD", "TO BE", "BACK", "", "Nico", "Tobach", "Alia", "Violet", "and you"}

function BOOT()
cls()
end

function BDR(l)
if l ==0 then 
vbank(1)
rt=s(t/30)
gt=s(t/31)
bt=s(t/32)
for i=0,15 do
poke(0x3fc0+i*3,math.min(255,i*(10+5*rt)))
poke(0x3fc0+i*3+1,math.min(255,i*(10+5*gt)))
poke(0x3fc0+i*3+2,math.min(255,i*(10+5*bt)))
end
end
end

function TIC()t=time()/100
--bass=0
bass = bass*.9
for i=0,8 do
 bass = bass + fft(i)
end

--mids=0
mids = mids*.9
for i=10,30 do
 mids = mids + fft(i)
end

treb=0
for i=100,255 do
 treb = treb + fft(i)
end
 
if first then
 vbank(0)
 memcpy(0x8000,0,120*136)
 first=false
end
vbank(0)
memcpy(0,0x8000,120*136)


cx=120+s(mids)*10
cy=68+c(mids)*8

circb(120,68,treb*20,treb*12)

tex=text[(t//20 % #text)+1] 
len=print(tex,2400,120,treb*16,true,4)
if t/20 %1 > .5 then
print(tex,120-len/2,60,4+math.min(7,treb*2)+t/10,true,4)
end
 
vbank(1)
cls()
d=200

x1= cx+d*s(tau/8)
x2= cx+d*s(tau/8*3)
x3= cx+d*s(tau/8*5)
x4= cx+d*s(tau/8*7)

y1= cy+d*c(tau/8)
y2= cy+d*c(tau/8*3)
y3= cy+d*c(tau/8*5)
y4= cy+d*c(tau/8*7)

twist=s(mids*5)/16

d = d- s(bass)*10
u1= cx+d*s(tau/8+twist)
u2= cx+d*s(tau/8*3+twist)
u3= cx+d*s(tau/8*5+twist)
u4= cx+d*s(tau/8*7+twist)

v1= cy+d*c(tau/8+twist)
v2= cy+d*c(tau/8*3+twist)
v3= cy+d*c(tau/8*5+twist)
v4= cy+d*c(tau/8*7+twist)
 
--[[
line(x1,y1,x2,y2,3)
line(x2,y2,x3,y3,3)
line(x3,y3,x4,y4,3)
line(x4,y4,x1,y1,3)
 
line(u1,v1,u2,v2,5)
line(u2,v2,u3,v3,5)
line(u3,v3,u4,v4,5)
line(u4,v4,u1,v1,5)

ttri(x1,y1,x2,y2,x3,y3,
     x1,y1,x2,y2,x3,y3,2)
--]]

ttri(x1,y1,x2,y2,x3,y3,
     u1,v1,u2,v2,u3,v3,2)
ttri(x1,y1,x4,y4,x3,y3,
     u1,v1,u4,v4,u3,v3,2)

 memcpy(0x8000,0,120*136)
print(tex,120-len/2,60,8,true,4)
vbank(0)
cls() 
 
end
