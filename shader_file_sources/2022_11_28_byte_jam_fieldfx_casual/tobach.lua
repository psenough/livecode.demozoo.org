--TEST!!!!!!
--one minute :))
--greets to mantra, visy and truck <3
--hmmm i have an idea
sin=math.sin
cos=math.cos
rnd=math.random

--todays ur lucky day...
--its a two in one!!
--a bogof even
function TIC()
 phr()
 --mcr()
end

--pharmacy sign!!
function phr()
 cls()
 t=time()
 for i=0,31 do
  for j=0,31 do
   circ(60+i*4,6+j*4,1,sin(t/128+i*sin(j/8+t/256)/16*4)*2+7)
  end
 end
 
 rect(58,4,44,44,0)
 rect(147,4,44,44,0)
   
 rect(58,88,44,44,0)
 rect(147,88,44,44,0)
 
 print("FIELD-FX MONDAY NIGHT BYTES",240-t/6%1000,56,12,true,5)
 
 rect(186,0,58,135,0)
 rect(0,0,63,135,0)
 
 for i=0,31 do
  for j=0,31 do
  rect(61+i*4,3+j*4,3,3,0)
  end
 end
 
 for i=0,35 do
  line(0,0+i*4,240,0+i*4,0)
 end
 
 for i=0,96 do
  line(2+i*4,0,2+i*4,136,0)
 end
 
end

--manchester baby 1948 computer
function mcr()
  t=time()
 cls()
 rect(30,0,30,136,14)
 rect(180,0,30,136,14)
 
 --main front panel
 rect(20,5,200,60,13)
 rect(20,70,200,20,13)
 rect(20,95,200,20,13)
 rect(20,120,200,20,13)
 
 --gubbins
 for j=0,4 do
  for i=0,9 do
   circ(50+i*15,15+j*10,3,rnd(2))
   circb(50+i*15,15+j*10,3,1)
  end
 end
 
 for k=0,1 do
  for i=0,13 do
   circ(35+i*13,75+k*8,3,15)
   circb(35+i*13,75+k*8,3,0)
   for j=0,2 do
    line(35+i*13+j,75+k*8,38+i*13+j,79+sin(t/32+i*16*k)*4-3+k*8,14)
   end
  end
 end
 
 for i=0,4 do
  circ(35+i*8,105,3,2)
  circb(35+i*8,105,3,1)
 end
 
 rect(80,100,120,15,15)
 
 for i=0,9 do
  rect(82+i*12,101,2,12,14)
  rect(82+i*12,102+sin(t/64+i)*4+4,4,4,12)
 end
 
 for i=0,1 do
  print("MANCHESTER BABY",35+1,123+1,14,false,2)
  print("MANCHESTER BABY",35,123,12,false,2)
 end
end