-- Greetz to: Aldroid, The Wolf,
-- Ferris, Mantratronic,
-- Alia, Gasman
-- Byte Jam Viewers!

SIN,COS=math.sin,math.cos

T=0
VINES={}

function BDR(y)
	for i=0,4 do
		for s=0,2 do
			local addr=0x3FC3+(i*3+s)*3
			local r=.5+SIN(i+s*.2+y*.02+T*.03)*.5
			local g=.5+SIN(1+i+s*.2+y*.022+T*.03)*.5
			local b=.5+SIN(2+i+s*.2+y*.023+T*.03)*.5
			poke(addr,r*255//1)
			poke(addr+1,g*255//1)
			poke(addr+2,b*255//1)
		end
	end
end

function BOOT()
	startVine()
end

function startVine()
	if #VINES==50 then
		VINES={}
	end

	local r=math.random(3)
	if r==0 then
		x,y=math.random(-20,239+20),-20
		a=math.pi/2
	elseif r==1 then
		x,y=239+20,math.random(-20,135+20)
		a=math.pi
	elseif r==2 then
		x,y=math.random(-20,239+20),139+20
		a=math.pi*1.5
 else
		x,y=-20,math.random(-20,135+20)
		a=0
	end
	a=a+math.random()-.5
	makeVine(x,y,a)
end

function TIC()
	cls()

 for i=1,#VINES do
  local v=VINES[i]
		if v.active and T%5==1 then
			addSeg(v)
		end

		local offScreen=doVine(v,4)
		if v.active and offScreen then
		 v.active=false
			startVine()
		end
 end

	print("VINE JAM",190,2,4)
	
	T=T+1
end

function makeVine(x,y,a)
 VINES[#VINES+1]={
		x=x,
		y=y,
		c=math.random(1,15),
		a={a},
		aim=a,
		active=true,
		age=0,
	}
end

function addSeg(v)
	local lastA=v.a[#v.a]
	local dA=v.aim-lastA

	v.a[#v.a+1]=lastA+dA*.3
end

function doVine(v,wSrc)
	local xl0,yl0=v.x,v.y
	xl0=xl0+math.sin(T*.02+v.age*.03)*10
	yl0=yl0+math.sin(T*.01+v.age*.04)*10
	for i=1,#v.a do
		w=((#v.a-i)*.2)*wSrc*(v.age^.7)/100
		w=math.min(w,10)
		local a=v.a[i]
		local ls=SIN(a)
		local lc=COS(a)
		local xl1=xl0+lc*10
		local yl1=yl0+ls*10

		local fx00=xl0-ls*w
		local fy00=yl0+lc*w
		local fx01=xl0+ls*w
		local fy01=yl0-lc*w

		local fx10=xl1-ls*w
		local fy10=yl1+lc*w
		local fx11=xl1+ls*w
		local fy11=yl1-lc*w
		
		tri(fx00,fy00,fx01,fy01,fx10,fy10,v.c)
		tri(fx10,fy10,fx11,fy11,fx01,fy01,v.c)

	 if i%2==0 then
			local lx1=fx11+ls*w
			local ly1=fy11-lc*w
			tri(fx11,fy11,lx1,ly1,fx01,fy01,v.c-1)
		else
			local lx1=fx10-ls*w
			local ly1=fy10+lc*w
			tri(fx10,fy10,lx1,ly1,fx00,fy00,v.c-1)
		end
					
		xl0,yl0=xl1,yl1

 	if xl0<-50 or xl0>=240+50 or
  	yl0<-50 or yl0>=136+50 then
   return true
		end
	end
	
	v.age=v.age+1
	
	if math.random()<.03 then
		v.aim=math.random()*math.pi*2
	end

	return false
end
