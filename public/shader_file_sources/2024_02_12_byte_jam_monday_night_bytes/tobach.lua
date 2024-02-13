
--another bytejam (forgot to do greetz oops)
--greetz to lynn, henearxn, vurpo
--catnip and jlorry :)

sin=math.sin

poke(0x3fc0,0)
poke(0x3fc1,0)
poke(0x3fc2,0)

poke(0x3fc3,255)
poke(0x3fc4,0)
poke(0x3fc5,0)

poke(0x3fc6,255)
poke(0x3fc7,255)
poke(0x3fc8,0)

poke(0x3fc9,0)
poke(0x3fca,0)
poke(0x3fcb,255)

poke(0x3fcc,0)
poke(0x3fcd,255)
poke(0x3fce,0)

poke(0x3fcf,0)
poke(0x3fd0,255)
poke(0x3fd1,255)

poke(0x3fd2,255)
poke(0x3fd3,0)
poke(0x3fd4,255)

poke(0x3fd5,255)
poke(0x3fd6,255)
poke(0x3fd7,255)


function TIC()
 cls(15)
 t=time()//32
 pv=t/96//1%3
 rect(0,0,29,135,14)
 rect(211,0,29,135,14)
 
 rectb(-1,-1,30,137,15)
 rectb(211,-1,30,137,15)
 
 for i=0,16 do
  for j=0,3 do
   pix(4+j*6,4+i*8+(j*2)%4,15)
  end
 end

 for i=0,16 do
  for j=0,3 do
   pix(216+j*6,4+i*8+(j*2)%4,15)
  end
 end
 
 rect(29,1,182,134,0)
 --pv=2
 
if pv==0 then
 print("P100 FFXFAX 1 100 MON 12 FEB",36,2,7,true)
 for i=0,2 do
  rect(36+i*18,16,17,17,7)
 end
 print("FFX",37,17,0,true,3)
 rect(96,16,106,17,3)
 print("MONDAY",97,17,2,false,3)

 print("NEWS",37,40,2,true,1)
 print("HOT BYTEJAM\nACTION!!",37,48,7,false,2)
 print("P200",156,60,2,true,2)

 rect(36,74,166,4,3)

 print("LOVEBYTE PARTY\nRESULTS",37,84,7,false,2)
 print("P300",156,96,2,true,2)

 rect(36,110,166,4,3) 
 
 for i=1,4 do
  print("FFX",8+i*40,123,i,true)
 end
 
elseif pv==1 then
 
  print("P110 FFXFAX 1 100 MON 12 FEB",36,2,7,true)
 for i=0,2 do
  rect(36+i*18,16,17,17,7)
 end
 print("FFX",37,17,0,true,3)
 rect(96,16,106,17,3)
 print("MONDAY",97,17,2,false,3)

 rect(162,60,40,50,2)

 rect(172,74,4,10,0)
 rect(172,84,10,4,0)

 rect(178,94,8,8,0)
 if t/16%2<1 then
 rect(178,98,8,4,2)
 end

 rect(164,66,8,4,0)
 rect(184,66,8,4,0)

 rect(152,60,50,4,1)
 rect(168,50,30,10,1)

 print("RADICAL JIM\nSAYS:",37,38,7,false,2)

 rect(36,66,120,50,7)
 rect(67,94,95,4,7)

 print("WHY DID THE\nCHICKEN\nCROSS THE\nROAD?",37,68,0,false,2)

 print("PRESS 'REVEAL' FOR ANSWER!",46,123,t/16%2,true)
 
 else if pv==2 then

  print("P120 FFXFAX 1 100 MON 12 FEB",36,2,7,true)
 
 rect(56,16,127,17,3)
 print("WEATHER",57,17,2,true,3)

 rect(140,35,30,20,5)

 rect(150,50,30,60,5)
 rect(130,70,20,25,5)
 rect(120,110,70,10,5)

 rect(180,80,10,20,5)

 print("    IT IS\n\n  BLOODY\n\nMISERABLE",37,49,6,false,2)

 for i=1,4 do
  print("FFX",8+i*40,123,i,true)
 end
 
 end
 end
end
