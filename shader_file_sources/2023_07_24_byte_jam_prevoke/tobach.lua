-- ^
--tobach here!! evoke is this weekend!!
--greetz to alia =^^=, superogue,
--aldroid and violet! <3

--since this jam is evoke themed
--i have a cool idea of what to make
--this week, let's hope it works out!!

clouds={}
builds={}

for i=1,25 do
 clouds[i]={math.random()*256,math.random()*128,math.random()*8+4}
end

for i=1,400 do
 builds[i]=math.random()*40+10
end

sin=math.sin
text="EVOKE 2023   28-30TH JULY   KOLN, GERMANY   DEMOS, SEMINARS, FRIENDS, KOLSCH AND CURRYWURST    BRING YOUR MATES!"
function TIC()
 cls(10)
 t=time()/50
 
 cloudsinnit(-60+sin(t/32)*64)

 rect(0,150+sin(t/32)*64,240,20,13)
 rect(0,170+sin(t/32)*64,240,80,6)
 
 buildpos=t/2%250
 
 for i=1,400 do
  rect((i*8-buildpos*10),150-builds[i]+sin(t/32)*64,8,1+builds[i],14)
 end
 
 sign(190-t*8%680,80+sin(t/32)*64)
 
 --plaen :)
 rect(45,68,146,18,12)
 rect(45,86,146,2,8)
 tri(20,68,45,68,45,70+18,8)
 tri(20,68,45,68,45,68+18,12)
 for i=0,2 do
  circ(190+i*6,76,8-i,12)
 end
 for i=0,15 do
  rect(54+i*8,74,4,6,15)
 end
 rect(198,72,10,4,15)
 --bloody maths!!!!
 tri(88,77,88,82,140,84,13)
 tri(68+20,64,68+20,79,78+20,79,9)
 rect(94,84,18,7,9)
 rect(98,82,10,10,14)
 tri(20,50,25,68,40,68,8)
 rect(76,88,3,10,14)
 rect(176,88,3,10,14)
 circ(78,95,3,15)
 circ(178,95,3,15)
 
 for i=1,4 do
  drawtext(230-t*10%2500+i,20+i,i)
 end
end

function sign(x,y)
 rect(66+x,40+y,50,30,2)
 rect(68+x,43+y,46,24,12)
 rect(68+x,70+y,6,14,2)
 rect(108+x,70+y,6,14,2)
 print("..",80+x,39+y,1,false,2)
 print("KOLN",68+x,50+y,1,true,2)
end

function cloudsinnit(y)
 for i=1,25 do
  for j=1,clouds[i][3] do
   circ((clouds[i][1]+j*2-1-(t/2)*i)%256,y+clouds[i][2]-1,5,13)
   circ((clouds[i][1]+j*2-(t/2)*i)%256,y+clouds[i][2],5,12)
  end
 end
end

function drawtext(x,y,cl)
 for i=1,#text do
  c=text:sub(i,i)
  print(c,x+i*18,y+sin(i/2+t/2)*8,cl,true,3)
 end
end