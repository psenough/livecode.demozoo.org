S,C,PI=math.sin,math.cos,math.pi
SECY0=20
SECY1=40

function BDR(y)
	vbank(0)
	doRGBLine(y,SECY0,0)

	local r=S(y*.03+T*.031)*.2+.2
	local g=S(y*.03-T*.023)*.2+.2
	local b=S(y*.03+T*.027)*.2+.2
	setRGB(0,r,g,b)	

	vbank(1)
	doRGBLine(y,SECY1,1)
	setRGB(15,1,1,1)
end

T=0
function TIC()
	vbank(0)
	cls()
	draw(SECY0,SECY0/2,T//10,7,28)
	
	vbank(1)
	cls()
	draw(SECY1,SECY1/2,T//4,4,14)

	lines={
		"Gentle",
		"Cubey",
		"Greetz",
		"To",
		"Aldroid",
		"Alia",
		"Nusan",
		"Mantratronic",
		"Synesthesia",
	}
	for i=1,#lines do
		local x=i*12+S(T*.1+i)*4
		local y=i*13+S(T*.04+i)*2
		print(lines[i],x+1,y+1,1,false,2)
		print(lines[i],x,y,15,false,2)
	end
	
	T=T+1
end

function draw(space,sz,ofs,ys,xs)
	for y=0,ys-1 do
		local yp=(space*y)%140
		for x=0,xs-1 do
			local dir=(y%2==0)and 1 or -1
			local xp=(x*sz+ofs*dir)%280-sz*2
			local a=x-T*.01
			local c=(x%14)+1
			drawShape(xp+space/2,yp+space/2,sz,c,a)
			drawShape(xp+space/2,yp+space/2,sz,(c+6)%14+1,a+.1)
			drawShape(xp+space/2,yp+space/2,sz,(c+12)%14+1,a+.2)
		end
	end
end

function drawShape(x,y,sp,c,a)
	local sz=sp/2
	y=y-math.abs(S(T*.1+a))*sz
	x0,y0=ang(x,y,a,sz)
	x1,y1=ang(x,y,a+PI/2,sz)
	x2,y2=ang(x,y,a+PI,sz)
	x3,y3=ang(x,y,a+PI*1.5,sz)
	
	tri(x0,y0,x1,y1,x,y,c)
	tri(x1,y1,x2,y2,x,y,c)
	tri(x2,y2,x3,y3,x,y,c)
	tri(x3,y3,x0,y0,x,y,c)
end

function ang(x,y,a,d)
	return x+S(a)*d,y+C(a)*d
end

function	doRGBLine(y,space,shift)
	local s=(y-4)//space
	for i=1,15 do
		local o=s*2+i*.03+shift+y*.02+T*.004
		local r=math.sin(o)*.5+.5
		local g=math.sin(o*2)*.5+.5
		local b=math.sin(o*3)*.5+.5
		setRGB(i,r,g,b)
	end
end

function setRGB(i,r,g,b)
	local addr=0x3fc0+i*3
	poke(addr,(r*255)//1)
	poke(addr+1,(g*255)//1)
	poke(addr+2,(b*255)//1)
end
