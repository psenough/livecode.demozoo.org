p=pix
s=math.sin
cls()
print("Demo.",32,0,12)
function TIC()t=time()//32
for y=5,136,2 do for x=0,240 do
p(x/s(t*y),y,(x+y+t)/9)
end end
for y=0,4 do for x=0,50 do
c=p(x+t%128,y)*(y+x)*.1
circ(x*9+s(t*.4+y)*4,y*12+48+32*s(x*.04+t*.1),9-x/4,c)
end end
end