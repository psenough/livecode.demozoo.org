cos=math.cos
sin=math.sin
pi=math.pi


function r2d(p,a)
 return {
  x=(cos(a)*p.x)+(sin(a)*-p.y),
  y=(cos(a)*p.y)+(sin(a)*p.x)
 }
end

t=0
ti=0
mbass=0
cooldown=0
trigger=false
syncthing=0
ft=0
dir={x=0,y=0}
fscale=0
frot=0

function TIC()t=time()//32

	for i=0,47 do
		poke(16320+i,sin(i+t/10)^2*i*6)
	end
	vbank(1)
	cls()
	memcpy(0,0x4000,16320)
	
	trigger=false
	local bass=0
	for i=0,10 do
	 bass=bass+fft(i)
	end
	ft=ft+bass
	dir={x=sin(ft/100)^5,y=sin(ft/77)^5}
	fscale=sin(ft/50)^5
	frot=(sin(ft/150)^5)/24
	
	if bass>mbass and cooldown<=0 then
	 mbass=bass
		cooldown=20
		trigger=true
		syncthing=syncthing+1
	end
	mbass=math.max(bass,mbass*.98)
	cooldown=cooldown-1
	
	for y=t%2,135,2 do
 	for x=t%2,239,2 do
 		pix(x,y,math.max(0,pix(x,y)-1))
 	end
 end
	
	local lp=nil
	local lo=nil
	for i=0,pi*2,(pi*2)/100 do
	 local p=r2d({x=10,y=0},i+t)
		lp=lp or p
		local o={x=sin(ti/8+i/5)*40+120,y=sin(ti/7+i/5)*40+68}
		lo=lo or o
		local f=fft(i*30//1)*2
		p.x=p.x*(1+f)
		p.y=p.y*(1+f)
		
		line(lp.x+lo.x,lp.y+lo.y,p.x+o.x,p.y+o.y,15)
		if f>.5 then
			circ(p.x+o.x,p.y+o.y,5,15)
		end
		lo=o		
		lp=p
	end
	
	vbank(0)
	local scale=fscale/20+1
	local p0=r2d({x=-.5,y=-.5},frot)
	local p1=r2d({x=.5,y=-.5},frot)
	local p2=r2d({x=-.5,y=.5},frot)
	local p3=r2d({x=.5,y=.5},frot)
	local off={
		x=dir.x*5+120,
		y=dir.y*5+68}
	p0={x=p0.x*240*scale+off.x,y=p0.y*136*scale+off.y}
	p1={x=p1.x*240*scale+off.x,y=p1.y*136*scale+off.y}
	p2={x=p2.x*240*scale+off.x,y=p2.y*136*scale+off.y}
	p3={x=p3.x*240*scale+off.x,y=p3.y*136*scale+off.y}
	ttri(
		0,0,
		240,0,
		0,136,
		p0.x,p0.y,
		p1.x,p1.y,
		p2.x,p2.y,
		2
	)
	ttri(
		240,0,
		0,136,
		240,136,
		p1.x,p1.y,
		p2.x,p2.y,
		p3.x,p3.y,
		2
	)
	if trigger then
	 local strs={"=^^=","alia"," <3","fris"," :3"," uwu"}
		print(strs[syncthing%#strs+1],5,32,15,0,10)
		--print("=^^=",5,30,0,0,10)
	end
	
	memcpy(0x4000,0,16320)
	
	vbank(1)
	cls()
	print("greets to jtruk, mantra, gasman",25,110,12)
	print("aldroid and ferris. And everyone watching!",7,120,12)
	print("=^^=",107,130,12)

	t=t+.01
	ti=ti+1
	vbank(0)
end

function SCN(y)
end