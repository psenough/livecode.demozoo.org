
-- hellooooooooo
-- hiiiiiiiiiii
-- haven't done this in a while
-- should be fun
-- no clue what im doing like but yknow
-- just wing it innit

sin=math.sin

function SCN(scnln)
vbank(0)
 poke(0x3ff9,sin(scnln//32+t/28+sin(t/23%8))*32)
 poke(0x3ffa,t*8%scnln/2)

for i=0,15 do
 poke(0x3fc0+(i*3),i*(8+math.sin(t/4+scnln/32)*2))
 poke(0x3fc0+(i*3)+1,i*8)
 poke(0x3fc0+(i*3)+2,i*16)
end
vbank(1)
 poke(0x3ff9,sin(scnln//32+t/28+sin(t/23%8))*32)
 poke(0x3ffa,t*8%scnln/2)
for i=0,15 do
 poke(0x3fc0+(i*3),i*(8+math.sin(t/4+scnln/32)*2))
 poke(0x3fc0+(i*3)+1,i*8)
 poke(0x3fc0+(i*3)+2,i*16)
end

end

function TIC()

 t=time()/100
 t=t%64

 vbank(0)
 for i=t%2,32640,1.9 do poke4(i,i/4e8+t%1) end
 
 for y=t*4%2,135,2 do
  for x=0,239 do
   --pix(x,y,(x+sin(x//8&y//4+t//1)*8+t/4)//8/2)
   if y%64<32 then
    af=1
   else
    af=(t%4)
   end
   if t%32<16 then
   ef1=((x//8&y//32)+(x+sin(x//8&y//4+t//1%32)*8+t/4)//8/2+math.random(4))/af
   else
   ef1=((x//13&y//8)-(x+sin(x//32&y//2+t*2//1%32)*8+t/2%2)//8/2+math.random(9))/af
   end
   pix(x,y,ef1)
  end
 end

 vbank(1)
 for i=t%2,32640,1.9 do poke4(i,i/4e8+t%1) end
  for y=0,135,2 do
   for x=0,239,2 do
    pix(x,y,(x//4&y//4))
   end
  end
end