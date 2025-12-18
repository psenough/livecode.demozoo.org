--greetingz!! crimbo jam time
--greetz to gasman, nico, alia
--aldroid, suule and violet :3

snow={}
sin=math.sin
cos=math.cos
flr=math.floor
for i=1,200 do
 snow[i]={math.random()*120,math.random()*120}
end
function TIC()
 cls()
 t=time()/100 

 rect(64,90,120,64,12)
 for i=-16,16 do
  elli(120+i*4,88+sin(i/3+1)*sin(i/7)*8,6,5+sin(i/3)*4+8,12)
 end

 rect(107,68,8,11,1)
 for i=0,4 do
  tri(95+i*2,68-i*8,109,50-i*8,124-i*2,68-i*8,7)
 end
 for i=0,20 do
  circ(110+sin(i)*i/2,25+i*2,1,t+i)
 end
 circ(109,17,1,4)
 
 for i=0,2 do
  circ(90,78-i*10,9-i*2,12)
  circb(90,78-i*10,9-i*2,13)
 end
 rect(85,52,11,2,15)
 rect(87,44,7,8,15)
 line(87,50,93,50,2)
 line(90,58,93,59,3)
 line(82,67,78,60,1)
 line(98,67,102,60,1)
 
 for i=0,38 do
  line(114+i,56,124+i,40,i%4)
 end
 rect(124,48,44,30,1)
 rect(124,44,16,34,2)
 for i=0,38 do
  line(134+i,56,124+i,40,i%4)
 end
 rect(128,66,6,12,1)

 for i=1,200 do
  pix((snow[i][1]+sin(t/4+i))%120+60,(snow[i][2]+t*(i/2+1)/32)%120,12)
 end
 cols={7,2,12,2}
 text="MERRY XMAS"
 for i=0,132 do
  circb(120,58,190-i,cols[flr(i/8+t/8)%4+1])
  circb(120+1,58,190-i,cols[flr(i/8+t/8)%4+1])
 end
 --bugger it i'll figure out the base
 --later on :)
 for i=-46,46 do
  line(120+i,102+sin(i/23+1.6)*16,120+i,130+sin(i/22+1.6)*4,1)
 end
 for i=1,#text do
  c=text:sub(i,i)
  print(c,84+i*6,115+sin(i/4+0.2)*8,4)
 end
 for i=0,2 do
  circb(120,58,58-i,13)
  circb(120-1,58,58-i,13)
 end
 for i=2,9 do
  circ(100+40-sin(i/8-1.6)*24,82-40-cos(i/8-1.6)*24,2,12)
 end
end