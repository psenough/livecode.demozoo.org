cos=math.cos
sin=math.sin
p={
{x1=-20,y1=20,x2=20,y2=20,c=3},
{x1=20,y1=20,x2=20,y2=-20,c=3},
{x1=20,y1=-20,x2=-20,y2=-20,c=3},
{x1=-20,y1=-20,x2=-20,y2=20,c=3},
}
t1={
{x=-50,y=50},
{x=0,y=50},
{x=50,y=50},
{x=-50,y=0},
{x=50,y=0},
{x=-50,y=-50},
{x=0,y=-50},
{x=50,y=-50},
}
t2={
{x=0,y=0},
--{x=-100,y=50},
--{x=-100,y=0},
--{x=-100,y=-50},
--{x=100,y=50},
--{x=100,y=0},
--{x=100,y=-50},
}
t=0
a=0
function rot(x1,y1,x2,y2,a)
	nx1 = x1*cos(a)-y1*sin(a)
	ny1 = x1*sin(a)+y1*cos(a)
	nx2 = x2*cos(a)-y2*sin(a)
	ny2 = x2*sin(a)+y2*cos(a)
	return {nx1,ny1,nx2,ny2}
end
function TIC()
	t=t+1
	a=t/40
	cls()
	for _,v in ipairs(p) do
		for _,w in ipairs(t1) do
			nv = rot(v.x1,v.y1,v.x2,v.y2,-a)
			nv[1]=nv[1]+w.x
			nv[2]=nv[2]+w.y
			nv[3]=nv[3]+w.x
			nv[4]=nv[4]+w.y
			nv = rot(nv[1],nv[2],nv[3],nv[4],a/2)
			nv[1]=nv[1]+120
			nv[2]=nv[2]+68
			nv[3]=nv[3]+120
			nv[4]=nv[4]+68
			line(nv[1],nv[2],nv[3],nv[4],(v.c+t>>3)%14+2)
		end
		for _,w in ipairs(t2) do
			nv = rot(v.x1,v.y1,v.x2,v.y2,-a)
			nv[1]=nv[1]+w.x
			nv[2]=nv[2]+w.y
			nv[3]=nv[3]+w.x
			nv[4]=nv[4]+w.y
			nv[1]=nv[1]+120
			nv[2]=nv[2]+68
			nv[3]=nv[3]+120
			nv[4]=nv[4]+68
			line(nv[1],nv[2],nv[3],nv[4],(v.c+t>>3)%14+2)
		end
	end
	txt={'H','e','l','l','o',' ','S','k','r','o','l','l','i',' ','\\','o','/'}
	for i=1,#txt do
		print(txt[i],i*10+30,68+sin(t/10+40*i),(t>>3)%13+3)
	end
end
