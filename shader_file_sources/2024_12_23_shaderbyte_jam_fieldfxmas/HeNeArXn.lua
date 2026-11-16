-- hi everyone! HeNeArXn here
t=0
cos=math.cos
sin=math.sin
pi2=2*math.pi
pi=math.pi
text="XMAS BYTEJAM"

top=-1




function TIC()
vbank(0)
cls(6)
vbank(1)
poke(0x03FF8, 15)
for j=3,47 do
 poke(16320+j,sin(j+t/200)^2*255) 
end
cls(15)
a=40--+sin(t/130)*15
b=20-sin(t/150)*15
xc=240/2
yc=136/2
steps=1000
i=0
--x=cos(i+t/100)*a+sin(13*i)*b
--y=sin(i+t/100)*a-cos(13*i)*b
x=0
y=0
for ii=-1,steps do
i=pi2*ii/steps
x_=cos(i+t/100)*a+sin(13*i)*b
y_=sin(i+t/100)*a-cos(9*i+cos(t/40)*4)*b
if ii>0 then
line(x+xc,y+yc,x_+xc,y_+yc,0)
end
if ii%10==0 then
for it=0,3 do
 circ(x_+xc,y_+yc+3+2*it,3-it,(ii/10)%14+1)
end
end

x=x_
y=y_

end
 
--	for x=0,239 do
--	 for y=0,135 do
--		pix(x,y,((x//10+y//10)%2)*4+2)
--		end
--	end

--for y=100+top,240,5 do
-- print(string.rep("snow",10),0,y,12,0,1)
--end

--for x=0,239 do
--line(x,135,x,120+sin(x/40)*15-cos(x/100)*20,12)
--line(x,0,x,120+sin(x/40)*15-cos(x/100)*20,0)
--end

--y=126+top-6
--print("trunk",100,y,2)
--print("trunk",100,y+5,2)

--print(text,15,100+sin(t/30)*20,12,0,3)
t=t+1

end
