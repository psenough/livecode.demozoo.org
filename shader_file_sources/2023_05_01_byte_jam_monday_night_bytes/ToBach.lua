-- ^
--tobach here!!
--greetz to mantra, jtruk and alia!! <3
sin=math.sin
cos=math.cos
abs=math.abs
function TIC()
 t=time()//32
 cls(8)
 
 elli(291-t/2%400,21,50,2,13)
 elli(291-t/3%400,41,30,2,13)

 elli(290-t/2%400,20,50,2,12)
 elli(290-t/3%400,40,30,2,12)


 for i=0,3 do
  rect(2+i*100,98,2,32,13)
 end
 for i=0,240 do
  pix(0+i,98+abs(sin(i/32)*8),15)
  pix(0+i,99+abs(sin(i/32)*8),14)
 end
 for i=0,240 do
  circ(0+i*8,100+abs(sin(i/4)*8),1,i+t/8)
 end

 rect(0,128,240,8,6)
 tri(110,130,120,88,130,130,13)
 for i=0,23,3 do
  line(120,88,120+sin(i/4+t/32)*32,88+cos(i/4+t/32)*32,1+i/6)
  line(120,88,120+sin(i/4+t/32+0.05)*32,88+cos(i/4+t/32+0.05)*32,2+i/6)
 end
 for i=0,100 do
  circ(120+sin(i/16)*32,88+cos(i/16)*32,2,14)
 end
 for i=0,12,1.8 do
  rect(119+sin(i/2+t/32)*32,84+cos(i/2+t/32)*32,2,10,15)
  rect(120-5+sin(i/2+t/32)*32,91+cos(i/2+t/32)*32,10,5,2)
  rect(120-5+sin(i/2+t/32)*32,84+cos(i/2+t/32)*32,10,2,2)
 end
 
 tri(24,30,38,130,40,30,3)
 tri(18,130,24,29,40,130,4)
 tri(18,130,40,30,46,130,4)
 rect(22,30,20,15,3)
 rect(19,44,26,3,2)
 rect(20,30,24,3,1)
 tri(24,30,32,20,40,30,4)
  
 for i=0,19 do
  circ(20+i/(2-i/16),58+i,2,2)
 end
 
 for i=0,19 do
  circ(20+i/(2-i/16),98+i,2,2)
 end
 
 line(190,20,190,125,13)
 line(200,20,200,125,13)
 
 for i=0,12 do
 line(190,20+i*8,200,30+i*8,13)
 end
 line(190,20,200,20,13)
  
 rect(180,126,30,2,14)
 
 for i=0,4 do
  rect(184+i*5,68+sin(t/24)*sin(t/32)*48,4,7,14)
 end
 rect(184,68+sin(t/24)*sin(t/32)*48,24,2,1)
 
end