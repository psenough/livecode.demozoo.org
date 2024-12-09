t=0
rand=math.random
s=math.sin
c=math.cos

buildings={}
for i=1,100 do
	x=rand(-400,400)
	z=rand(-400,400)
	y=-rand(10,70)
	r=rand(12,20)
	buildings[i]={
		{x-r,z-r},
		{x+r,z-r},
		{x+r,z+r},
		{x-r,z+r},
		y,
		40
	}
end

scale=400

function TIC()
	t=t+1
	cls(1)
end

cols={
	{
		{0x66,0x55,0xaa},
		{0xff,0x66,0x44},
		{0xff,0xee,0x88},
	},
	{
		{0xcc,0xee,0xff},
		{0xcc,0xbb,0xaa},
		{0xff,0xee,0x88},
	},
	{
		{0x66,0x55,0xaa},
		{0xff,0x66,0x44},
		{0xff,0xee,0x88},
	},
}

sp=200

function SCN(y)
	p=(t%sp)/sp
	i=(t//sp)%(#cols-1)+1
	scol={
		lerpRGB(cols[i][1],cols[i+1][1],p),
		lerpRGB(cols[i][2],cols[i+1][2],p),
		lerpRGB(cols[i][3],cols[i+1][3],p),
	}
	if y<34 then
		col=lerpRGB(scol[1],scol[2],y/34)
		setRGB(1,col)
	elseif y<68 then
		col=lerpRGB(scol[2],scol[3],(y-34)/34)
		setRGB(1,col)
	else
		col=lerpRGB({50,50,50},{0,0,0},(y-68)/68)
		setRGB(1,col)
	end
end

function setRGB(i,c)
	local addr=0x3fc0+i*3
	poke(addr,c[1])
	poke(addr+1,c[2])
	poke(addr+2,c[3])
end

function lerpRGB(c1,c2,i)
	return {
		c1[1]+(c2[1]-c1[1])*i,
		c1[2]+(c2[2]-c1[2])*i,
		c1[3]+(c2[3]-c1[3])*i,
	}
end

function OVR()
	for i=0,15 do
		setRGB(i,lerpRGB({0,0,0},{100,100,130},i/15))
	end
	a=s(t/300)*3
	C=c(a)
	S=s(a)

	dist=800+s(t/80)*300

	transformed={}
	for i=1,#buildings do
		b=buildings[i]
		tr={}
		y1=b[5]
		y2=b[6]
		for j=1,4 do
			x=b[j][1]*C+b[j][2]*S
			z=(b[j][2]*C-b[j][1]*S+dist)/scale
			tr[j]={
				x/z,
				y1/z,
				y2/z,
				z,
			}
		end
		if tr[1][4]>0 then
			table.insert(transformed,tr)
		end
	end

	table.sort(transformed,function(a,b)
		return a[1][4]>b[1][4]
	end)

	for i=1,#transformed do
		tr=transformed[i]
		l=tr[4]
		d=tr[1][4]
		for j=1,4 do
			p=tr[j]
			dot=(l[1]-p[1])*(l[2]-p[2])-
							(l[1]-p[1])*(l[3]-p[2])
			if dot>0 then
				col=j+d*3
				tri(
					120+l[1],
					68+l[2],
					120+p[1],
					68+p[2],
					120+p[1],
					68+p[3],
					col)
				tri(
					120+p[1],
					68+p[3],
					120+l[1],
					68+l[3],
					120+l[1],
					68+l[2],
					col)
			end
			l=p
		end
	end
end
