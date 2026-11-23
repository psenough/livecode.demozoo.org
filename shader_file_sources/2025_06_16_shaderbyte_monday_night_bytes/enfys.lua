--i hope the thing works!!!

sin=math.sin
cos=math.cos

--i dont know any more numbers
--of pi than this sorry for the
--lack of precision lol
pi=3.14159265358

parts={}
for i=1,512 do
 parts[i]={math.random()*240,math.random()*136}
end

function SCN(scnln)
 for i=0,47 do
  poke(16320+i,i%3*i*1.5*(sin(scnln/16+t/8+sin(scnln/3+t/2))/2%2))
 end
end

function TIC()
 t=time()/100
 ft=time()/100
 
 for i=t%2,32640,1.9 do
  poke4(i,i/4e8+ft%1)
 end

 for i=1,#parts do
  rect(parts[i][1],(parts[i][2]+t/8*i/32)%144-8,8,8,i%2+1)
  circ((parts[i][1]+(sin(i/64+t/18)*32))%240,parts[i][2]+(sin(i/31+t/17)*32),5,1)
 end

 --i have to admit i am a bit
 --lost in my own effect

 for j=0,3 do
  for i=1,#parts do
   pix((parts[i][1]+(sin(i/64+t/18+j/16)*32))%240,parts[i][2]+(sin(i/31+t/17+j/16)*32+i/16),j+1)
   circ((parts[i][1]+(sin(i/64+t/18+j/16)*32))%240,parts[i][2]+(sin(i/31+t/17+j/16)*32),1,j+2)
   rect((parts[i][1]+(sin(i/64+t/18+j/16)*32)-32)%240,parts[i][2]+(sin(i/31+t/17+j/16)*32)-32,3,3,j)
  end
 end
 print("enfys",200,136-14,13,true,2,true)
end