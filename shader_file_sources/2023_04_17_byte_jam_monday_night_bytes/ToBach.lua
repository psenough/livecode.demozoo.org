-- ^
--tobach here!!!
--this is going to be an absolute blast
--greetz to synackster, alia, dave,
--nusan, jtruk, mantratronic,
--kii and superogue!! :) <3

sin=math.sin
cos=math.cos

function SCN(scnln)
 if scnln>100 then 
  poke(0x3ff9,sin(t/2+scnln/2)*2)
 else
  poke(0x3ff9,0)
 end
end

function TIC()
 t=time()/100
 cls(10)
 
 flower(280-t*8%390,88,1,1)
 flower(420-t*8%600,68,3,2)
 flower(320-t*8%500,58,8,3)
 flower(490-t*8%540,48,12,4)
 
 bee(40+sin(t/4)*8,0+sin(t/3)*8)
 bee2(10+sin(t/4+1)*4,0+sin(t/3+1)*4)
 bee2(-20+sin(t/4+2)*4,0+sin(t/3+2)*4)
 bee2(-50+sin(t/4+3)*4,0+sin(t/3+3)*4)
 
 grass(0-(t*12)%124+18,10,2)
 grass(0-(t*12)%124+9,4,1)
 grass(0-(t*12)%124,10,0)
 
 scroller("Don't worry bee happy :)",240-t*10%540,10,0)
end

function bee(x,y)
 circ(x+110,y+68,10,4)
 circ(x+133,y+68,10,4)
 for i=0,8 do
 rect(x+108+i*3,y+58,3,21,i%2*4)
 end
 circ(x+140,y+65,3,12)
 circ(x+141,y+65,2,0)
 elli(x+116,y+58,10,sin(t*6)*6,14)
 elli(x+128,y+58,10,sin(t*6)*6,13)
end

function bee2(x,y)
 circ(x+110,y+68,8,4)
 circ(x+117,y+68,8,4)
 for i=0,3 do
 rect(x+108+i*3,y+60,3,17,i%2*4)
 end
 circ(x+120,y+65,3,12)
 circ(x+121,y+65,2,0)
 elli(x+110,y+60,4,sin(t*6)*3,14)
 elli(x+115,y+60,4,sin(t*6)*3,13)
end

function flower(x,y,c,o)
 for i=0,20 do
  circ(x+sin(i/4+sin(t/2+1+o))*4,y+i*4,5,7)
 end
 for i=0,5 do
  circ(x+sin(i+sin(t/2+o)/4)*16,y+cos(i+sin(t/2+o)/4)*16,10,c)
  circb(x+sin(i+sin(t/2+o)/4)*16,y+cos(i+sin(t/2+o)/4)*16,10,c+1)
 end
 circ(x,y,10,4)
 circb(x,y,10,3)
end

function grass(x,y,c)
 for i=0,200 do
  tri(x+0+i*5+sin(i/4)*8,y+136,x+5+i*5+sin(i/4)*8+sin(t/3)/3,y+90,x+8+i*5+sin(i/4)*8,y+136,5+c)
 end
end

function scroller(text,x,y)
 for i=1,#text do
  c=text:sub(i,i)
  for j=0,2 do
   print(c,x+i*12+j,y+j+sin(i+t)*4,14-j,true,2)
  end
 end
end