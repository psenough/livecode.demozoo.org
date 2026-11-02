p={}
sz=25
tau=math.pi*2
depth=3
function SCN(l)
for i=0,15 do
r=i*(8+8*(math.sin(tau/6*5+t/9+l/100)))
poke(0x3fc0+i*3,math.min(r,255)) --??
g=i*(8+8*(math.sin(t/9+l/100)))
poke(0x3fc0+i*3+1,g)
b=i*(8+8*(math.cos(t/9+l/100)))
poke(0x3fc0+i*3+2,b)
end
end

function zsort()
for i=1,#p do
j=i
while j>1 and p[j-1].z>p[j].z do
p[j-1],p[j]=p[j],p[j-1]
j=j-1
end
end
end

function e1()
for i=1,sz^2 do
y=i//(sz/2)-sz/2
a=(i%sz)/sz*tau
d=sz+sz/2*math.cos(y/5+t/4)
x=d*math.sin(a+t/7+math.sin(y/sz))
z=d*math.cos(a+t/7+math.sin(y/sz))
p[i]={x=x,y=y,z=z}
end
zsort()
for i=1,#p do
circ(120+p[i].x*p[i].z/9+20*math.sin(p[i].y/5),58+p[i].y*p[i].z/9,p[i].z/5,p[i].z/4)
end
end
function e2()
for i=1,sz^2 do
y=i//(sz/2)-sz/2
a=(i%sz)/sz*tau
d=sz/2*math.sin(t/depth)+sz*math.sin(y/sz)
x=d*math.sin(a+t/13)
z=d*math.cos(a+t/13)
a2=t/11
p[i]={x=x*math.cos(a2)-y*math.sin(a2),y=y*math.cos(a2)+x*math.sin(a2),z=z}
end
for i=2,#p do
line(120+p[i].x*p[i].z/9+20*math.sin(p[i].y/5),58+p[i].y*p[i].z/9,120+p[i-1].x*p[i-1].z/9+20*math.sin(p[i-1].y/5),58+p[i-1].y*p[i-1].z/9,(math.abs(p[i-1].z)+math.abs(p[i].z))/8+8)
end
end
function e3()
for y=0,135 do for x=0,239 do
X=x-120
Y=y-68
a=math.atan(X,Y)
d=math.sqrt(X^2+Y^2)
pix(x,y,8+8*math.sin(10*math.sin(depth*a+t/2)+d/10+t))
end
end
end

function OVR()
for i=0,47 do
poke(0x3fc0+i,255)
end
dy=5+10*math.sin(t/10)
print("greets to jobe, lynn, pestis, aldroid",25,50+dy,15)
print("and all at demodulation!",50,60+dy,15)
end

function TIC()t=time()/320
cls()
p={}
if t%30 < 10 then
e3()
elseif t%30 < 20 then
e2()
else
e1()
depth=2+math.random(5)//1
end
end