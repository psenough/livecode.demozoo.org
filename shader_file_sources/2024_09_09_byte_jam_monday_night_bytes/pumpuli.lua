-- GREETS EVERYONE !! 
W=240
H=136
MARGIN=20
MAIN=1
BACK=0
STEP=8
FLOW=2
PARS=40
THRE=800
DRAG=0.7
BRWN=0.4
SPD=0.8
BPM=174


rnd=math.random
abs=math.abs
max=math.max
min=math.min
sin=math.sin
cos=math.cos

m={0,0,0,0,0,0,0}
grad={16,50,84,118,0,0,0,0,152,186,220,254,0,0,0,0}
for ii=0,1 do
	for i=0,8 do
		poke(0x4000+(32*ii)+i,grad[i+8*ii+1])
end
end
t=0
ps={}

cyan={
	0x04,0x0d,0x0c,0x1c,0x13,0x2b,
	0x22,0x19,0x3a,0x26,0x1e,0x49,
	0x28,0x24,0x58,0x2a,0x2d,0x67,
	0x2f,0x3a,0x77,0x35,0x4a,0x86,
	0x3a,0x5c,0x96,0x3f,0x70,0xa5,
	0x45,0x87,0xb5,0x50,0x9d,0xbe,
	0x5f,0xb1,0xc4,0x6e,0xc3,0xcb,
	0xa3,0xdc,0xb9,0xde,0xee,0xd7}

orange={ 
	0x1a,0x0c,0x0a,0x2e,0x15,0x10,
	0x43,0x1e,0x15,0x59,0x27,0x19,
	0x70,0x31,0x1b,0x88,0x3d,0x1c,
	0xa1,0x49,0x1d,0xbb,0x57,0x1c,
	0xd7,0x66,0x1a,0xeb,0x79,0x20,
	0xf1,0x8d,0x32,0xf7,0xa0,0x46,
	0xfc,0xb3,0x5b,0xff,0xc3,0x70,
	0xe8,0xf1,0xaa,0xde,0xee,0xd7}

white={
	0x00,0x00,0x00,0x10,0x10,0x10,
	0x20,0x20,0x20,0x30,0x30,0x30,
	0x40,0x40,0x40,0x50,0x50,0x50,
	0x60,0x60,0x60,0x70,0x70,0x70,
	0x80,0x80,0x80,0x90,0x90,0x90,
	0xa0,0xa0,0xa0,0xb0,0xb0,0xb0,
	0xc0,0xc0,0xc0,0xd0,0xd0,0xd0,
	0xe0,0xe0,0xe0,0xf0,0xf0,0xf0}

blue={
	0x00,0x00,0x00,0x08,0x08,0x10,
	0x10,0x10,0x20,0x18,0x18,0x30,
	0x20,0x20,0x40,0x28,0x28,0x50,
	0x30,0x30,0x60,0x38,0x38,0x70,
	0x40,0x40,0x80,0x48,0x48,0x90,
	0x50,0x50,0xa0,0x58,0x58,0xb0,
	0x60,0x60,0xc0,0x68,0x68,0xd0,
	0x70,0x70,0xe0,0x78,0x78,0xf0}


function frnd(a,b,s)
	return rnd(a*s,b*s)/s
end
function lerp(a, b, t)
	return a + (b - a) * t
end
function quad(p1,p2,p3,p4,c,z)
	local x1,y1,x2,y2,x3,y3,x4,y4=p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,p4.x,p4.y
	-- p1 -- p2
	-- |      |
	-- p3 -- p4
	ttri(x1,y1,x2,y2,x4,y4,c,0,c,0,c,0,1,0,z,z,z)
	ttri(x1,y1,x3,y3,x4,y4,c,0,c,0,c,0,1,0,z,z,z)	
end
function quadb(p1,p2,p3,p4,c,z)
	local x1,y1,x2,y2,x3,y3,x4,y4=p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,p4.x,p4.y
	-- p1 -- p2
	-- |      |
	-- p3 -- p4
	line(x1,y1,x2,y2,c)
	line(x4,y4,x2,y2,c)
	line(x1,y1,x3,y3,c)
	line(x4,y4,x3,y3,c)
	--ttri(x1,y1,x2,y2,x4,y4,c,0,c,0,c,0,1,0,z,z,z)
	--ttri(x1,y1,x3,y3,x4,y4,c,0,c,0,c,0,1,0,z,z,z)	
end
function subpix(i,a,f)
	local p=peek4(i+f)
	poke4(math.min(i-f,0x3fbf*2),math.max(p-a,0))
end
function clr(c1,c2)
	local curbnk=vbank()
	vbank(0)
	cls(c1)
	vbank(1)
	cls(c2)
	vbank(curbnk)
end
function palset(bnk,pal)
	local curbnk=vbank()
	vbank(bnk)
	loadpal(pal)
	vbank(curbnk)
end
function loadpal(pal)
 for i=1,48 do
  poke(0x3fc0+i-1,pal[i])
 end
end
function palmix(bnk,p1,p2,t)
	local curbnk=vbank()
	local pal={}
	for i=1,#p1 do
		pal[i]=lerp(p1[i],p2[i],t)
	end
	vbank(bnk)
	loadpal(pal)
	vbank(curbnk)
end
function distance(p1,p2)
	local dx,dy=p2.x-p1.x,p2.y-p1.y
	return dx*dx+dy*dy
end

function newP(x,y,xv,yv,z)
	return {x=x,y=y,xv=xv,yv=yv,ox=x,oy=x,z=z}
end

function rndP(z)
	local p,x,y,xv,yv={},0,0,0,0
	x=rnd(W)
	y=rnd(H)
	xv=frnd(-1,1,100)
	yv=frnd(-1,1,100)
	p=newP(x,y,xv,yv,z)
	return p
