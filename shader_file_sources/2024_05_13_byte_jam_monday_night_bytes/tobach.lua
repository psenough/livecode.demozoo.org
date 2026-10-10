--forgot to do starting text lol
--greetz to reality, pumpuli, catnip
--vurpo, jlorry and polynomial!!

--also to superogue, blossom and
--dozer the cat who are in the room :)

sin=math.sin
cos=math.cos
function TIC()
 t=time()/500
 cls(10)
 tv=sin(t*2)*2//1
 for i=0,11 do
  sv=sin((2*(math.pi)*i/8+t))*90-6
  cv=cos((2*(math.pi)*i/8+t))*90-6
  print("*",119+sv,63+cv,15,true,3)
  print("*",121+sv,65+cv,4,true,3)
 end
 tri(120-70,68,120,98,120+70,68,8)
 tri(120-80,68,120-60,48,100,68,8)
 tri(120-80+100,68,120-40+100,48,100+100,68,8)
 
 tri(120-80,68,120,188,120+80,68,8)
 tri(120-50,138,120,68,120+50,138,8)

 tri(120-20,68,120,128,120+20,68,12)

 rect(45,68,23,80,8)
 rect(173,68,23,80,8)

 for i=0,3 do
  elli(120,68-i*2,10,4,3)
 end
 rect(98,48+tv,45,16,12)

 for i=4,13 do
  circ(120,48-i+tv,22,12)
 end
 for i=0,12 do
  circ(120,48-i+tv,20,4)
 end
 for i=-15,15 do
  circ(120-i,24+sin(i/6-1.6)*3+tv,5,12)
 end
 
 circ(120,52+tv,13,12)
 rect(105,38+tv,30,18,4)
 
 rect(110,62+tv,20,4,4)
 line(110,60+tv,130,60+tv,0)
 
 circ(120,46+tv,5,3)
 circ(120,44+tv,5,4)
 
 for i=-4,4 do
  circ(110-i,35+sin(i/2-1.6)+tv,1,2+i%2)
 end
 for i=-4,4 do
  circ(130-i,35+sin(i/2-1.6)+tv,1,2+i%2)
 end
 
 circ(110,42+tv,4,3)
 circ(110,44+tv,4,4)

 circ(130,42+tv,4,3)
 circ(130,44+tv,4,4)
 
 for i=-6,6 do
  circ(120-i,52+tv,2,2+i%2)
 end
 tc={0,4,8,9}
 for i=1,4 do
  print("EURO  PAPA",4-i,14-i+sin(t*4)*3,tc[i],true,4)
 end
 
end
