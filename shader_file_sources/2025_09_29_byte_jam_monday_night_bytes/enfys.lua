sin=math.sin

for i=0,47 do
 poke(16320+i,i*5)
end

function SCN(scnln)
 if scnln>=-30+t*8%135 and scnln<=10+t*8%135 then
  poke(0x3ff9,sin(t/8+scnln)*4+math.random()*32)
 else
  poke(0x3ff9,math.random()*3)
 end
 for i=0,47 do
  poke(16320+i,i%3*i*(sin(t/4)/2+1.5)+scnln/8)
 end
 for i=0,47 do
  poke(16320+(3*8),i%3+sin(scnln/16-t/2)*32+8)
 end

end

function TIC()
 t=time()/99
 poke(0x3ffb,0)
 for i=t%2,32639,1.9 do poke4(i,i/4e8+t%1)end
 for y=0,135,2 do
  for x=0,239,2 do
   pix(x+t%2,y+t%2,(sin(x/2/16+1+t/2)*8//1+8&y//8+t*2//1)+t)
  end
 end
 for i=-2,3 do
  line(0,i*32+t*8%64,240,i*32+t*8%64,2+i*8)
 end
 rectb(math.random()*240,math.random()*135,80,10,15)
 print(math.random()*32,math.random()*240,math.random()*135,15,true,2,true)
 print(" you know what\n  you wanna do\nwith that mate?\n\n you wanna put\na banging donk\n     on it",40,30,8,true,2)
end