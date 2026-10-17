for i=0,7 do
 a=i*3
 poke(0x3fc0+a,i*32)
 poke(0x3fc0+a+1,i*32)
 poke(0x3fc0+a+2,i*32)
end
for i=8,15 do
 a=i*3
 poke(0x3fc0+a,i*32)
 poke(0x3fc0+a+1,0)
 poke(0x3fc0+a+2,0)
end

sin=math.sin

function SCN(scnln)
 if dt>=0 and dt<=9 then
  poke(0x3ff9,math.random()*4+sin(scnln//32+t/32)*16)
 else
  poke(0x3ff9,math.random()*4)
 end
end

function TIC()
 --cls()
 for i=0,10000 do
  pix(math.random()*240,math.random()*136,0)
 end
 t=time()/100
 dt=t%40

 if dt>=0 and dt<=9 then
  scn1()
 elseif dt>=10 and dt<=19 then
  scn2()
 elseif dt>=20 and dt<=29 then
  scn3()
 elseif dt>=30 and dt<=39 then
  scn4()
 end
 --scn4()
  
end

function scn1()
 for j=0,3 do
  for i=-16,16 do
   if t//1%8==0 then
    v=math.random()*10+5
   end
    rectb(47+j*60,i*12-t*4%32,7,8,math.random()*4+4)
    rect(4+j*60,0+i*16+t*8%128,240/6,v,math.random()*2)
    rect(58+j*60,0+i*16-t*8%128,4,v,math.random()*4+8)
  end
 end
end

function scn2()
 for x=0,15,math.random()*2//1 do
  for y=0,15,math.random()*2//1 do
   circ(x*16+t*8%16,y*16+t*4%16,1,math.random()*7)
   circ(x*16-t*3%16,y*16+t*7%16,1,math.random()*7)
  end
 end
 circb(120,68,60,7)
 for i=0,6 do
  line(0,0+i*32-t*8%32,240,0+i*32-t*8%32,math.random()*8+8)
 end
end

function scn3()
 for j=0,3 do
  for i=0,32 do
   chr=44+sin(i/3+t/8+j*8)*8//1
   print(string.char(chr),i*24,j*38,math.random()*4,true,4)
   print(string.char(chr),i*12-t*4%32,24+j*38,math.random()*4+4,true,2)
  end
 end
end

function scn4()
 for i=0,600 do
  circ(120+sin(i/8+t)*128,68+sin(i/4+t)*128,1,math.random()*8)
 end
 for i=0,400,math.random()*32 do
  line(math.random()*240,math.random()*136,math.random()*240,math.random()*136,math.random()*8+8)
 end
 
end