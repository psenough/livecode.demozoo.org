function SCN(scnln)
 poke(0x3ff9,math.sin(scnln/32+t/2)*32)
end

function TIC()
 cls()
 t=time()/100
 for i=0,136,2 do
  sv=math.sin(i/32+t/3)*math.sin(i/64+t/7)*32
  line(0,i,240,i,sv%4)
 end
 for i=0,240,2 do
  sv=math.sin(i/32+t/3)*math.sin(i/64+t/7)*32
  line(i,0,i,135,sv%5)
 end
 
 print("ENFYS WOZ HERE",40,60,t,true,2)
 
end