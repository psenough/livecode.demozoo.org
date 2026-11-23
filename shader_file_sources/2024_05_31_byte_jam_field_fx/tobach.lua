--hello from the tent in field-fx!!
--greetz to all in the tent and fellow jammers
-- :3

grass={}
for i=1,100 do
 grass[i]={math.random()*240,(math.random()*68)+84}
end
sin=math.sin
function TIC()
 cls(8)
 t=time()/100
 t2=t/2%4
 
 if t2>2 then
  for i=0,3 do
   line(160,68,160-math.random()*200,-20,6)
   line(60,68,60+math.random()*200,-20,11)
  end
 else
  for i=0,3 do
   line(190,68,160+math.random()*200,-20,2)
   line(90,68,90-math.random()*200,-20,4)
  end
 end
 
 title="FIELD-FX 2024 !!   Greetz to everyone who showed up to watch <3      And also to the following groups: Bitshifters, Torment, Rift, Slipstream, Haujobb, Poo-Brain, Alcatraz, Logicoma, Desire, Defeest, Svatg, K2, Titan, and you !!"
 for i=1,#title do
  for j=0,2 do
   print(title:sub(i,i),240+i*18-j-(t*24)%4400,12+sin(i/4+t)*8+j,14-j,true,3)
  end
 end

 elli(80,90,60,40,12)
 ellib(80,90,60,40,13) 
 
 rect(0,80,240,100,7)
 --haha grass stars :))))
 for i=1,100 do
  pix(grass[i][1],grass[i][2]-80,12)
 end

 drawgrass()
 
 rect(120,60,100,40,12)
 rectb(120,60,100,40,13)
 
 tri(120+45,100,125+45,60,130+45,100,15)
 tri(120,60,125+45,50,220,60,13)
 
 --hehehe thats the tent we're in :)
 rect(121,87,46,10,12)
 print("WORKSHOP 4",124,90,15,true,1,true)
 rectb(121,87,46,10,1)
 rect(128,97,4,10,15)
 rect(158,97,4,10,15)

 for i=0,240 do
  circ(i,120+sin(i/32)*sin(i/24)*4,7,15)
 end

 for i=0,240 do
  circ(i,120+sin(i/32)*sin(i/24)*4,5,14)
 end

 drawtent(0,0,1)
 drawtent(40,4,9)
 drawtent(20,20,11)
 
end

function drawgrass()
 for i=1,100 do
  tri(0+grass[i][1],0+grass[i][2],4+grass[i][1],-4+grass[i][2],8+grass[i][1],0+grass[i][2],6)
 end
end

function drawtent(x,y,c)
 tri(10+x,90+y,20+x,60+y,30+x,90+y,c) 
 rect(20+x,60+y,30,30,c)
 tri(10+30+x,90+y,20+30+x,60+y,30+30+x,90+y,c+1)

end