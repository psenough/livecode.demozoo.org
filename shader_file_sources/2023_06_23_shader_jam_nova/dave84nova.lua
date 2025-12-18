-- title:   Nova Lasers
-- author:  dave84
-- desc:    ByteJam tribute to the lasers at Nova demoparty
-- license: MIT License
-- version: 1.0
-- script:  lua

-- Greets to everyone IRL!
t=0
s=math.sin
c=math.cos
cls()
function TIC()
vbank(1)
cls(0)
vbank(0)
line(0,((t*10)//1)%136,240,((t*10)//1)%136,0)
line(((t*20)//1)%240,0,((t*20)//1)%240,240,0)

x1,y1=0,0
x2,y2=0,0
x2,y3=0,0
for i=0,12 do
 x1=120+s(t)*30
 y1=68+c(t+i)*30
 pix(x1,y1,t//1)
 vbank(1)
 line(240//2,136,x1,y1,t//1)
 vbank(0)
 x2=40+s(t*-1)*30*s(t+i*2)
 y2=68+c(t)*30*s(t+i*2)
 pix(x2,y2,t//1)
 vbank(1)
 line(240//2,0,x2,y2,t//1)
 vbank(0)
 x3=200+s(t*-1)*30*s(t-i)
 y3=68+c(t)*30*s(t+i)
 pix(x3,y3,t//1)
 vbank(1)
 line(240//2,0,x3,y3,t//1)
 vbank(0)
end

t=t+0.1
end
