-- mt testing 1...2..37..68
m=math
s=m.sin
function SCN(y)
	 vbank(0)
    if (t/5)%1 < .5 then
 				poke(0x3ff9, 10*fftn[(y+t)//1%255+1])
 				poke(0x3ffa, 3*s(y+t)*fftn[20])
    end
    rs=s(t/100 + y/130)+1
    gs=s(t/100+m.pi*2/3 + y/130)+1
    bs=s(t/100+m.pi*4/3 + y/130)+1
    for i=0,15 do
        if (t/50)%1 < .5 then
        j=15-i
        else
        j=i
        end
        poke(0x3fc0+i*3,128*j/15*rs)
        poke(0x3fc0+i*3+1,128*j/15*gs)
        poke(0x3fc0+i*3+2,128*j/15*bs)
    end
  vbank(1)
				poke(0x3ff9, 10*fftn[(y+t)//1%255+1])
				--poke(0x3ffa, 3*s(y+t))
end

fftm={}
fftn={}
ffts={}

function BOOT()
for i=0,255 do
fftm[i]=0
fftn[i]=0
ffts[i]=0
end
end

function TIC()t=time()/500
for i=0,255 do
if fft(i)>fftm[i] then
fftm[i]=fft(i)
end
fftn[i]=fft(i)/fftm[i]
ffts[i]=ffts[i]+fft(i)
end

vbank(0)
--[[
for y=0,136 do for x=0,240 do
pix(x,y,(x+y)>>3)
end 
end 
--]]
if fftn[5]>.5 then
cls()
else
--vbank(0)
for i=1,2000 do
x=m.random(240)-1
y=m.random(136)-1
c=pix(x,y)
if c == 0 then
else
nx=x-120
ny=y-68
d=(nx^2+ny^2)^.5-1
a=m.atan2(nx,ny)
pix(120+d*m.sin(a),68+d*m.cos(a),c-1)
pix(x,y,0)
end
end

end

X,Y={},{}
cx=120
cy=68
n=250
for i=1,n do
d=i/3+30+6*s(t+i/25)
X[i]=cx+d*s(i+t/9)
Y[i]=cy+d*s(i+11+t/9)
circb(X[i],Y[i],2,8)
end
for i=1,n do
for j=1,n do
if i~=j and ((X[j]-X[i])^2+(Y[j]-Y[i])^2)^.5<20*fftn[50]+3*s(t/3+i/5)then 
line(X[i],Y[i],X[j],Y[j],i%4+11)end
end
end


vbank(1)
for i=1,2000 do
x=m.random(240)-1
y=m.random(136)-1
c=pix(x,y)
if c == 0 then
else
dx=4*m.sin(t)
dc=1.2*m.sin(t/2)
pix(x+dx,y+1,c+1)
pix(x,y,0)
end
end
vbank(1)
if (t/15)%1 < .25 then
 tex="MNB"
elseif (t/15)%1 < .5 then
 tex="TOPLAP"
elseif (t/15)%1 < .75 then
 tex="SOLSTICE"
else
tex=""
end
l=print(tex,0,140,15,true,4)
print(tex,120-l/2,(60-m.sin(ffts[20])*40)%136,12,true,4)
end

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

