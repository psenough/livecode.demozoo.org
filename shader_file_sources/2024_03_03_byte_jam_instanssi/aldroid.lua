-- pos: 0,0
-- aldroid here - hello instanssi!
a=0
S=math.sin
C=math.cos
P=math.pi
cls()

function xfft(i)
return ((1+C(t*2.4))/2)^0.5
end

cols = {}
for i=0,47 do
cols[i]=peek(0x3fc0+i%4+8)
end

function SCN(l)
if clr then 
for i=0,47 do
poke(0x3fc0+i,cols[i])
return
end
end
u=l<co and 1 or 0.5+fft(5)
l=math.abs(l-co)
if l < 40+S(time()/1200)*80 then 

for i=0,47 do
poke(0x3fc0+i,cols[i])
end
return end
for i=0,15 do
poke(0x3fc0+3*i,cols[i*3+0]^0.4+l+60+u*10)
poke(0x3fc1+3*i,cols[i*3+1]*0.1+l)
poke(0x3fc2+3*i,cols[i*3+2]*u+l+u*10)
end
end

co=0

function TIC1()t=time()/320


-- hello instanssi! it is late and
-- i have no brain. but i hope you
-- are having a brilliant party.
-- so much gratitude for all the 
-- sick demos and stuff you have
-- been making and showing today <3
 -- if at first you don't succeed...
 -- ... do something else ig
 co = S(t/31+fft(1))*80+60
 
 clip(0,68+co,239,135-160)
 cls(14)
 for i=0,13 do
  arc1 = i*2*P/13+t
  arc2 = (i+1)*2*P/13+t
  tri(
  120+co+C(arc1)*220,68+S(arc1)*220,
  120+co+C(arc2)*80,68+S(arc2)*80,
  120,68,
  i%4+11)
 end
 clip()
 for i=0,10 do
  x=S(i*P*2/10)
  y=0
  z=C(i*P*2/10)
  x1=x*C(t)+z*S(t)
  y1=y
  z1=z*C(t)+x*S(t)
  x2=x1
  y2=y1*C(t/13)+z1*S(t/13)
  z2=z1*C(t/13)+y1*S(t/13)
  circ(120+100*x2,68+100*y2,5+4*z2,1+fft(1+i)*200)
 end
 
 circ(120,68,2+fft(2)*50,12)
 if fft(1) > 0.05 then
 mg = "INSTANSSI ROCKS"
 a=print(mg,120-a/2,64,15)
 end
 for x=0,240,2 do for y=20,68 do
  ox1=math.random(0,2)
  ox2=math.random(0,2)
  p1=pix(ox1+x,66-y)
  pix(ox2+x,68+co-y,p1)
  p2=pix(ox1+x,70+y)
  pix(ox2+x,68+co+y,p1)
 end end
end
b=0
clr=false

function TIC2()


circ(120,68,60,4)
clip(120,0,240,68)
circb(120,68,40,0)
clip()
circ(92,67,4,0)
circ(116+6*C(fft(1)*10),90+S(fft(1)*10)*6,8,0)

end
function TIC3() 
d=(time()%1200//600)*3-2
for x=1,238 do
for y=0,135 do
pix(x,y,pix(x+d,y))
end end
end

function TIC()
bigtime = time()%9000
clr = bigtime<3000



if clr then

TIC1()
elseif bigtime < 6000 then
 circ(120,68,2+fft(12)*550,fft(1)*50)
t=time()//230
xp=S(t+time())*80
yp=C(t*t+0.3*time())*80
rect(120-b/2-xp-2,62+yp,b+4,12,3)
b=print("INSTANSSI ROCKS",120-b/2-xp,64+yp,12)
elseif bigtime < 700 then
TIC2()
else
TIC3()
end
if math.random() < 0.1 then
newcol = {}
for i=0,47 do
newcol[i]=cols[(i+1)%47]
end
cols= newcol
end


sqx=120+C(t//3)*120

rect(sqx-10,0,20,135,0)

end
