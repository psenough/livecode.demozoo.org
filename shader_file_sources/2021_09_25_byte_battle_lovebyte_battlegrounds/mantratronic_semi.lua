m=math
s=m.sin
r=m.random
p={}for i=0,470 do
p[i*2]=240*r()p[i*2+1]=136*r()end
function TIC()t=time()/99
for i=0,470 do
y=(p[i*2+1]-t)%136
circ((p[i*2])+10*s(y),y,y/10,i%5)x=r(240)line(x,y,x+10,y,pix(x,r(136)))end
print("I MET MY DOOM.",90,50,0)end 
