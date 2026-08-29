m=math
function BDR(y)
a=y-32
b=240
l=(a^2+b^2)^.5
d=0
for i=0,200 do
v=10*t+d*b/l
u=400*f*f*m.sin(v/1e3)+d*a/l
d=d+1e3-u
end
h=5e5//d
for i=0,15 do
poke(16320+i*3,m.min(255,64+y+h*f))
end
if(a>0)then
c=(v//1e3)%2
o=120+30*m.sin(v/6e4)
line(0,y,240,y,2)
line(o-h,y,o+h,y,(1-c)*12)
line(o-h/3,y,o+h/3,y,c*12)
end
end
TIC=load"cls(1+fft(1)*2)t=time(5)f=fft(1)print('INFINITE PICNIC BLANKET',55,10,12,12,1)"