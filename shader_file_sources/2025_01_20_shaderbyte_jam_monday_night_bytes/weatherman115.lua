for i=0,47 do
poke(16320+i,i*5)end
Z=table.insert
cls()t=0S=math.sin
function TIC()for i=0,4e4 do
x=i%240y=i/240z=pix(x,y)pix(x,y,z<1 and 0or z-1)end
s=(t%16<1)and math.random()or s
for z=4,1,-1 do
for x=-z-1,z do
x=120*(x+(t/60%1))/z+120y=68
for T=0,8,4 do
P={}for n=0,5 do
r=(n+T)//2*1.571/s-t/30+z+x/99Z(P,30/z*(S(r-11)+S(r)*(-1)^n)/(1+T/2)+(n&1<1 and x or y))
end
Z(P,T+1+z)tri(table.unpack(P))end
end
end
for i=0,99 do
r=((193+i)^4.3)+t/60
circ(120*S(r*s-11)+120,120*S(r+s)+68,i%(2+s/i),i)
end
t=t+1
end