end


function drawP(ps,sc)
	local i,j,f
	local p={}
	local p2={}
	local d=0
	local s=0
	vbank(MAIN)
	for i=1,#ps do
		p=ps[i]
		f=fft(min(1024,max(0,p.y)))*100
		for j=1,#ps do
			if i~=j then
				p2=ps[j]
				d=distance(p,p2)/THRE
				if 15//d//sc>2 then	
					--line(p.x,p.y,p2.x,p2.y,15/d/sc)
					quad(
						{x=p.x,y=p.y},
						{x=p2.x,y=p2.y},
						{x=p.ox-p.xv*FLOW,y=p.oy-p.yv*FLOW},
						{x=p2.ox-p2.xv*FLOW,y=p2.oy+p2.yv*FLOW},
						15//d//sc-f*10,
						d
					)
				end
			end
		end
	end
	vbank(BACK)
for i=1,#ps do
		p=ps[i]
		f=fft(min(1024,max(0,p.y)))*100
		for j=1,#ps do
			if i~=j then
				p2=ps[j]
				d=distance(p,p2)/THRE
				if 15//d//sc>2 then	
					--line(p.x,p.y,p2.x,p2.y,15/d/sc)
					quadb(
						{x=p.x,y=p.y},
						{x=p2.x,y=p2.y},
						{x=p.ox-p.xv*FLOW,y=p.oy-p.yv*FLOW},
						{x=p2.ox-p2.xv*FLOW,y=p2.oy+p2.yv*FLOW},
						15//d//sc-f*10,
						d
					)
				end
			end
		end
	end
end

function updateP(ps,mode,off)
	local i,j
	local p={}
	local p2={}
	for i=1,#ps do
		p=ps[i]
		p.ox=p.x+1+off[3]
		p.oy=p.y+1+off[4]
		p.x=p.x+p.xv*SPD
		p.y=p.y+p.yv*SPD
		p.xv=p.xv*DRAG+off[1]*frnd(0,1,100)*(PARS/2-p.z)
		p.yv=p.yv*DRAG+off[2]*frnd(0,1,100)*(PARS/2-p.z)
		p.xv=p.xv+frnd(-1,1,100)*BRWN*SPD
		p.yv=p.yv+frnd(-1,1,100)*BRWN*SPD
		for j=1,#ps do
			if j~=i then
				p2=ps[j]
				d=1/(1+distance(p,p2))
				p.xv=p.xv+p2.xv*d*SPD
				p.yv=p.yv+p2.yv*d*SPD
			end
		end
		--[ wrap around
		if mode==0 then
			if p.x>W+MARGIN then p.x,p.ox=-MARGIN,-MARGIN end
			if p.x<0-MARGIN then p.x,p.ox=W+MARGIN,W+MARGIN end
			if p.y>H+MARGIN then p.y,p.oy=-MARGIN,-MARGIN end
			if p.y<0-MARGIN then p.y,p.oy=H+MARGIN,H+MARGIN end
		--]]
		--[ reset at edge
		elseif mode==1 then
			if p.x>W+1+MARGIN or p.x<-1-MARGIN or p.y>H+1+MARGIN or p.y<-1-MARGIN then 
				ps[i]=rndP(i) 
			end
		--]]
		--[ bounce
		elseif mode==2 then
			if p.x>W or p.x<0 then p.xv=-p.xv*.8 end
			if p.y>H or p.y<0 then p.yv=-p.yv*.8 end
			if p.x>W then p.x=W end
			if p.x<0 then p.x=0 end
			if p.y>H then p.y=H end
			if p.y<0 then p.y=0 end
		--]]
		end
	end
	
end


function slen(a)
	return a[1]*a[1]+a[2]*a[2]
end	

function BOOT()
	clr(0,0)
	palset(BACK,orange)
	
	palset(MAIN,orange)
	local i,x,y,xv,yv=0,0,0,0,0
	for i=1,PARS do
		ps[i]=rndP(i/(PARS/10))
	end
	updateP(ps,0,{0,0,0,0})
end

sn={}

function TIC()
	t=t+1
	b=fft(0)*400
	
	m[1]=0
	m[2]=0
	ang=fft(1000)*100000
	vel=fft(10)*30
	m[1]=m[1]+cos(ang)*vel
	m[2]=m[2]+sin(ang)*vel
	palmix(MAIN,cyan,orange,min(1,slen(m)*.4))
	palmix(BACK,cyan,orange,min(1,slen(m)*.4))
	
	vbank(MAIN)
	cls()
	for i=0,W*H,STEP do
		r=frnd(-1.5,1,100)
		rn=rnd(-abs((r*(r*.2)*(peek4(i)*4))//1),16-peek4(i))
		subpix(i+t%STEP,rn/4,r)
	end
	drawP(ps,1)
	vbank(BACK)
	--[
		for i=0,W*(H-1) do
			r=frnd(-1,1,100)
			rn=rnd(-1,1)*(W/2)
			subpix(i,1,r-rn)
		end
	
	
	
	updateP(ps,0,{m[1],m[2],ang*.1,0})
--	sprint("PUMPULI",10,70,b*10,fft(0),1,5,5)
end

function sprint(text,x,y,c1,c2,m,s,sh)
	local i
	for i=0,sh do
		print(text,x+i,y+i,c2,m,s)
		print(text,x+i+1,y+i,c2,m,s)
	end
	print(text,x,y,c1,m,s)
end

function BDR(i)
	local ii=abs(i-H/2)
	f=0--fft(ii*2)*10
	vbank(BACK)
	if i%2==0 then 
		poke(0x3ff9,f)
	else
		poke(0x3ff9,-f)
	end
end