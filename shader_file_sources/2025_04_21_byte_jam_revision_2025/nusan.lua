r=math.random
s=math.sin
flr=math.floor

function SCN(y)
p=0x3FC0
for k=0,47 do
	if k<45 then
		poke(p+k,16*(s(k%3-t*0.01+y/30)*0.5+0.5+(k+flr(t/10))%5*0.1)*k/3)
	else
		poke(p+k,255)
	end
end
end

function lin(ax,ay,bx,by,c)
	line(ax,ay,bx,by,c)
	l=r()
	for i=0,5 do
	
		local s=80
		rx,ry=(r()-0.5)*s,(r()-0.5)*s
		jx,jy=ax*l+bx*(1-l),ay*l+by*(1-l)
		if(i==0) then nx,ny=jx,jy end
		jx,jy=jx+rx,jy+ry
		line(jx,jy,nx,ny,c)	
		nx,ny=jx,jy
	end
end

cls()
function TIC()
t=time()/32


for i=1,800 do
	--circb(r(240),r(136),r(2),0)
	for j=1,10 do
		x,y=r(240)-5+j,r(136)-5
		of=r(10)
		v=pix(x,y)
		pix(x,y+of,v*0.9)
	end
end

for i=1,3 do
	--circ(r(240),r(136),r(5),3)
end

if r(10)<2 then
	for i=1,3 do
		--circ(r(240),r(136),r(50),5)
	end
end

lx,ly=240,50
for j=0,3 do
	px,py,b=200-50*j,136/2,10
	for i=1,100 do
	 f=i/100.0+j*0.3
	 d=b*0.1
		px=px+s(t*0.2+f*4)*d
		py=py+s(t*0.13+f*0.3)*d
		b=b*0.98
		circ(px,py,b,8-f*30+t)
	end
	circ(px,py,5,12)
	lin(px,py,lx,ly,15)
	lx,ly=px,py
end
lin(0,50,lx,ly,15)

--for y=0,136 do for x=0,240 do
--pix(x,y,(x+y+t)>>3)
--end end 
end
