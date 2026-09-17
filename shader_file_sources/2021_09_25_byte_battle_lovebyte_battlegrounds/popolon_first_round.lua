s=math.sin
W=240 H=136
function TIC()t=time()//32
cls(6)for y=0,136,5 do
for j=1,5 do t5=t/50
circ((j*15+y*5+t+15*s(y+t/10))%W,(y*5+t+5*s(j*10+t5))%H,5+3*s(y+t5),6+j)Y=(y+t)%H
circb((50*j+(5+j)*s(y+t/20))%W,-Y%H,Y/20,6+Y/30)end end end
