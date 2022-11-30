m=math
s=m.sin
c=m.cos
function SCN(y)
poke(16321,y*2)
poke(16322,y-64)
end
function TIC()t=time()cls()
for k=0,3 do
S=(k+t/600)%4
d=m.min(S,1)
for i=0,3.2,.01 do
for j=0,7 do
circ(120-S*(40-j*2)*c(i*d),60+8*S+S*(-35-j*2)*s(i*d),2,j+2)
end
end
end
end