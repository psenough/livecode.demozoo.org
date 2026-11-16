--[[
tobach here!! :)
greetz to mt, borb and gasman
lovebyte rulez!! B-)
let's do this!!
]]--

--time for some scanline nonsense :^)

function SCN(scnln)

 --[[
 --for twister
 --damn you last minute scanline stuff!!!
 if scnln>30 then
 poke(0x3ffa,math.sin(time()/200+scnln/66)*20)
 poke(0x3ff9,math.sin(time()/400+scnln/66)*math.sin(time()/800)*50)
 else
 poke(0x3ffa,0)
 poke(0x3ff9,0)
 end
 ]]--
 
 --works with checkerboard
 if scnln<32 then
  poke(0x3ff9,math.sin(time()/500+scnln/16)*20)
 else
  poke(0x3ff9,0)
 end
 
 
end

q=22
function TIC()
 cls()
 t=time()/100
 	-- NOW ALL AT ONCE :)))
 --cls()
 --oldskool()
 groovy()
 sheep()
 --twist()
 print("come to fieldfx",30,110,12,true,2)
end

function twist()
 for i=31,135 do
  line(0,i,240,i,i/16)
 end

 for a=31,135 do
  x=math.sin(a/q+t/2)*33+120
  y=math.sin(a/q+90+t/2)*33+120
  z=math.sin(a/q+180+t/2)*33+120  
  if x<y then line(x,a,y,a,15) end
  if y<z then line(y,a,z,a,15) end
  if z<x then line(z,a,x,a,15) end  
 end
 
 for a=31,135 do
  x=math.sin(a/q+t/2)*30+120
  y=math.sin(a/q+90+t/2)*30+120
  z=math.sin(a/q+180+t/2)*30+120  
  if x<y then line(x,a,y,a,1) end
  if y<z then line(y,a,z,a,2) end
  if z<x then line(z,a,x,a,3) end  
 end
 
 print("GREETZ TO LOVEBYTE ORGAS <3, MANTRATRONIC, GASMAN AND BORB <3",240-t*16,0,12,true,4)
 
end

function sheep()
 --lets bring back a fan favourite shall we??
 --mantratronics thing is mindblowing!!! :D
 
 elli(120,120,180,20,7)
 
 --lotsa thinking involved now haha..
 
 --lets get some legs going
 --looks rather dopey doesn't it? :D
 
 for i=1,4 do
  line(85+i,80,85+math.sin(t)*8+i,105,15)
  line(120+i,80,120+math.sin(t)*8+i,105,15)
 end
 
 for i=1,4 do
  line(95+i,80,95+math.cos(t+0.3)*8+i,105,15)
  line(130+i,80,130+math.cos(t+0.3)*8+i,105,15)
 end
 
 elli(110,68+math.sin(t)*2,35,20,12)
 elli(75,72+math.sin(t)*2,5,10,12)
 elli(142,61+math.sin(t)*2.1,11,13,15)
 tri(125,65+math.sin(t)*2.5,125,50+math.sin(t)*2.5,138,50+math.sin(t)*2.5,15)
 tri(158,65+math.sin(t)*2.5,158,50+math.sin(t)*2.5,148,50+math.sin(t)*2.5,15)
 
end

function groovy()
 
 --yet another for loop...
 --pretty cool huh? ;)
 --i am watching you twitch chat... >:)
 
 --loving gasmans galaxy thing, very cool :))

 for k=0,135,8 do
  for j=-1,1 do
   for i=1,300,8 do
    rect(i+j*4-t*4%32,0+j*4+k+math.sin(time()/500)*4,4,4,1)
   end
  end
 end

 for k=0,135,16 do
  for j=-1,1 do
   for i=1,300,16 do
    rect(i+j*8-t/1.2*8%32,0+j*8+k+math.sin(time()/500)*8,8,8,2)
   end
  end
 end

 for k=0,135,32 do
  for j=-1,1 do
   for i=1,300,32 do
    rect(i+j*16-t*8%32,0+j*16+k+math.sin(time()/500)*16,16,16,3)
   end
  end
 end
 
 for k=0,135,64 do
  for j=-1,1 do
   for i=1,300,64 do
    rect(i+j*32-t*8%64,0+j*32+k+math.sin(time()/500)*32,32,32,4)
   end
  end
 end
 
 for i=0,31 do
  line(0,i,240,i,14+i%3)
 end
 
 for i=1,3 do
  print("LOVEBYTE",50+i,5+i,15-i,true,3)
 end
end

--now thats organised!

function oldskool()
 for l=0,5 do
  for i=0,7 do
   line(0,34+math.sin(t/2+l/2)*20+i,240,34+math.sin(t/2+l/2)*20+i,i)
  end
 end
 --new floor perhaps??
 for i=-240,240,16 do
  line(i+120+math.sin(time()/300)*10,68,i*2+120+math.sin(time()/400)*20,136,1)
  line(i+120+math.sin(time()/300)*10+1,68,i*2+120+math.sin(time()/400)*20+1,136,2)
 end
 for i=68,136,8 do
  line(0,i+t*2%8,240,i+t*2%8,1)
  line(0,i+t*2%8-1,240,i+t*2%8-1,2)
 end 
 --lets go even MORE oldskool
 --""""alcatraz"""" bars ;)
 for i=1,136 do
  ksin=math.sin(time()/250+i/16)*math.sin(time()/600+i/8)*50
  for l=0,7 do
   line(120+l+ksin,i,120+l+ksin,136,l/2)
  end
 end
end