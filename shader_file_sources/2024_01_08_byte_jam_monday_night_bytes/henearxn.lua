cos=math.cos
sin=math.sin
rand=math.random
pi2=3.14159*2


function dist(x0,y0,x1,y1)
return math.sqrt((x1-x0)^2+(y1-y0)^2)
end

function li(x0,y0,x1,y1)
--line(x0,y0,x1,y1,11)
xa=x0
ya=y0
a=math.atan2(x1-x0,y1-y0)
s=sin(a)
c=cos(a)
p=0
color=math.random(4)
repeat
p=p+5
r=(math.random(2)-1)*3
x=x0+p*s+r*c
y=y0+p*c-r*s
line(xa,ya,x,y,9+color)--math.random(4))
xa=x
ya=y
until p>dist(x0,y0,x1,y1)-1
end
cls(0)
function TIC()t=time()//32
--Hi from HeNeArXn
--testing this fft thing...
-- ok, only fft later maybe :/
--cls()

inr=20+sin(t/33)^5*10+sin(t/33)^4*10
as=fft(0)+fft(1)+fft(2)+fft(3)+fft(14)
if as*1.5 <4.5 then
for i=0,900 do
 x=rand(120-60-15,120+60+15)
 y=rand(0,136)
 c=pix(x,y)
 if c>0 then
  if c==10 then c=1 end
	 pix(x,y,c-1)
	end
end
else
cls(0)
end
circ(120,136/2,inr,as/1.8)

vbank(1)
cls(0)

for i=0,10 do
	x=120+inr*cos(pi2/10*i+(t/10)%(pi2))
	y=136/2+inr*sin(pi2/10*i+(t/10)%(pi2))
	circ(x,y,5,10)
end

outr=60+sin(t/4)^2*15
for i=0,10 do
	x=120+outr*cos(pi2/10*i-(t/10)%(pi2))
	y=136/2+outr*sin(pi2/10*i-(t/10)%(pi2))
	circ(x,y,5,i)
end
vbank(0)

for i=0,as*1.5 do

a=math.random(0,10)
b=a+math.random(-2,2)
x1=120+inr*cos(pi2/10*a+(t/10)%pi2)
y1=136/2+inr*sin(pi2/10*a+(t/10)%pi2)
x0=120+outr*cos(pi2/10*a-(t/10)%pi2)
y0=136/2+outr*sin(pi2/10*a-(t/10)%pi2)
li(x0,y0,x1,y1)
vbank(1)
circ(x1,y1,6,12)
vbank(0)
end
vbank(1)
rect(0,0,as*15,136,as*1.5+0.5)
rect(240-as*15,0,240,136,as*1.5+0.5)
vbank(0)
--print(fft(0)+fft(1)+fft(2)+fft(3)+fft(14))
end

