st="DEADLINE20242024"

hene="HeNeArXn"

cls(0)

function distance(x1,y1,x2,y2)
 return math.sqrt(
         (x2-x1)*(x2-x1)+
         (y2-y1)*(y2-y1)
         )
end

w=6
h=6
t=0
s=math.sin
for j=0,47 do
poke(16320+j,s(j/15+s(j%3*3))^2*255)
end
function TIC()
cls(0)
t=t+12
px=math.sin(t/1000)*200
  +math.cos(t/200)*50
px=px/w
py=100+math.sin(t/600+200)*40
      +math.sin(t/400+200)*20
py=py/h


for x=w//2,250,w do
 for y=h//2,150,h do
 i=(x//w+y//h)%8+1
 d=distance(x//w,y//h,px,py)
 i=d//1%8+1+((time()//5000)%2*8)
 c=(d%15+1)
 if (time()//2500)%2 <1 then
 	 if (i-1)%8>3 then c=0  end
 end
 if y//h==20 and x//w>30 and x//w<39 then
	i=x//w-30
 print(hene:sub(i,i),
 					 x-w//2,
       y-h//2,
       c,
       false,
       1)
 else

 print(st:sub(i,i),
 					 x-w//2,
       y-h//2,
       c,
       false,
       1)
end
end
end
end
