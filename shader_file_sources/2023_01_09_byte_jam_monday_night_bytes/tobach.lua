sin=math.sin
cos=math.cos
abs=math.abs

stars={}
q=5

for i=0,100 do
stars[i]={math.random()*256,math.random()*160}
end

function TIC()
 t=time()//32
 
 --no clue what i want to make tonight
 --haha hmmmmmm....
 --big ups mantra, alia and gasman <3
 
 poke(0x3ffb,1)
 cls()
 
 for i=0,100 do
  pix((stars[i][1]+sin(t/16+i)*8),(stars[i][2]-(t*2*i/4)/10)%136,15-i/32)
 end
 
 rect(45,120,150,20,3)
 
 circ(70,108,30,4)

 circ(170,108,30,4)
 
 rect(70,0,100,136,13)
 
 rect(80,10,80,60,14)
 rect(85,15,70,50,5)
 
 for j=0,50 do
  for i=0,70 do
   sval=sin((i/4*sin(t/16))+sin(t/27)*16)*cos((j/4*sin(t/16))+cos(t/20)*8)+t//16
   pix(85+i,15+j,sval%3+5)
  end
 end
 
 for i=15,65 do
  q=sin(t/8+i/16)/2*8+10
  x1=sin(i/q+(t/50))*20+120
  x2=sin(i/q+90+(t/50))*20+120
  x3=sin(i/q+180+(t/50))*20+120
  if x1<x2 then line(x1,i,x2,i,5) end
  if x2<x3 then line(x2,i,x3,i,6) end
  if x3<x1 then line(x3,i,x1,i,7) end
 end
 
 hv1=sin(t/2+sin(t/7)*3)
 hv2=sin(t/2+sin(t/5+0.3)*3)
 
 for i=0,hv2+1 do
  circ(150,100-i,5,1+i)
 end
 
 circ(135,107,5,1)
 circ(135,106,5,2)

 rect(88,90,8,26,15)
 rect(79,99,26,8,15)
 
 print("FUNTENDO GAMEBOX",80,71,12,false,1,true)
 
 elli(75,105-abs(hv1*6),25,8,4)

 elli(170,98-abs(hv2*6),25,8,4)
 
 for i=0,6 do
  line(140+i*3,140-i*3,150+i*3,150-i*3,15)
 end
 
end
