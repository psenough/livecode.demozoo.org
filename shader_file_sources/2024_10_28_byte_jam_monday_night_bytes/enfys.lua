--beep boop enfys
sin=math.sin
cos=math.cos
stars={}
for i=1,100 do
 stars[i]={math.random()*240,math.random()*135}
end

txt="Trick Or Treat!!"

function TIC()
 cls(8)
 t=time()/100
 for i=1,100 do
  pix((stars[i][1]+t/8)%240,stars[i][2],4)
 end
 mwn(80,-50)

 rect(0,110,240,40,7)
 rect(0,90,240,30,14)
 
 for i=-2,8 do
  line(0+i*32+(t)%32,90,0+i*32+(t)%32,119,15)
 end

 for i=-4,8 do
  house(i*56+t/1.5%56,0)
 end

 char1(-40+sin(t/6+2)*2,4+sin(t/7)*2)
 char2(40+sin(t/7)*2,8+sin(t/6+2)*2)

 rect(18,114,200,20,12)
 tri(25,114,64,92,38,124,12)

 tri(185,114,174,100,219,124,12)
 
 for i=1,#txt do
  s=txt:sub(i,i)
  print(s,10+i*12,120+sin(i/2+t)*2,15,true,2)
 end

end

function house(x,y)
 rect(80+x,18,50,72,15)
 tri(70+x,18,80+25+x,1,90+50+x,18,15)
 circ(104+x,28,8,4)
 line(104+x,18,104+x,38,15)
 line(94+x,28,114+x,28,15)
 rect(90+x,48,30,15,4)
 line(104+x,48,104+x,68,15)
 line(90+x,55,119+x,55,15)
 rect(99+x,72,11,18,4)
end

function mwn(x,y)
 circ(120+x,68+y,15,13)
 circ(110+x,68+y,4,14)
 circ(124+x,68+y,5,14)
 circ(118+x,62+y,7,14)
 circ(124+x,78+y,5,14)
end

function char2(x,y)
 rect(113+x,85+sin(t+1)*2+y,6,14,4)
 rect(122+x,85-sin(t+1)*2+y,6,14,4)
 rect(120+x,95-sin(t+1)*2+y,8,4,13)
 rect(111+x,95+sin(t+1)*2+y,8,4,13)

 rect(131+x,88+y,8,6,15)
 rectb(131+x,82+y,8,6,15)

 for i=-24,2 do
  circ(120+cos((2*math.pi)*i/48)*16+x,80+sin((2*math.pi)*i/48)*10+y,2,4)
 end 

 circ(120+x,68+y,13,12)
 rect(107+x,68+y,27,20,12)
 for i=0,4 do
  circ(110+x+i*5,88+y,2,12)
 end
 
 elli(110+x,68+y,1,3,15)
 elli(114+x,68+y,1,3,15)
 
end

function char1(x,y)
 rect(113+x,85+sin(t)*2+y,6,14,4)
 rect(122+x,85-sin(t)*2+y,6,14,4)
 rect(120+x,95-sin(t)*2+y,8,4,3)
 rect(111+x,95+sin(t)*2+y,8,4,3)

 rect(136+x,92+y,8,6,15)
 rectb(136+x,86+y,8,6,15)

 for i=-24,2 do
  circ(120+cos((2*math.pi)*i/48)*20+x,84+sin((2*math.pi)*i/48)*10+y,2,4)
 end 

 elli(120+x,80+y,15,10,3)
 tri(120+x,78+y,125+x,73+y,130+x,78+y,15)
 tri(110+x,78+y,115+x,73+y,120+x,78+y,15)
 for i=0,2 do
  tri(110+i*5+x,83+y,115+i*5+x,88+y,120+i*5+x,83+y,15)
 end
 rect(116+x,63+y,9,7,4)
 elli(120+x,62+y,10,2,3)
 
 circ(117+x,67+y,1,15)
 circ(121+x,67+y,1,15)
end