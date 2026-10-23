cls()
m=math
r=m.random
s=m.sin
function TIC()
t=time()/4999
for i=0,47 do
--let's just go with the boring grayscale
poke(16320+i,i*5)
end
for a=r(32639),r(32639) do
poke4(a,peek4(a)*.9)
end
p1=r(7)
d=150+50*s(t*3)
x1=d
y1=0
for i=1,9^4 do
p2=(p1+r(6)%5)+1
a=2*p2/7*m.pi+t
x2=d*m.cos(a)
y2=d*s(a)
u=2.2+.4*s(t*3.3)
x=120+(x1+x2)/u
y=68+(y1+y2)/u
pix(x,y,math.min(15,pix(x,y)+1))
p1=p2
x1=x-120
y1=y-68
end
end