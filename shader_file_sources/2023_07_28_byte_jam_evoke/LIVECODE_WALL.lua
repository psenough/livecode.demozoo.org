
--LIVECODING WALL
--CTRL+R to run
--ESC to stop running

t=1
S=math.sin
C=math.cos

function W(a,j,k)
	b=a+math.pi/2
	for i=-12,12 do
		p=i*4
		z=math.abs(i)-j+5
		
		x=p*C(a)
		y=p*S(a)
		circ(120+x,68+y,z,k)
		
		x=p*math.cos(b)
		y=p*math.sin(b)
		circ(120+x,68+y,z,k)
	end
end

-- Genuine Tobach Grass
function grass(y)
	for i=0,240 do
		line(0+i,100+S(i)*10+y,0+i,135+y,7)
		line(0+i-3+S(time()/500+i)*2,110+S(i)*10+y,0+i,135+y,6)
	end
end

function TIC()
t=t+1
cls()
P=math.sin(t/64)+2
for y=0,136,2 do 
for x=0,240,2 do
xx=x-120
yy=y-68.1
z=(xx*xx+yy*yy)/999
X=(xx+yy)/z
X=(xx+yy)/z
X=(xx+yy)/z

Y=(xx-yy)/z
c=(X+math.sin(t/64)*28)//P&(Y+math.sin(t/57)*39)//P
pix(x,y,8-(c&z//1)%4)

end end

grass(0)
elli(120,136,25,85,t/25+1)
elli(124,136,22,82,t/25)
W(t/16,0,2)
W(t/16,3,12)
circ(120,68,8,t/25+2)
circ(120,68,6,t/25+10)
circ(120,68,4,t/25+2)

tx=S(t/4)*2
ty=S(t/6)*3
print("welcome to evoke 2023",61+tx*100,7+ty,0)
print("welcome to evoke 2023",60+tx*10,60+ty*10,10+(t/32%4))

sheep(tx,0)
sheep(-170+tx,10)

sheep(35+tx,10)
sheep(-125+tx,15)

end

function sheep(x,y)

dx=180
dy=100

turned = math.floor((t/80)%2)
elli(dx+10+x -(turned),dy+8+y,8,6,12)
elli(dx+x + (turned * 19),dy+6+y,2,4,1)
rect(dx+4+x,dy+13+y,2,6,1)
rect(dx+14+x,dy+13+y,2,6,1)

letter_spacing=10
for d=0,100,letter_spacing do
 letter="A"
 if d==0 then
  letter="B"
 end
 print(letter,
  x+dx+d+math.sin(t/10+d/10)*10+10,
  y+dy-d-10,
  10)
end

end