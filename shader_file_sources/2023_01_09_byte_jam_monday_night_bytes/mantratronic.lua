-- mt here
-- not done a tunnel in ages,
-- lets see if i remember how!
-- ok nm the tunnel, this looks ok
p={}
np=136
function BOOT()
for i=1,np do
p[i]={x=240*math.random(),y=136*math.random()}
end
end

function BDR(l)
-- colours
for i=0,47 do
vbank(0)
c=math.min(255,4*i*((i+bt/10)%3))
poke(0x3fc0+i,c)
vbank(1)
poke(0x3fc0+i,255-c)
end
end

b=0
bt=0
function TIC()t=time()/32
-- death to meeces!
vbank(0)
poke(0x3ffb,1)
cls()
vbank(1)
poke(0x3ffb,1)
cls()

-- baaaaass
b=0
for i=0,10 do
b=b+fft(i)/2
end
bt=bt+b/2

-- points
for i=1,np do
 f=fft(i)*20*(.25+i/25)
 p[i].x=(p[i].x+1-f)%240
 p[i].y=68+((i%3)-1)*(8*f)%136
end

vbank(0)
for i=0,239 do
for j=0,135 do
x=i-120
y=j-68
d=(x^2+y^2)^.5
a=math.atan(y,x)--+2*math.sin(b)
d1=d/10-b*math.sin(10*a+t)
c=(1+math.sin(d1-bt))*7
pix(i,j,c)
end
end

-- hmmmm
for i=1,np do
 s=fft(i)*100*(.25+i/34)
 for j=0,math.pi*2,1/s do
  x= s*math.sin(j)
  y= s*math.cos(j)
  vbank(0)
  c = 1+pix(p[i].x+x,p[i].y+y)
  vbank(1)
  pix(p[i].x+x,p[i].y+y,c)
 end
end

end

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

