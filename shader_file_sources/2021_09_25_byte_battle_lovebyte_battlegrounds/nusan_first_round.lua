s=math.sin
function TIC()cls()t=time()/512
for k=0,47 do
poke(16320+k,k//3*15*s(k%3+t-s(t)))end
for i=0,899 do
f,j=i//9/99,i%9
a,b=f*3,j+s(t/4)*3*s(t/3)x,y=120+s(a+t+j)*50*f+s(b)*40,80-(f*80+s(a*3+t+j/4)*50/3)*f+40*s(b+1.6)circ(x,y,10*(1-f),f*17)end
end
