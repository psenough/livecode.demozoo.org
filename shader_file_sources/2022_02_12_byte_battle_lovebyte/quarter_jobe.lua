o=16320memset(o,0,48)for i=3,47,3 do
poke(o+i,255)poke(o+i+1,i*5)end
r=math.random
function v(b)return(b+r(50))*h
end
function TIC()for x=0,999 do
x=r(240)-1y=r(136)-1
c=pix(x,y)a=c>0 and circ(x,y,1,c+1)or 1h=math.sin(x/76)line(x,v(39),x,v(55),r(4))end
end