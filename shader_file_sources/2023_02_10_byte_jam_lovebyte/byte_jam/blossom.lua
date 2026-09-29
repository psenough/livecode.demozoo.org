function SCN(l)
poke(16320,l)
poke(16320+3,l)
end

W=240
H=136
m=math
pi2=m.pi*2
F=20

txt={" ","E","N","J","O","Y"," ","L","O","V","E","B","Y","T","E"}

function blossom(x,y,t,s,n,k)

r=m.sin(t/9)+fft(3)*F/8
for p=1,n do
d=s*(2+fft(3)*3)
dx=m.sin(r+(p/n)*pi2)*d
dy=m.cos(r+(p/n)*pi2)*d
circ(x+dx,y+dy,s+1,k)
circ(x+dx,y+dy,s,12)
end

circ(x,y,s*2,k)

end

function bg(u,v,t,h)
cx=u-W/2
cy=v-H/2+h

z=m.sqrt(cy*cy)+.1
fx=cx*(fft(1)+4)/z
fy=H/z-(10+fft(2)*2)

tx=m.atan(fx,fy)*9+t
ty=m.sqrt(fx*fx+fy*fy)*(2+fft(2))

k=(tx//1)~(ty//1)
k=17-k%6
pix(u,v,ty<20 and k or 0)
end

t=0
function TIC()
t=t-fft(1)*.1-.2

h=fft(2)*F-F/4

for u=0,W do for v=0,H do
bg(u,v,t,h)
end end


b=15
for i=1,b do
x=W/2
y=H/2+h

x=x+m.sin(i*pi2/b+t/9)*80
s=m.cos(i*pi2/b+t/9)*2+5
k=3-(i+fft(3)*10)%5
y=y+m.sin(i+t)*s*s*.5

blossom(x,y,t,s,6+i%4,k)

j=1+i%15
print(txt[j],x-s-1,y-s-1,12,1,s/2)
print(txt[j],x-s+1,y-s+1,12,1,s/2)
print(txt[j],x-s,y-s,1,1,s/2)
end

s2=8+fft(4)*2
k2=1
blossom(20,20,t,s2,7,k2)
blossom(W-20,20,t,s2,7,k2)
blossom(20,H-20,t,s2,7,k2)
blossom(W-20,H-20,t,s2,7,k2)

end
