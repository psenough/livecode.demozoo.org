--helloooo!!!
-- ^
--tobach here, live at inercia!!!
--greetz to gasman jtruk mantra dr soft
--suule nusan superogue violet and aldroid
--<3

sin=math.sin

function TIC()
 cls(11)
 t=time()/100

 for j=0,8 do
  for i=0,16 do
   circ((j*64)-t*8%128,98-i*4,6,1)
  end
  for i=0,7 do
   circ((j*64)-t*8%128,58-i*4,15,5)
  end
 end

 rect(0,100,240,40,13)

 circ(56,104,8,15)
 circ(86,104,8,15)

 circ(156,104,8,15)
 circ(186,104,8,15)
 rect(56,106,30,4,14)
 rect(156,106,30,4,14)

 --toniiiight toniiiight
 --its all in motion....

 line(0,108,240,108,14)

 tram(0,-1+sin(t/2))
 line(0,113,240,113,14)
 
 line(0,8,240,8,14)
 line(0,7,240,7,14)

 --what a CHOON

 for j=0,3 do
  for i=0,50 do
   rect(0+i*5-t*8%5,116+j*5,4,4,14)
  end
 end
 
end

function tram(x,y)
 rect(30+x,80+y,190,30,4)
 rect(30+x,50+y,190,30,12)
 for i=0,7 do
  rect(31+i*24+x,51+y,20,28,10)
 end
 tri(224+x,80+y,220+x,110+y//1,230+x,110+y//1,4)
 rect(220+x,50+y,5,30,12)
 rect(220+x,80+y,5,30,4)
 rect(221+x,51+y,3,28,10)
 rect(197+x,51+y,22,50,4)
 rectb(197+x,51+y,22,50,15)
 rect(199+x,53+y,8,22,10)
 rect(209+x,53+y,8,22,10)
 rect(199+x,77+y,8,22,10)
 rect(209+x,77+y,8,22,10)
 
 rect(197-166+x,51+y,22,50,4)
 rectb(197-166+x,51+y,22,50,15)
 rect(199-166+x,53+y,8,22,10)
 rect(209-166+x,53+y,8,22,10)
 rect(199-166+x,77+y,8,22,10)
 rect(209-166+x,77+y,8,22,10)
 
 
 rect(32+x,46+y,190,4,12)
 rect(36+x,42+y,182,4,14)

 rect(197+x,101+y,22,5,14)
 rect(31+x,101+y,22,5,14)
 
 for i=0,3 do
  line(160+i+x//1,41+y//1,130+i+x//1,20+y//1,15)
  line(160+i+x//1,10+y//1,130+i+x//1,20+y//1,15)
 end
 print("  Inercia\nExpress 2005",54,82+y,12,true,2)
 
end