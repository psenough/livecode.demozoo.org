--greetz to ferris, blossom
--mantra and visy <3

stars={}
planets={}

sin=math.sin
cos=math.cos

for i=0,200 do
stars[i]={math.random()*240,math.random()*136}
end

for i=0,10 do
planets[i]={math.random()*300,math.random()*136,math.random()*8}
end

function SCN(scnln)
 if scnln>=0 and scnln<=16 then
  poke(0x3ff9,sin(t/8+scnln/16)*16)
 else
  poke(0x3ff9,0)
 end
end

function TIC()
 cls()
 t=time()//32
 fv=fft(2)+fft(3)+fft(4)*512
 --print(fv)
 print("LOVEBYTE 2023",45,0,12,true,2)
 for i=0,200 do
  pix((stars[i][1]-(t/8*i/5))%240,(stars[i][2]+sin(t/16+i/64)*8)+16,15-i/64-fv/2)
 end
 for i=1,10 do
 planet((planets[i][1]-(t/4*i/32)*16)%300-20,planets[i][2]+sin(t/16+i/32)*2+32,10-planets[i][3])
 end
 planet(120,128+sin(t/8)*2,35)

 ufoy=sin(t/8)*8

 smolshp(0,8-t/2%52)

 for i=0,40,2 do
  pix(120+sin(i/8+t/8)*8,48+i+ufoy,12+i+t)
  pix(120+sin(i/8+t/8+1.5)*8,48+i+ufoy,12+i+t)
  pix(120+sin(i/8+t/8+4)*8,48+i+ufoy,12+i+t)
 end
 
 circ(120,40+ufoy,10,10)
 circb(120,40+ufoy,10,9)
 elli(120,48+ufoy,32,6,13)
 ellib(120,48+ufoy,32,6,14)
 
 for i=1,3 do
  print("FEEL THE LOVE",40+i+sin(t/4)*8,136-16+i,0+i+t/4%8,true,2)
 end 
end

function planet(x,y,s)
 circ(x,y,s,14)
 circ(x,y,s-2,13)
 circ(x-17,y,s-21,14)
 circ(x+1-17,y-1,s-22,13)
 circ(x-17+20,y+12,s-23,14)
 circ(x+1-17+20,y-1+12,s-24,13)
 circ(x-17+30,y-4,s-23,14)
 circ(x+1-17+30,y-1-4,s-24,13)
end

function smolshp(x,y)
 elli(120+x,90+y,4,2,12)
 elli(116+x,88+y,1,2,15)
 for i=1,2 do
  line(114+i*4+x,92+y,114+i*4+x,95+y,15)
 end
end