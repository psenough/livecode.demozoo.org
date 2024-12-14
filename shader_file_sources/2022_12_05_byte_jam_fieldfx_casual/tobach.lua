--yeeeeee hawwwwww B-)
--greetz to the bytejam folks <3
sin=math.sin
cos=math.cos

function TIC()
--hmmmmm wonder what to do this time...
 cls()
 t=time()
 for i=1,3 do
  rect(0,i*16,240,136/4,i)
 end
 
 circ(120,78,50,4) 
 rect(0,80,240,136/2,2)

end

function SCN(scnln)
 if scnln<78 then
  poke(0x3ff9,sin(t/64+scnln)*2)
 else
  poke(0x3ff9,0)
 end
end

--trying something hmmmm...
function OVR()

 line(0,85,240,85,13) 
 
 rect(90,56,60,25,15)
 rect(137,44,6,12,8)
 
 circ(140-t/16%90,40-t/32%45,2,13)
 
 tri(134,40,140,50,145,40,8)
 
 for i=0,4 do
  rectb(95+i,42+i,15,20,15)
 end
 
 circ(102,76,8,14)
 circ(120,76,8,14)
 
 for i=0,2 do
  line(100-sin(t/128)*4,75+i+cos(t/128)*4,123-sin(t/128)*4,75+i+cos(t/128)*4,13)
 end
 
 circ(135,80,4,13)
 circ(145,80,4,13)
 
 tri(152,83,150,75,165,83,9)

 elli(240-t/24%490,89,4,2,3)
 cactus2(340-t/24%490,72)
 cactus1(240-t/16%290,70)
 elli(290-t/12%490,110,8,4,3)
 
 for i=0,2 do
  print("CHOO CHOO",64+i,120+i,14-i,true,2)
 end
end

function cactus1(x,y)
 elli(4+x,3+y,2,10,5)
 elli(8+x,10+y,6,2,5)
 elli(14+x,10+y,4,20,5)
end

function cactus2(x,y)
 elli(20+x,5+y,2,6,6)
 elli(18+x,10+y,3,1,6)
 elli(14+x,10+y,2,10,6)
end