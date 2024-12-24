--hello ho ho
--mary chrysler
--hap chrimmus
--happee crimbo

snow={}
for i=1,250 do
 snow[i]={math.random()*256,math.random()*256}
end

sin=math.sin
function TIC()
 cls(10)
 t=time()/100
 --its snowing innit
 for i=1,#snow do
  pix((snow[i][1]+sin(t/2+i)*2),(snow[i][2]+t+i*t/64)%135,12)
 end
 
 rect(0,98,240,40,12)
 rect(68,98,100,40,13)
 for i=-1,4 do
  tree(-78+i*48,0,i,sin(i*9)*4)
 end
 snowman(0,-4)
 for i=-16,16 do
  sv=-math.abs(sin(t/1.5+i)*4)
  snowchild(i*32+t*8%513,0+sv,i*3%8+3)
 end
end

function tree(x,y,o,s)
 rect(113+x,78+y,15,20,1)
 for i=-6+s/2,6 do
  tri(100-i+x,68+i*4+y,120+x,58+i*4+y,140+i+x,68+i*4+y,7)
 end
 for i=-1+s*2,52 do
  circ(120+sin(i/2)*i/3+x,38+i+y,1,i+t+o*3)
 end
end

function snowchild(x,y,c)
 for i=0,1 do
  circ(20+x,78+i*12+y,8+i*2,13)
 end
 for i=0,1 do
  circ(20+x,78+i*12+y,7+i*2,12)
  circ(19+i*5+x,76+y,1,15)
 end
  rect(14+x,81+y,14,3,c)
  rect(16+x,81+y,3,8,c)
  circ(22+x,90+y,1,15)
end

function snowman(x,y)
 for i=0,20 do
  circ(120+i,68+i/4+y,1,15)
 end
 for i=0,20 do
  circ(120-i+sin(t/2+1.6)*2,70-i/(4+sin(t/2)*2)+y,1,15)
 end
 for i=0,2 do
  circ(120,58+i*16+y,9+i*2,13)
 end
 for i=0,2 do
  circ(120,58+i*16+y,8+i*2,12)
 end
 for i=0,1 do
  circ(120,73+i*16+y,1,15)
  circ(117+i*6,55+y,1,15)
 end
 rect(113,64+y,16,3,1)
 rect(116,64+y,3,15,1)
 for i=-4,4,2 do
  pix(120+i,61+sin(i/3+1.5)*2+y,15)
 end
 rect(117,59+y,3,1,3)
 rect(140,63+y,3,40,0)
 circ(141,60+y,8,2)
 circ(141,60+y,6,4)
 rect(137,59+y,9,3,0)
end