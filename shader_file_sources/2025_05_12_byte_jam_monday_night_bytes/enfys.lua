--original idea won't work oops
vbank(0)
for i=0,15 do
 a=0x3fc0+i*3
 v=i*255/15
 poke(a,v)
 poke(a+1,0)
 poke(a+2,0)
end


vbank(1)
for i=0,15 do
 a=0x3fc0+i*3
 v=i*255/15
 poke(a,v/2)
 poke(a+1,v/2)
 poke(a+2,v/2)
end

sin=math.sin
t=0

function SCN(scnln)
 vbank(0)
 poke(0x3ff9,math.random()*2)
 vbank(1)
 poke(0x3ff9,math.random()*8)
 poke(0x3ffa,sin(scnln/4+t)*4)
end

vbank(0)
cls()
function TIC()
 vbank(0)
 t=time()/100
 for i=0,2000 do
  pix(math.random()*240,math.random()*135,math.random()*2)
 end
 for i=0,1 do
  line(0,t*6%165-i*16,240,t*6%165-i*16,i*4+math.random()*4)
 end

 vbank(1)
 cls()
 --rect(0,0,240,136,1)
 for y=0,135 do
  for x=0,240 do
   pix(x,y,math.random()*2+1)
  end
 end

 for x=-8,8 do
  for i=0,4 do
   v=x*100+t*16%100
   circb(120+v,68,30-i,0)
   g=t/4%4//1
   if g==0 then
   for i=0,20 do
    circ(120-i-20+v,68-i-20,2,0)
    circ(120+i+20+v,68-i-20,2,0)
    circ(120+v,68-i+50,2,0)
    circ(130-i+v,68+40,2,0)
    circ(120-i-20+v,68-40,2,0)
    circ(120-40+v,68-i-20,2,0)
    circ(120+i/1.5-33+v,68-i/1.5-20,2,0)
    circ(120-i+40+v,68-40,2,0)
    circ(120+40+v,68-i-20,2,0)
   end
   elseif g==2 then
   
    for i=0,20 do
    --circ(120-i-20,68-i-20,2,0)
    circ(120+i+20+v,68-i-20,2,0)
    circ(120+v,68-i+50,2,0)
    circ(130-i+v,68+40,2,0)
    --circ(120-i-20,68-40,2,0)
    --circ(120-40,68-i-20,2,0)
    --circ(120+i/1.5-33,68-i/1.5-20,2,0)
    circ(120-i+40+v,68-40,2,0)
    circ(120+40+v,68-i-20,2,0)    
    end
   
   elseif g==4 then
    for i=0,20 do
    --circ(120-i-20,68-i-20,2,0)
    circ(120+i+20+v,68-i-20,2,0)
    --circ(120,68-i+50,2,0)
    --circ(130-i,68+40,2,0)
    --circ(120-i-20,68-40,2,0)
    --circ(120-40,68-i-20,2,0)
    --circ(120+i/1.5-33,68-i/1.5-20,2,0)
    circ(120-i+40+v,68-40,2,0)
    --circ(120+40,68-i-20,2,0)
    end
    
   elseif g==1 then
    for i=0,20 do
    --circ(120-i-20,68-i-20,2,0)
    --circ(120+i+20,68-i-20,2,0)
    circ(120+v,68-i+50,2,0)
    circ(120-i/2+v,68+40,2,0)
    --circ(120-i-20,68-40,2,0)
    --circ(120-40,68-i-20,2,0)
    --circ(120+i/1.5-33,68-i/1.5-20,2,0)
    --circ(120-i+40,68-40,2,0)
    --circ(120+40,68-i-20,2,0)
    end
   elseif g==3 then
    for i=0,20 do
    circ(120+i+20+v,68-i-20,2,0)
    --circ(120+i+20,68-i-20,2,0)
    --circ(120,68-i+50,2,0)
    --circ(120-i/2,68+40,2,0)
    circ(120-i+40+v,68-40,2,0)
    circ(120+40+v,68-i-20,2,0)
    circ(120-i/1.5+32+v,68-i/1.5-20,2,0)
    --circ(120-i+40,68-40,2,0)
    --circ(120+40,68-i-20,2,0)
    end
   end

  end
  
 end
end