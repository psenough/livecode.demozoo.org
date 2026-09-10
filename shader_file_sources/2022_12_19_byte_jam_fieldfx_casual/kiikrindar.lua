-- Happy hollidays and merry wintertime

s=math.sin
r=math.random

offsets={}

for n=0,51 do
 offsets[n]=r(-5,5)
end
t=0

snow={}
for n=0,51 do
 snow[n] = {r(240),r(136)}
end

moon={
 {30,30,8},
 {30,20,4},
 {33,15,7},
 {20,30,6},
 {24,10,9},
 {15,10,5},
}

function TIC()
  cls(15)
  
  -- let's go to the moon
  v=t/48
  h=10*s((20+v)/80+10)+20
  circ(20+v,h+20,30,13)
  for i=1,6 do
    circ(moon[i][1]+v,moon[i][2]+h,moon[i][3],14)
  end
  
  -- snowy snow
  for i=0,50 do
    print('*',snow[i][1],snow[i][2],12)
    if(t%5==0) then
      snow[i][2]=snow[i][2]+1
      if (snow[i][2]>=136) then
        snow[i]={r(240),0}
      end
    end
  end
  
  -- snowman maybe?
  circ(120,64,12,12)
  circ(120,44,10,12)
  circ(120,28,8,12)
  circ(117,24,1,0)
  circ(123,24,1,0)
  pix(117,30,0)
  pix(124,30,0)
  for i=0,5 do
   pix(118+i,31,0)
  end
  line(128,40,135,25,3)
  line(112,43,103,35,3)

  -- building bridges  
  rect(0,75,240,5,7)

  for x=0,240 do
   y=10*s(x/90+3.3)
   
   pix(x,y+48,7)
   pix(x,y+49,7)
   pix(x,y+50,7)
   
   if (x%3==0) then
     pix(x,y+49,2*s(x+t/10)+4)
   end
   
   if (x%19>=2 and x%19<=5) then
     line(x,y+50,x,75,7)
   end
   
   pix(x,2.1*s(x)+77,s(x+t/10)+10)  
  end
  
  -- snowman arm
  line(103,35,113,40,3)
  
  -- reflecting
  for y=85,136 do
   for x=0,240 do
     c=pix(x-offsets[y-85],170-y)
     if (c==15 or c==0) then c=8 end
     pix(x,y,c)
     
     if (t%20==0) then
       if (offsets[y-85]<=-5) then
         offsets[y-85]=offsets[y-85]+r(1)
       elseif (offsets[y-85]>=5) then
         offsets[y-85]=offsets[y-85]-r(1)
       else
         offsets[y-85]=offsets[y-85]+r(-1,1)
       end
     end
   end
  end

  -- redraw snow over reflection
  for i=0,50 do
   print('*',snow[i][1],snow[i][2],12)
  end

  t=t+1
end

function SCN(n)
  poke(0x3fc0+15*3+2,n+120)
  poke(0x3fc0+8*3+2,n+20)
end
