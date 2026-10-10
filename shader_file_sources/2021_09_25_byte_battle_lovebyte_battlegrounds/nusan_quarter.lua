function SCN(k)o=k%47
poke(16320+o,o//3*5-o%3*19+o*18+t)end
function TIC()cls()t,s=time()/512,math.sin
for i=0,239 do
h=i/240
d=100*h+3
for j=-d,d do
g=120+j+d*s(t+h*13)k=h*20//1+t%1
m=h*240//k*k+j/5*s(t)rect(g,m,1,10,k+i/8)end
circ(g,m-9,d/9,i/8%5)end
end