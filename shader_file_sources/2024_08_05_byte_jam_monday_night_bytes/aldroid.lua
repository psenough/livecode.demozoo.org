function TIC()t=time()/320

poke(0x3fc0,204)
poke(0x3fc1,204)
poke(0x3fc2,204)

for i=1,15 do
u=math.sin(i+t)*100+100
v=math.sin(i+t*0.17*i+0.4)*50+50
w=math.sin(i+t*0.4+1.4)*50+50
poke(0x3fc0+3*i,u)
poke(0x3fc1+3*i,v)
poke(0x3fc2+3*i,w)
end

if math.random() < 0.5 then
circ(math.random()*240,math.random()*136,13,16*math.random())
end
for y=0,136 do for x=0,240 do
xc=x-120+math.sin(t*0.09)
yc=y-68
a=math.atan2(xc,yc)+0.05+math.sin(t/20)
r=(xc*xc+yc*yc)^0.5+math.sin(t)/2+0.5
nx=r*math.cos(a)+120
ny=r*math.sin(a)+68
pix(x,y,pix(nx,ny))
end end end
