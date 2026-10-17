sin=math.sin
cos=math.cos
abs=math.abs

parts={}

for i=1,200 do
 parts[i]={math.random()*240,math.random()*136}
end

function SCN(scnln)
 vbank(0)
 if scnln>=113 and scnln<=136 then
  poke(0x3ff9,sin(scnln*8+t/4)*4)
 else
  poke(0x3ff9,0)
 end
end

function TIC()
 poke(0x3fc0+(3*4),120)
 poke(0x3fc0+(3*4)+1,94)
 poke(0x3fc0+(3*4)+2,59)
 vbank(1)
 cls()
 vbank(0)
 cls()
 t=time()/100
 rect(0,90,240,2,6)
 rect(0,127,240,2,6)

 rect(215,20,21,70,4)
 rect(217,24,17,17,3)
 circ(225,32,7,12)

 line(225,32,225+sin(t/32)*6,32-cos(t/32)*6,0)
 line(225,32,225+sin(t/32/12)*4,32-cos(t/32/12)*4,0)
 
 tri(215,20,220,10,235,20,15)
 tri(215,20,230,10,235,20,15)
 
 tri(218,10,225,-5,232,10,15)
 
 rect(218,8,14,5,4)
 
 for i=0,4 do
  line(217+i*4,45,217+i*4,85,3)
 end

 rect(-10+(t*3)%252,86,6,3,15)
 rect(-10+(t*3)%252,88,8,2,15)
 
 rect(-12+(240-t*2)%264,84,12,6,2)
  
 for i=0,3 do
  rect(41+i*50.70,98,6,22,14)

  rect(43+i*50.70,80,3,11,13)
  rect(43+i*50.70,128,3,11,13)

  circ(42+i*50.70,83,1,3)
  circ(46+i*50.70,83,1,3)
  circ(44+i*50.70,80,1,3)

  circ(42+i*50.70,133,1,3)
  circ(46+i*50.70,133,1,3)
  circ(44+i*50.70,136,1,3)

 end
 for i=0,240 do
  circ(i,99-abs(sin(i/16+0.4))*8,1,6)
  circ(i,120+abs(sin(i/16+0.4))*8,1,6)
 end
 rect(0,90,240,1,14)
 rect(0,128,240,1,14)
 
 message="oh no, its like"
 message2="a week til crimbo"
 
 for i=1,#message do
  for j=0,2 do
   print(string.sub(message,i,i),5+i*12-j,30-j+sin(i+t)*2,14-j,true,2)
  end
 end
 for i=1,#message2 do
  for j=0,2 do
   print(string.sub(message2,i,i),-5+i*12-j,55-j+sin(i+t)*2,14-j,true,2)
  end
 end 

 vbank(1)
 rect(195,90,50,50,14)
 for i=1,200 do
  pix((parts[i][1]+sin(i+t/32)*64)%240,(parts[i][2]+t*4)%136,12)
 end
end