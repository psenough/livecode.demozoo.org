--beep boop enfys

for i=0,15 do
 poke(0x3fc0+i*3,i*8)
 poke(0x3fc0+i*3+1,i*4)
 poke(0x3fc0+i*3+2,i*16)
end

sin=math.sin
cos=math.cos

rects={}
for i=1,200 do
 rects[i]={math.random()*256,math.random()*256}
end

rectobjtab={}
for i=1,8 do
 rectobjtab[i]={math.random()*320}
end

function SCN(scnln)
 poke(0x3ff9,math.random()*2+scnln/5)
end

function TIC()
 cls()

 t=time()
 t2=time()/100
 
 sx=cos(t2/16)*64%32
 sy=0

 for i=0,32 do
  line(0+i*32+sx,0,0+i*32+sx,135,3)
  line(0,i*32,240,i*32,3)
 end
 
 for i=1,#rects do
  rectb(rects[i][1],(rects[i][2]-t2*4*i/32)%256-32,30-i/16,30-i/16,i/32+2)
 end

 txtarr={"it is all wires,","the veins of","artificial divinity.","to what gods","do we pray?","some malfunction","and we forget","to care..."}

 for i=1,#txtarr do
  print(txtarr[i],-12+i*20+math.random()*2,-10+i*16,14+sin(t2)*2,true,2,true)
 end

 for i=1,8 do
  rectobj((i*32-t2*16)%256-32,i)
 end

 for y=0,135,2 do
  for x=0,239,2 do
   pix(x+t%2,y+t%2,0)
  end
 end 
  
end

function rectobj(y,off)
 if off%2==0 then
 rectb(-1,0+y,242,10,10)
 for i=0,3 do
  rect((rectobjtab[off][1]+t2*(16+rectobjtab[off][1]/32))%340-i*8-64,2+y,6,6,15-i*2+math.random()*4-4)
 end
 else
 rectb(-1,0+y,242,10,10)
 for i=0,3 do
  rect((rectobjtab[off][1]-t2*(16+rectobjtab[off][1]/32))%340+i*8-64,2+y,6,6,15-i*2+math.random()*4-4)
 end 
 end
end