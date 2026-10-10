for i=0,15 do
 a=0x3fc0+i*3
 poke(a,i*5)
 poke(a+1,i*4)
 poke(a+2,i*16)
end

--hello stream :3
--lol nvm same time next week o7
--nvm we are so back???

sin=math.sin
cos=math.cos

tab={}
for i=1,200 do
 tab[i]={math.random()*240,math.random()*240}
end

function SCN(scnln)
 poke(0x3ff9,math.random()*2)
 for i=0,47 do
  poke(16320+i,i%3*i*.5*(sin(scnln/8+t/8+sin(scnln/13+t/7))+1)*4)
 end
end

function TIC()

 t=time()/40
 
 if t%2==0 then
 cls()
 end
 --gonna be honest i have no clue
 --what i'm doing, or if the jam
 --is even still going on
 
 --ah well
  
 for i=1,200 do
  rect(tab[i][1]+sin(i/32+t/32)*32,(tab[i][2]-t*i/16)%200-64,1,64,i/32%4)
  rect((tab[i][1]-t*i/16)%200,tab[i][2]+sin(i/32+t/32)*32,64,1,i/32%4)
 end

 for i=0,16 do
  print(".,;@#@;,.",80+sin(i*8+t/47)*64,i*16-t%16,math.random()*4+4,true,2,true)
 end
 
 for y=0,135,2 do
  for x=0,239,2 do
   cv=(x//2+sin(y/32+t/16)*8//1+t//1)&(y//2+sin(x/32+t/14)*8//1+t/4//1)
   pix(x,y,cv/8%8)
  end
 end

 print("enfys",200,136-14,8,true,2,true)

end
