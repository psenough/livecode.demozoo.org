--{
--}
--for x=0,15 do
--{
--	poke(16320+3*x  , 255*(x/15))
--	poke(16320+3*x+1, 255*(x/15)^3)
--	poke(16320+3*x+2,0)
--}
--end

xs={}
ys={}
n=40
st="DEADLINEDEADLINEDEADLINEDEADLINEDEADLINE"


cls(0)

function distance(x1,y1,x2,y2)
 return math.sqrt(
         (x2-x1)*(x2-x1)+
         (y2-y1)*(y2-y1)
         )
end
for i=1,n do
 xs[i]=(i-1)%8*20--math.random(240)
 ys[i]=(i-1)//8*20-math.random(40)
end

function lightning(x0,y0,x1,y1)
	xa=x0
	ya=y0
	a=math.atan2(x1-x0,y1-y0)
	s=math.sin(a)
	c=math.cos(a)
	p=0
	 co=math.random(3)
	repeat
	 p=p+distance(x0,y0,x1,y1)/10
	 r=(math.random(2)-1)*3*math.sin(3*p/distance(x0,y0,x1,y1))
	 x=x0+p*s+c*r
	 y=y0+p*c-s*r
	line(xa,ya,
	     x,y,9+co)
		xa=x
		ya=y
	until p>=distance(x0,y0,x1,y1)-1

end


function TIC()
vbank(1)
cls(0)
for i=1,n do
 for j=1,n do
  if (i-1)//8 == (j-1)//8 then
  if j-i==1 then hh=10 else hh=0 end
  d=distance(xs[i],ys[i],xs[j],ys[j])
  if d < 40+math.random(15) +hh
  then
   lightning(xs[j],ys[j],xs[i],ys[i])
  end
  end
 end

-- circ(xs[i],ys[i],2,2)
 print(st:sub(i,i),xs[i]-8,ys[i]-8,2+(i-1)//8,false,3)

 xs[i]=(xs[i]+(i/n))%240
 ys[i]=(ys[i]+(i/n))%136

end
vbank(0)
rect(math.random(0,240),
					math.random(0,136),
					math.random(0,60),
					math.random(0,60),
					math.random(3)+13)
end
