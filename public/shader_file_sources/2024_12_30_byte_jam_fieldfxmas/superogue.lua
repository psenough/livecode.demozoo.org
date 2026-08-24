-- superogue at FieldFXmas 2024 Bytejam
R=load'X,Y,A=...return X*C(A)-Y*S(A),X*S(A)+Y*C(A)'
S=math.sin
C=math.cos
for i=0,47 do poke(16320+i,S(i/15)*255)end
function BDR(l)
poke(16323,l/4)
poke(16324,l/3)
poke(16325,l/2)
end

function TIC()
f=fft(2)*16
t=time()/60
pp=t//16
n=7
cls()
for i=0,136,2 do
line(0,i,240,i,1)
end

ff=ffts(0)*4
oz=ff+S(t/16)*4+14
for Z=-n,n do

for Y=-n,n do
for X=-n,n do
W=(X*X+Y*Y+Z*Z)
f=ffts(W)*8
x,y=R(X,Y,ff+t/12)
x,z=R(x,Z,f+t/9)
z=z+oz
x=x*64/z+80
y=y*64/z+68
c=((X&Y&Z)%8)
zz=4-z/6
ss={X+Y+Z,S(X)*8+16,X*Y*Z,64}
r=pix(x,y)<c and W>ss[1+(pp&3)]+f and zz or -1
rectb(x,y,r,r,c)
rectb(240-x,y,r,r,c)
end end end
print("Happy New Year from Superogue",63,129,0,1,1,1)
print("Happy New Year from Superogue",62,128,8,1,1,1)
end