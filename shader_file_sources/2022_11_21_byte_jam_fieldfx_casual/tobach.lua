-- ^
--tobach heeerreeeee
--lets get a little diarama(?) going ;)
sin=math.sin
cos=math.cos
abs=math.abs
function TIC()
 cls()
 t=time()/4
 
 for y=0,135,2 do
  for x=0,239,2 do
   sval=sin(x/8+t/16+sin(x/64+t/64)*4)*cos(y/8+sin(t/64)*2+sin(y/16+t/32)*2)+t//64
   pix(x,y,sval%8)
   pix(x+1,y,sval+1)
   pix(x,y+1,sval+1)
   pix(x+1,y+1,sval)
  end
 end
 
 sv=sin(t/24)*2
 rect(95,65+sin(t/24+0.4)*2,40,80,15)

 rect(103,48+sv,20,20,4)
 
 elli(100,55+sv,2,5,13)
 elli(125,55+sv,2,5,13)
 
 for i=0,3 do
  elli(104+i*6,48+sin(i+3.1)*3+sv,3,3,15)
 end
 
 rectb(105,55+sv,7,5,0)
 rectb(114,55+sv,7,5,0)
 line(112,57+sv,114,57+sv,0)
 sv2=sin(t/24+0.4)*2
 
 --logicomaaaaa <3
 circb(113,85+sv2,9,12)
 circb(109,81+sv2,1,12)
 circb(117,81+sv2,1,12)
 circb(113,91+sv2,1,12)
 
 rect(40,105,162,70,13)
 rect(43,115,75,20,14)
 elli(80,120,35,10,15)
 elli(80,120,8,1,14)
 line(45,110,45,120,0)
 line(45,110,60,114+sin(t/32),14)
 line(45,111,61,115+sin(t/32),14)

 rect(123,115,75,20,14)
 elli(160,120,35,10,15)
 elli(160,120,8,1,14)

 line(125,110,125,120,0)
 line(125,110,140,114+sin(t/32),14)
 line(125,111,141,115+sin(t/32),14)

 for i=0,4 do
  line(93+i,65+sin(t/24+0.4)*2,100+i+sin(t/16)*4,118+cos(t/16+1)*4,4)
 end

 for i=0,4 do
  line(130+i,65+sin(t/24+0.4)*2,115+i,118,4)
 end
 
 wave("H0FFMAN BANGING OUT",-6,8,2)
 wave("THEM",80,28,2)
 
 print("CHOONS",81+sv2*4,121,t/32-1,true,2)
 print("CHOONS",80+sv2*4,120,t/32,true,2)
 
end

function wave(text,x,y,amp)
 for i=1,#text do
  c=text:sub(i,i)
  print(c,x+i*12,y+amp*sin((t/8+i*30)/4),13,true,2)
  print(c,x+i*12-1,y+amp*sin((t/8+i*30)/4)-1,12,true,2)
 end
end