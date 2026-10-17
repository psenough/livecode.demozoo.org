--ello !!!
--yet another jaaammmm
--greetz to jtruk, catnip, pumpuli and
--realityyyy
sin=math.sin
cos=math.cos
startab={}
sprinkletab={}
for i=1,8 do
 startab[i]={math.random()*256,math.random()*136,math.random()*8}
end

for i=1,32 do
 sprinkletab[i]={math.random()*60,math.random()*36}
end

function TIC()
 cls(9)
 t=time()//32
 for i=1,#startab do
  drawstar((startab[i][1]-t*i/2)%256,startab[i][2],startab[i][3])
 end
 drawrainbow(-cos(t/4+0.6)*4//1)
 drawfeet(0,-cos(t/4+0.6)*4//1)
 drawbody(sin(t/4+0.6)*4//1,10-cos(t/4+0.6)*4//1)
 drawhead(20+sin(t/4)*4//1,-25-cos(t/4)*4//1)

 for i=0,2 do
  print("NYA NYA NYA NYA NYA",0-t*6%72+i,4+i,14-i,true,3)
  print("NYA NYA NYA NYA NYA",-72+t*6%72+i,112+i,14-i,true,3)
 end
end

function drawrainbow(y)
 for j=0,15 do
  for i=1,8 do
   circ(0+j*8,y+50+i*3+sin(j/2+t/4)*8,4,i+t/4)
  end
 end
end

function drawfeet(x,y)
 for i=0,1 do
  rect(90+sin(t/4+0.4)*8,78+y,8,22,13)
  rect(110+sin(t/4+0.6)*8,78+y,8,22,13)
 end
 for i=0,1 do
  rect(130+sin(t/4+0.6)*6,88+y,8,12,13)
  rect(150+sin(t/4+0.8)*6,88+y,8,12,13)
 end
 
 rect(76+sin(t/4+0.6)*4//1,68+sin(t/4)*4,12,4,13)
 
end

function drawbody(x,y)
 rect(90+x,28+y,70,50,4)
 rect(86+x,32+y,78,42,4)
 rect(94+x,32+y,62,42,3)
 rect(90+x,36+y,70,34,3)
 for i=1,#sprinkletab do
  rect(x+96+sprinkletab[i][1],y+34+sprinkletab[i][2],4,4,1+i%2)
 end
end

function drawstar(x,y,off)
 rect(x,y,2,2,12)
 rect(x,y-(t%12),2,2,12)
 rect(x,y+(t%12),2,2,12)
 rect(x+(t%12),y,2,2,12)
 rect(x-(t%12),y,2,2,12)
end

function drawhead(x,y)
 tri(110+x,68+y,110+x,82+y,125+x,82+y,13)
 tri(150+x,68+y,150+x,82+y,135+x,82+y,13)
 rect(108+x,82+y,44,25,13)
 rect(110+x,98+y,40,12,13)
 circ(122+x,90+y,4,15)
 circ(140+x,90+y,4,15)
 circ(120+x,88+y,1,12)
 circ(138+x,88+y,1,12)
 
 circ(123+4+x,100+y,4,14)
 circ(130+4+x,100+y,4,14)
 circ(122+4+x,98+y,3,13)
 circ(131+4+x,98+y,3,13)
 
 circ(114+x,98+y,4,2)
 circ(146+x,98+y,4,2)

end