-- ^
--tobach here!!
--greetz to newcomers luchak and jtruk
--and also gasman ofc :) <3
sin=math.sin
cos=math.cos
function TIC()
 cls(10)
 t=time()//32
 fv=fft(0)+fft(1)+fft(2)*12
 print(fv)
 
 for j=0,136,2 do
  for i=0,240,2 do
   sv=10+sin(i/16+cos(t/27)*6)*sin(j/16+sin(t/16)*6+sin(i/8+t/4)+sin(j/16)*2)
   pix(i,j,sv)
   pix(i+1,j,sv+1)
   pix(i,j+1,sv+1)
   pix(i+1,j+1,sv)

  end
 end
 
 rect(60,10,50,200,4)
 rect(50,10,100,10,13)

 rect(50,10,10,100,13)
 
 rect(140,10,10,100,13)
 
 for i=0,4 do
  rect(63+i*16,25,10,10,15)
 end 

 rect(8,32,180,80,15)
 rect(10,30,180,80,14)
 
 circ(50,70,25,13)
 circ(150,70,25,13)
 
 circ(50,70,17+fv/2,15)
 circ(150,70,17+fv/2,15)
 
 circb(50,70,5+fv/2,14)
 circb(150,70,5+fv/2,14)
 
 for i=0,3 do
  circ(60+i*13,8,7,4)
 end
 
 rect(80,60,40,20,13)
 
 line(100,79,100+sin(fv-1)*16,62,1)
 line(101,79,101+sin(fv-1)*16,62,2)
 
 circ(105,18,8,4)
 rect(160,50,80,100,2)
 for i=0,30 do
  line(120-i,110+i,190-i,110+i,2)
 end

 head(0+fv*2)
 
end

function head(y)
 
 circ(200,62+y,55,4)
 rect(148,42+y,80,3,15)
 rect(155,40+y,35,20,0)
 rect(205,40+y,35,20,0)
 rect(190,90+y,30,4,15)
 tri(190,80+y,200,60+y,200,80+y,3)
 
 
 for i=0,10 do
  circ(155+i*8,30-sin(i/4+0.2)*20+y,8,15)
 end
 
 rect(165,34+y+sin(t/2)*fv/2,20,3,14)
 rect(205,30+y+sin(t/2+1)*fv/2,20,3,14)
 
end