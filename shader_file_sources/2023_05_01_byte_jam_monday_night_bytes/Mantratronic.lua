-- mt
-- greets to all
-- some dots today i think

s=math.sin
c=math.cos
r=math.random
tau=2*math.pi
p={}

rt=0
gt=0
bt=0
function BDR(l)
vbank(0)
for i=0,15 do
 poke(0x3fc0+i*3,i*(12+rt))
 poke(0x3fc0+i*3+1,i*(12+gt))
 poke(0x3fc0+i*3+2,i*(12+bt))
end
vbank((t/8)%2)

--alia inspired screen shifting time :)
am=(l/10+t*3)%255
poke(0x3ffa,15*s(am))
am=(l/10+t*4)%255
poke(0x3ff9,10*s(am))
end

p={}
np=2000

cls()

function TIC()t=time()/1000
--[[
for y=0,136 do for x=0,240 do
pix(x,y,(x+y+t)>>3)
end end 
--]]
--cls()
rt= 4*s(t/17*10)
gt= 4*s(t/15*10)
bt= 4*s(t/19*10)

vbank(0)
poke(0x3ff9,0)
poke(0x3ffa,0)
for i=1,2000 do
 x=240*r()
 y=136*r()
 pix(x,y,
  math.max(0,(pix(x,y)
  										 +pix(x+1,y+1)
             +pix(x-1,y+1)
             +pix(x+1,y-1)
             +pix(x-1,y-1))/6))
end

if t%32 < 16 then
 div=3+(t//3)%10
else
 div=3+(t/3)%10
end


for i=1,np do
 a1=(i/div + t/10%div)%1* tau/2
 a2=i/np * tau
 
 dist=20 +3*s(a2*3+t)+3*s(a1*4)+fft(i/10)*i/(np/4)*400
 
 x=dist*s(a1)
 y=dist*c(a1)
 
 z=45+x*s(a2+t)
 x=x*c(a2+t)
 
 col=z/5
 z=z/99
 
 ra=t/3
 x1=x*c(ra)-y*s(ra)
 y1=x*s(ra)+y*c(ra)
 
 x=x1/z+120
 y=y1/z+68
 pix(x,y,math.max(0,math.min(15,4+pix(x,y))))
end

vbank(1)
cls()
poke(0x3ff9,0)
poke(0x3ffa,0)
len=print("OUTLINE",240,136,12,false,5)-8
print("OUTLINE",118-len/2,38,12,false,5)
print("OUTLINE",122-len/2,38,12,false,5)
print("OUTLINE",118-len/2,42,12,false,5)
print("OUTLINE",122-len/2,42,12,false,5)
print("OUTLINE",120-len/2,40,0,false,5)
len=print("18-21 MAY",240,136,12,false,5)-8
print("18-21 MAY",118-len/2,68,12,false,5)
print("18-21 MAY",122-len/2,68,12,false,5)
print("18-21 MAY",118-len/2,72,12,false,5)
print("18-21 MAY",122-len/2,72,12,false,5)
print("18-21 MAY",120-len/2,70,0,false,5)

len=print("in a field, kinda, but not fx",240,136,12)
print("in a field, kinda, but not fx",120-len/2,98,12)

end
