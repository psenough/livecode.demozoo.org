-- mantratronic here
-- greetz to all coders, orgas
-- and partygoers - except ps. 
-- its ok, he wont read this anyway ;)

m=math
s=m.sin
c=m.cos

function clamp(x,a,b)
 return m.max(a,m.min(x,b))
end

function BDR(y)
vbank(0)
for i=0,8 do
 poke(0x3fc0+i*3, 217*(i/8))
 poke(0x3fc0+i*3+1, 168*(i/8))
 poke(0x3fc0+i*3+2, 143*(i/8))
end
for i=9,15 do
 poke(0x3fc0+i*3, clamp(217+50*((i-8)/8),0,255))
 poke(0x3fc0+i*3+1, 168+90*((i-8)/8))
 poke(0x3fc0+i*3+2, 143+110*((i-8)/8))
end
vbank(1)
for i=0,8 do
 poke(0x3fc0+i*3, 217*(i/8))
 poke(0x3fc0+i*3+1, 168*(i/8))
 poke(0x3fc0+i*3+2, 143*(i/8))
end
for i=9,15 do
 poke(0x3fc0+i*3, clamp(217+50*((i-8)/8),0,255))
 poke(0x3fc0+i*3+1, 168+90*((i-8)/8))
 poke(0x3fc0+i*3+2, 143+110*((i-8)/8))
end
end

first = true

tex={"ALL", "THAT", "JAZZ","<3",""}

function TIC()t=time()/300

if first then
 for y=0,136 do for x=0,240 do
 pix(x,y,(x+y+fft(5)*50)//1>>3)
 end end
 vbank(0)
 cls(8)
-- rectb(100,48,40,40,0)
memcpy(0x8000,0,120*136)
 cls(8)
 first=false
end
--vbank(0)
vbank(0)
cls(8)
 memcpy(0,0x8000,120*136)
--cls(0)
-- rectb(100,48,40,40,4)

d=200
dd=0
a=0--t/300
ad=1/87--fft(20)*100

cx=120
cy=68

x1=cx+d*s(0 + a)
y1=cy+d*c(0 + a)
x2=cx+d*s(m.pi*2/3 + a)
y2=cy+d*c(m.pi*2/3 + a)
x3=cx+d*s(m.pi*4/3 + a)
y3=cy+d*c(m.pi*4/3 + a)

--d = d + dd
a = a + ad
cx=cx + .1*s(t/100)
cy=cy + 2*c(t/100)
u1=cx+d*s(0 + a)
v1=cy+d*c(0 + a)
u2=cx+d*s(m.pi*2/3 + a)
v2=cy+d*c(m.pi*2/3 + a)
u3=cx+d*s(m.pi*4/3 + a)
v3=cy+d*c(m.pi*4/3 + a)

vbank(1)
ttri(x1,y1,x2,y2,x3,y3,
     u1,v1,u2,v2,y3,v3,2)
--rectb(100+t/50,48,40,40,4)
x=m.random(240)
y=m.random(136)
line(x,y-5,x,y+5,m.random(15))

for i=0,1000 do
 x=m.random(240)
 y=m.random(136)
 circb(x,y,2+m.random(2),pix(x,y))
end

text=tex[1+((t/10)%#tex)//1]
len = print(text,0,-100,14,true,3)
if (t/4)%1 < .3 then
print(text,120-len/2,60,t,true,3)
memcpy(0x8000,0,120*136)
else
memcpy(0x8000,0,120*136)
print(text,120-len/2,60,t,true,3)
end

end
