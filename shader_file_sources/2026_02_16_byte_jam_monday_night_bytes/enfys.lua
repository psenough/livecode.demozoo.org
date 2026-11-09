for i=0,15 do
 poke(0x3fc0+i*3,i)
 poke(0x3fc0+i*3+1,i*10)
 poke(0x3fc0+i*3+2,i*16)
end

parts={}

for i=1,64 do
 parts[i]={math.random()*240,math.random()*136}
end

sin=math.sin

function SCN(scnln)
 poke(0x3ff9,math.random()*3)
 for i=0,15 do
  poke(0x3fc0+i*3,i)
  poke(0x3fc0+i*3+1,i*10)
  poke(0x3fc0+i*3+2,i*16+sin(scnln/32-t/4)*16+16)
 end
end

function TIC()
 t=time()/100
 poke(0x3ffb,0)
 for i=0,4000 do
  pix(math.random()*240,math.random()*136,math.random()*2)
 end
 
 for i=0,15 do
  line(i*32+t%32,0,i*32+t%32,136,math.random()*2+2)
  line(0,i*32+t%32,240,i*32+t%32,math.random()*2+2)

  line(i*16+t*1.5%16,0,i*16+t*1.5%16,136,math.random()*2+4)
  line(0,i*16+t*1.5%16,240,i*16+t*1.5%16,math.random()*2+4)
 end
 
 for i=1,#parts do
  for j=0,32 do
   circ((parts[i][1]+t/2*i/8+t)%250,(parts[i][2]+t*2)%136,2,math.random()*4+8)
  end
  rectb(-4+(parts[i][1]+t/2*i/8+t)%250,-4+(parts[i][2]+t*2)%136,8,8,math.random()*4+4)
 end
 
end
