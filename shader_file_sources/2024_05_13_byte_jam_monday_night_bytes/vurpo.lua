--greetings to tobach, pumpuli, catnip, jtruk
--to polynomial and reality
--to joost, nemo, bambie thug, windows95man
--and to you!
-- vurpo

poke(0x3fc0,0)
poke(0x3fc1,0)
poke(0x3fc2,0)

m=math

function f(x)
return {
x=80*m.cos(x*(7/8))+40*m.sin(x+m.sin(0.9*x)),
y=50*m.sin(x*(5/7))+10*m.cos(x+m.cos(1.1*x))
}
end

function palette(p)
 for i=1,#p do
 poke(0x3fc2+i,p[i])
 end
end

s="JAM "

p={
{0x5b,0xce,0xfa,0xf5,0xa9,0xb8,0xff,0xff,0xff},
{0xff,0xff,0xff,0x00,0x2f,0x6c},
{0xc8,0x10,0x2e,0xff,0xff,0xff,0x00,0x3d,0xa5},
{0xda,0x29,0x1c,0xff,0xff,0xff},
{0xfc,0xf4,0x34,0xff,0xff,0xff,0x9c,0x59,0xd1,0x2c,0x2c,0x2c},
{0x00,0x9a,0x44,0xff,0xff,0xff,0xff,0x82,0x00}
}
co={
{1,2,3,2,1},
{1,2},
{1,2,3},
{1,2},
{1,2,3,4},
{1,2,3}
}

function TIC()
cls(0)
t=time()/1000

p0=m.floor((t/1)%#p+1)
trace(p0)
palette(p[p0])
c0=co[p0]
trace(c0)

for i=0,m.random()*50 do
pix(m.random()*240,m.random()*136,c0[i%#c0+1])
end

for i=0,60 do
c=f(t*2-i/3+0.3*fft(0,10))
r=3+7*fft(i,i+3)
circ(120+c.x,68+c.y,r,c0[i%#c0+1])
print(string.sub(s,i%#s+1,i%#s+1),118+c.x,66+c.y,0)
end
end