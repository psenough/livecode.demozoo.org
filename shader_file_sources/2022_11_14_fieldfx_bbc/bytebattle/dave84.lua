pal={6,7,12,13}
function TIC()
t=time()/999
for x=0,240 do
 for y=0,136 do  
  x1=s(t/300)*x-c(t)*y
  y1=c(t)*x-s(t)*y
  cl=s((x1+t)/10)*s(t/20)+s((y1+t)/10)*c(t/20) 
  pix(x,y,pal[(cl//1+2)%4+1]+(x1//1~y1//1)%2)
 end
end
end
m=math
s=m.sin
c=m.cos
