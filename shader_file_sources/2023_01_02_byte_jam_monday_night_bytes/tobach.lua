--yeeeee hawwww ;)
--hello!!!
--greetz to kii, alia and mantra <3

sin=math.sin
cos=math.cos

fdir=0

function SCN(scnln)
 poke(0x3ff9,sin(t/4+scnln/4)*1.1)
end

function TIC()
 cls(14)
 t=time()//32
 
 fx=60+sin(t/32)*64
 fy=sin(t/2)*2
 
 --need a "diorama"... hmmmmmm
 --i have an idea :)
 
 rect(0,110,240,40,4)
 rect(0,20,240,80,10)
 
 circ(120,95,20,9)
 tri(100,90,105,70,120,80,9)
 tri(110,90,135,70,140,90,9)
 
 circ(110,85,5,11)
 circ(130,85,5,11)
 
 circ(85,90,6,9)
 
 for i=0,10 do
  circ(85+i,90+i*2,4,9)
 end
 
 circ(155,90,6,9)
 
 for i=0,10 do
  circ(155-i,90+i*2,4,9)
 end

 for i=1,4 do
  circ(78+i*2.4,92-i*1.75,1,10)
 end
 
 circ(87,92,2,10)
 
 for i=1,4 do
  circ(150+i*2.5,84+i*1.25,1,10)
 end
 
 circ(153,92,2,10)
 
 elli(110+fx/32-1,85,1,5,10)
 elli(130+fx/32-1,85,1,5,10)
 
 rectb(-2,20,244,100,12)
 rect(-2,20,244,10,15)
 rectb(-2,20,244,10,13)
 
 --print(fx)
 --fishrev(0,0,3)
end

function OVR()
 --fish(0+sin(t/128)*64,0+sin(t/2)*2,3)
 
 for i=-5,5 do
  line(200+i*4,80+sin(t/16+i/2)*4,200,110,7)
  line(200+i*4+1,80+sin(t/16+i/2)*4,200,110,6)
 end
  
 for i=0,3 do
  rect(31+i*7.8,65,5,5,14)
 end
 
 rect(30,70,30,30,14)


 rect(40,85,10,15,15)
 circb(45+sin(t/8)*4,97-t*2%60,1,11)
 
 if fx>122 then
  fdir=1
 end
 if fx<-3 then
  fdir=0
 end
 
 if fdir==0 then
  fish(fx,fy,3)
  circb(60+fx+sin(t/2)*2,85+fy-t%40,1,11)
 elseif fdir==1 then
  fishrev(fx,fy,3)
  circb(50+fx+sin(t/2)*2,85+fy-t%40,1,11)
 end
 
 for i=0,18 do
  line(0,100+i,240,100+i,4-i/8)
 end
  
end

function fish(x,y,col)
 --our tank needs a friend :)
 tval=sin(t/4)*3
 tri(x+40-tval,y+80,x+50,y+85,x+40-tval,y+90,col)
 trib(x+40-tval,y+80,x+50,y+85,x+40-tval,y+90,col+1)
 elli(x+55,y+85,8,6,col)
 ellib(x+55,y+85,8,6,col+1)
 circ(x+60,y+82,1,15)
end

function fishrev(x,y,col)
 --our tank needs a friend :)
 tval=sin(t/4)*3
 tri(30+x+40+tval,y+80,30+x+30,y+85,30+x+40+tval,y+90,col)
 trib(30+x+40+tval,y+80,30+x+30,y+85,30+x+40+tval,y+90,col+1)
 elli(30+x+25,y+85,8,6,col)
 ellib(30+x+25,y+85,8,6,col+1)
 circ(30+x+20,y+82,1,15)
end