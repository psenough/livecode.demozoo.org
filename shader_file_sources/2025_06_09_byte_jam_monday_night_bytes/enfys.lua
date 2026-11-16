sin=math.sin
cos=math.cos

tab={}
for i=1,100 do
 tab[i]={math.random()*256,math.random()*256}
end

function SCN(scnln)
end

function TIC()
 cls(0)
 t=time()/100 

 for i=1,#tab do
  circ((tab[i][1]-t*i/4)%240,(tab[i][2])%135,i/64,15-i/64)
 end

 print("Harry Hill's",48,13,12,true,2)
 print("Elite Cracktro 9000",64,26,12,true,1)

 print("SLIPSTREAM 1988",78,114,12,true,1)

 for j=0,4 do
  vv=sin(t/8+j/2)*32+68
  for i=0,8 do
   --sv=sin(t/2)*8+68
   line(0,i+vv,240,i+vv,12+i+t)
  end
 end

 for i=0,1 do 
  line(0,46+i*8,240,46+i*8,8+t%4)
  print("+4 trainer               YES",i+29,48,14-i*2,true)
 end

 for i=0,1 do 
  line(0,56+i*8,240,56+i*8,8+t%4)
  print("extra shiny bald head    YES",i+29,58,14-i*2,true)
 end

 for i=0,1 do 
  line(0,66+i*8,240,66+i*8,8+t%4)
  print("unlimted lives           YES",i+29,68,14-i*2,true)
 end

 for i=0,1 do 
  line(0,76+i*8,240,76+i*8,8+t%4)
  print("mr blobby minigame       YES",i+29,78,14-i*2,true)
 end

 for i=0,1 do 
  line(0,86+i*8,240,86+i*8,8+t%4)
  print("250 quid                 YES",i+29,88,14-i*2,true)
 end

 
 print("a long time ago in a galaxy far far away innit... hello lamerzzzz!! welcome to my cool new crack for Harry Hill's You've Been Framed The Videogame... greetz to elitez fuckingz to lamerzzzz.....",(260-(t*16)%2600),120,12,true,2)
end
