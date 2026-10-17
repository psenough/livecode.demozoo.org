o=16320r=math.random
for i=3,47,3 do
poke(o+i,255)poke(o+1+i,i*4)poke(o+2+i,0)end
function TIC()cls()line(0,40,0,96,9)for x=1,239 do
for y=0,135 do
c=pix(x-1,y)for i=1,c do
n=y+i/(c+1)k=n-72+r(8)n=n+k/(7+k*k/(1+r(3))+.1)pix(x,n,pix(x,n)+1)end 
end end end