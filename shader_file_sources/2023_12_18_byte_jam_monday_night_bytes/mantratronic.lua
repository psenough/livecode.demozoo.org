-- hello!

m=math
cls()
t=0

function C(x,a,b)
return m.max(a,m.min(x,b))
end

function BOOT()
for i=0,15 do
poke(0x3fc0 +i*3,i*16)
poke(0x3fc0 +i*3 +1,i*8)
poke(0x3fc0 +i*3 +2,i*4)
end
end

function TIC()
for x=0,239 do
line(x,135,x,134,fft((x+t*5)%255)*10000)
end

for x=0,239 do
for y=1,134 do
dx=1.1*(135-y)/135*m.sin(time()/100+y/20)
c=pix(x,y-1)+
pix(x-1,y)+pix(x+1,y)+
pix(x-1,y+1)+pix(x,y+1)+pix(x+1,y+1)
c=C(c/5.75,0,15)
pix(x+dx,y-1,c)
end
end
t=t+fft(5)
end
