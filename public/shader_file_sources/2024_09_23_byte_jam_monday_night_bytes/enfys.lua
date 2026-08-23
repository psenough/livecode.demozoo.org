--beep boop enfys

sin=math.sin

for i=0,15 do
 a=0x3FC0+i*3
 v=i*255/15
 poke(a,v/255)
 poke(a+1,(v/255)^2*255)
 poke(a+2,v/255)
end

parts={}
for i=1,72 do
 parts[i]={math.random()*256,math.random()*200,math.random()*40+5,math.random()*40+10}
end

function SCN(scnln)
 poke(0x3ff9,math.random()*4+math.tan(t/8)*4+sin(scnln/32+t/17)*8)
end

function TIC()
 t=time()/100
 sv=t%4
 --cls()
 for i=t%2,32640,1.9 do poke4(i,i/4e8+t%1) end
 
 for i=0,32 do
  line(-8+i*8,0,-8+i*8,130,sin(i/3+t/2)*4+4)
 end
 
 for i=1,#parts do
  rectb((parts[i][1]+math.tan(t/4)*8),-50+(parts[i][2]-t/8*i)%256,parts[i][3],parts[i][4],i/8%12+4)
 end
 
 for i=0,64 do
  print(string.char((math.random()*32+32)//1+i),20+i*24-t*16%240,110,12+sin(i)*4,true,3)
  print(string.char((math.random()*32+32)//1+i),-240+i*24+t*16%240,10,12+sin(i)*4,true,3)

  print(string.char((math.random()*32+32)//1+i),20,-240+i*24-t*16%240,12+sin(i)*4,true,2)
  print(string.char((math.random()*32+32)//1+i),220,-240+i*24+t*16%240,12+sin(i)*4,true,2)
 end
 
 for i=1,#parts do
  rect((parts[i][1]-t)%256,-50+(parts[i][2]-t/7*i*2+1)%256,parts[i][3]/2,parts[i][4]/2,i/8%8+4)
 end

end
