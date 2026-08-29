--tobach here!! :)
--greetz to alia, visy and gasman <3
--hope ur monday is going swell!!

--i'm going to hopefully make what
--i was supposed to make for outline!

rain={}

for i=0,70 do
 rain[i]={math.random()*256,math.random()*256}
end

sin=math.sin
abs=math.abs
function TIC()
 cls()
 for i=0,240,2 do
  line(i,0,i,240,abs(sin(i/16)*3))
  --line(i,0,i,240,sin(i/7)*3)
 end
 for i=0,30 do
  circ(0+(i*8),106+sin(i)*3,10,7+sin(i))
 end
 rect(0,110,240,40,15)
 t=time()/100
 elli(120,80,28,38,14)
 elli(99,90,8,24,14)
 --elli(140,90,8,24,14)
 elli(110,116,8,4,14)
 elli(129,116,8,4,14)
 elli(120,60,20,24,14)
 elli(120,90,24,28,13)
 for i=0,3 do 
 st=-sin(i)*3
 tri(103+(i*9),74+st,107+(i*9),69+st,111+(i*9),74+st,14)
 end
 for i=0,4 do 
 sv=-sin(i/1.2)*3
 tri(98+(i*9),84+sv,102+(i*9),79+sv,106+(i*9),84+sv,14)
 end
 for i=0,2 do
  line(110,55,90,55+sin(i*2)*9,15)
 end
 for i=0,2 do
  line(130,55,150,55+sin(i*2)*9,15)
 end
 circ(112,45,3,12)
 circ(128,45,3,12)
 circ(113,45,1,0)
 circ(127,45,1,0)
 tri(116,51,120,48,124,51,15)
 rect(118,57,4,1,15)
 
 tri(107,38,110,26,113,36,14)
 tri(107+20,36,110+20,26,113+20,38,14)
 rect(109,34,2,8,14)
 rect(129,34,2,8,14)
 elli(119,37,8,2,5)

 rect(123,24,2,54,15)
 elli(120,20,20,4,8)
 tri(100,20,92,30,140,20,8)
 tri(100,20,150,30,140,20,8)
 for i=0,7 do
  circ(140-i*2,74-i/4,5-sin(i/4),14)
 end

 rect(40,118,14,4,14)
 
 rect(46,68,2,50,0)
 rectb(45,68,3,50,14)
 circ(46,68,8,10)
 rect(41,88,11,3,15)
 rect(38,67,17,3,12)


 for i=1,#rain do
  for j=0,8 do
   pix((rain[i][1]-j/4-t*4)%240,(rain[i][2]+t*4*(i/4+4)+j*2)%256,8)
   pix((rain[i][1]-j/4-t*4)%240,(rain[i][2]+t*4*(i/4+4)+j*2+1)%256,9)
  end
 end

end
