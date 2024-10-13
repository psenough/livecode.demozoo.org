ptab={}

for i=1,64 do
 ptab[i]={math.random()*256,math.random()*256}
end

for i=0,15 do
 poke(0x3fc0+(i*3),i*10)
 poke(0x3fc0+(i*3)+1,i*16)
 poke(0x3fc0+(i*3)+2,i*12)
end

function TIC()
 t=time()/100
 for i=0,5000 do
  pix(math.random()*240,math.random()*136,0)
 end
 
 for i=1,#ptab do
  circ((ptab[i][1]-t/4*i/2+math.sin(t/64*i/2)*16)%256,(ptab[i][2]+t/2*i/2)%256,3,4+i%4)
 end
 
end