-- hello bytejammers
-- greeting to jammers and watchers
-- vurpo

m=math
i=m.floor

xv=0
yv=0

G=0.05
c={
 {x=70,y=50,xv=1.5,yv=0,r=16,c=12},
 {x=200,y=60,xv=-0.9,yv=0,r=17,c=12},
 {x=20,y=100,xv=0.2,yv=0,r=15,c=12},
 {x=26,y=50,xv=-0.5,yv=0,r=12,c=12},
 {x=50,y=60,xv=1,yv=0,r=22,c=12},
 {x=12,y=20,xv=1.6,yv=0,r=10,c=12},
 {x=130,y=100,xv=1.1,yv=0,r=11,c=12}
}

function int(c1,c2)
 return m.sqrt(
  m.pow(c2.x-c1.x,2)+
  m.pow(c2.y-c1.y,2))
  <c1.r+c2.r
end

function norm(x,y)
 return 
  x/m.sqrt(m.pow(x,2)+m.pow(y,2)),
  y/m.sqrt(m.pow(x,2)+m.pow(y,2))
end

function dot(x1,y1,x2,y2)
 return x1*x2+y1*y2
end

function r(x,y,nx,ny)
 d=dot(x,y,nx,ny)
 return x-2*d*nx, y-2*d*ny
end

function drawc()
 for _,c in pairs(c) do
  circ(c.x,c.y,c.r,c.c)
 end
end

function updatec()
 for i=1,#c-1 do for j=i+1,#c do
  if int(c[i],c[j]) then
   nx,ny=norm(
    c[i].x-c[j].x,
    c[i].y-c[j].y
   )
   c[i].x=c[i].x+nx
   c[i].y=c[i].y+ny
   c[j].x=c[j].x-nx
   c[j].y=c[j].y-ny
   c[i].xv,c[i].yv=r(c[i].xv,c[i].yv,nx,ny)
   c[j].xv,c[j].yv=r(c[j].xv,c[j].yv,-nx,-ny)
  end
 end end 
	for i=1,#c do
	 if c[i].y>136-c[i].r then
	  c[i].yv=-m.abs(c[i].yv)
			c[i].y=136-c[i].r
	 elseif c[i].y<0+c[i].r then
		 c[i].yv=m.abs(c[i].yv)
			c[i].y=0+c[i].r
		else
	 	c[i].yv=c[i].yv+G
	 end
		
	 if c[i].x<0+c[i].r then
	  c[i].xv=m.abs(c[i].xv)
			c[i].x=0+c[i].r
	 elseif c[i].x>240-c[i].r then
	  c[i].xv=-m.abs(c[i].xv)
			c[i].x=240-c[i].r
	 end
	 
	 c[i].x=c[i].x+c[i].xv-xv
	 c[i].y=c[i].y+c[i].yv-yv
	end
end

function TIC()
 t=time()//8
 f=m.max(0,(fft(1)+fft(2)+fft(3)-1.0)*3.5)
 yv=m.cos(t)*f
 xv=m.sin(t)*f
 cls(16)
	
	updatec()
	drawc()
	
	--for x=-1,1 do for y=-1,1 do
		--print("vurpo",10+x,10+y,12)
	--end end
	--print("vurpo",10,10,16)
end
