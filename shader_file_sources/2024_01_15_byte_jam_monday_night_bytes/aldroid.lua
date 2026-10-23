-- aldroid here!

-- hey everyone! glhf and love a bit
-- of dnb thank you polynomial!

-- <3
cls(0)
s=math.sin
c=math.cos

function TIC1()t=time()/32
clip(0,0,240,68)
circb(120,68,60,fft(20)*90)
for x=-120,120 do for y=-68,0 do
a=math.atan2(y,x)
r=(x^2+y^2)^0.5
pix(x+120,y+68,
 pix(
   -(r-1)*math.cos(a)+120,
   (r-1)*math.sin(a)+68))
 

end end
pix(120+math.sin(t)*20,40+math.cos(t)*20,12)
clip()
rect(0,69,240,135,0)
for x=-19,19 do for y=0,9 do
Z=y+2-t%2
X1=x/Z
X2=(x+1)/Z

ffti1=x+19
ffti2=x+20
Y1=fft(x+19)*(1+ffti1)+2/Z
Y2=fft(x+20)*(1+ffti2)+2/Z

line(120+X1*10,68+Y1*10,
     120+X2*10,68+Y2*10,4)
end end
end


function TIC2()
t=time()/230%6.28
u=time()/400%1+1
v=time()/1400
for i =0,200 do
  circ(120+20*c(v)+c(i/2+t)*i/2*u,
  68+20*s(v)+s(i/2+t)*i/2*u,2,fft(i)*100)
end
end

function TIC()
if time()%6000 < 4000 then
 TIC1()
else
 TIC2()
end
end
