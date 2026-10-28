--it just crashed :/

for i=0,15 do
 poke(0x3fc0+i*3,i*16)
 poke(0x3fc0+i*3+1,i*10)
 poke(0x3fc0+i*3+2,i*8)
end

scncnt=0
function SCN(scnln)
 if scnln>=scncnt and scnln<=scncnt+32 then
  poke(0x3ff9,math.random()*16)
 else
  poke(0x3ff9,math.random()*2)
 end
 poke(0x3ffa,math.random()*3)
end

sin=math.sin
function TIC()
 t=time()/100
 scncnt=scncnt+1
 if scncnt>135 then scncnt=0 end
 --cls()
 for i=0,8000 do
  pix(math.random()*240,math.random()*136,math.random()*6)
 end
 
 grtz={"  choose  ","   life   ","  choose  ","   a job   ","  choose  "," a career ","  choose  "," a fuckin ","big telly"}
 
 for i=0,32 do
   print(math.random(),-20,i*16,math.random()*4,true,2)
   print(math.random(),150,i*16,math.random()*4,true,2)
 end
 
 for i=0,16 do
  line(0,i*12,240,i*12,sin(i/4+t)*2+2)
  line(i*12,0,i*12,135,sin(i/4+t+1)*2+2)
 end
  
 for i=-4,4 do
 print(grtz[(t/2//1+i)%#grtz+1],30+i*8,50+math.random()*8+i*32-t*2%32,math.random()*4+4,true,5,true) 
 end 
 
end