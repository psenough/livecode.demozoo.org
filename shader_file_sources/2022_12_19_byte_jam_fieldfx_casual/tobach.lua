--hello!!! :)
--greetz to kii, synackster and superogue <3

sin=math.sin
cos=math.cos
abs=math.abs
flr=math.floor

chars={" ",".","o","#",";","&","#","@"}

scr = {}
for i=0,17 do
 scr[i]={}
 for j=0,15 do
  scr[i][j]=0
 end
end

function TIC()
 cls()
 
 for i=-20,156 do
  line(0,i+sin(time()/400)*16,240,i-sin(time()/400)*16,i/16+sin(time()/1600)*32)
 end
 
 rect(48,10-10,140,120,15)
 for i=1,4 do
  rectb(48+i,10+i-10,140-i*2,120-i*2,14)
 end
 
 circ(68,30-10,8,7)
 circ(168,30-10,8,7)
 
 circ(68,110-10,8,7)
 circ(168,110-10,8,7)
 
 rect(60,30-10,117,80,7)
 
 rect(70,22-10,97,97,7)
 
 for i=1,17 do
  for j=1,15 do
   rndval=math.random(8)
   --error in my maths means 2/8 chars is shown lol...
   --my head hurts, 4-5/8 ain't bad right lol
   pxval=flr(sin((i/8)+sin(time()/1200+j/16)*8)*cos(j/4+sin(time()/900+j/16)+sin(i/4))*3+4)
   scrpix(i,j,pxval%7)
   print(scr[i][j],62+i*6,20+j*6-10,7-math.random(2))
  end
 end
 
 line(60,17+time()/10%84,176,17+time()/10%84,7-math.sin(time()/100)*1)
 
 rect(20,120,200,30,14)
 for i=1,18 do
  rect(20+i*10,122,8,8,13)
  rect(15+i*10,132,8,8,13)
 end
 yval=abs(sin(time()/60)*32)
 yval2=abs(sin(time()/50+1)*32)
 xval=math.sin(time()/150)*24+16
 xval2=math.sin(time()/150+1)*24+16
 for i=1,24 do
  line(50+i+xval,130-yval,30+i,200,1)
 end

 for i=1,24 do
  line(160+i-xval2,130-yval2,170+i,200,1)
 end
 
 circ(65+xval,130-yval,14,4)
 circ(170-xval2,130-yval2,14,4)
 
end

function scrpix(x,y,val)
 scr[x][y]=chars[val]
end