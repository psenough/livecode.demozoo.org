vbank(0)
for i=0,3 do
 a=0x3FC0+i*3
 v=i*255/15
 poke(a,v)
 poke(a+1,(v/255)^0.1*64)
 poke(a+2,v)
end
for i=4,7 do
 a=0x3FC0+i*3
 v=i*255/15
 poke(a,(v/255)^0.8*255)
 poke(a+1,(v/255)^0.3*64)
 poke(a+2,(v/255)^0.3*64)
end
for i=8,11 do
 a=0x3FC0+i*3
 v=i*255/15
 poke(a,(v/255)^0.3*255)
 poke(a+1,v)
 poke(a+2,(v/255)^0.1*128)
end
for i=12,15 do
 a=0x3FC0+i*3
 v=i*255/15
 poke(a,(v/255)^1.1*64)
 poke(a+1,(v/255)^2.1*48)
 poke(a+2,v*4)
end

vbank(1)
for i=0,3 do
 a=0x3FC0+i*3
 v=i*255/15
 poke(a,v)
 poke(a+1,(v/255)^0.1*64)
 poke(a+2,v)
end
for i=4,7 do
 a=0x3FC0+i*3
 v=i*255/15
 poke(a,(v/255)^0.8*255)
 poke(a+1,(v/255)^0.3*64)
 poke(a+2,(v/255)^0.3*64)
end
for i=8,11 do
 a=0x3FC0+i*3
 v=i*255/15
 poke(a,(v/255)^0.3*255)
 poke(a+1,v)
 poke(a+2,(v/255)^0.1*128)
end
for i=12,15 do
 a=0x3FC0+i*3
 v=i*255/15
 poke(a,(v/255)^1.1*64)
 poke(a+1,(v/255)^2.1*48)
 poke(a+2,v*4)
end

sin=math.sin
function TIC()
 cls(1)
 t=time()/100
 vbank(0)
 
 rect(0,0,240,136,1)
 for i=0,8 do
  sv=sin(t/8+i/3)*48
  tweedbar2(sv)
 end

 for i=0,8 do
  sv=sin(t/8+i/4)*96
  tweedbar(sv)
 end
 
  --tweedbar2(0)
 
 for j=0,136,2 do
  for i=0,240,2 do
   pix(i,j,7)
   pix(i+1,j+1,7)
   --pix(i+1,j+2,7)
   --pix(i+1,j+3,7)
  end
 end

 vbank(1)
 --cls(0)
 rect(0,0,240,136,1)
 for i=0,10 do
  sv2=sin(i/16+t/4)*32
  tweedbar3(110-i*24+sv2)
 end
 for j=0,136,2 do
  for i=0,240,2 do
   pix(i,j,3)
   pix(i+1,j+1,3)
  end
 end

 for i=0,16 do
  rect(100+sin(i/3+t/7+sin(t/13))*128,48+sin(i/7+t/3+4)*48,40,40,0)
 end
 print(" I feel\nthe need,",40,16-math.abs(sin(t/4)*8),10,true,3)
 print(" The need\nfor tweed!",30,96-math.abs(sin(t/4+1)*8),10,true,3)
 
 for i=0,15 do
  --pix(i,0,i)
 end
end

function tweedbar(x)
 rect(110+x,0,20,136,5)
 rect(110+x,0,8,136,4)
 rect(130+x,0,8,136,4)
 
 line(114+x,0,114+x,136,8)
 line(134+x,0,134+x,136,8)

 rect(120+x,0,8,136,3)
end

function tweedbar2(y)
 rect(0,58+y,240,24,15)
 rect(0,58+y,240,8,13)
 rect(0,68+y,240,8,14)
 rect(0,78+y,240,8,13)
end

function tweedbar3(y)
 rect(0,58+y,240,24,7)
 rect(0,58+y,240,8,2)
 rect(0,68+y,240,8,14)
 rect(0,78+y,240,8,2)
end