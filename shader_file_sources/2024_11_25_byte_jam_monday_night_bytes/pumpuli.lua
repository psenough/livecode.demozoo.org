W=240
H=136
BPM=176*.5
STEP=5
PARTICLES=100
HISTORY=100

m=math
min=m.min
max=m.max
abs=m.abs
rnd=m.random
sin=m.sin
cos=m.cos
pow=m.pow
flr=m.floor
PI=m.pi
P2=m.pi*2

white={
	0x00,0x00,0x00,0x10,0x10,0x10,
	0x20,0x20,0x20,0x30,0x30,0x30,
	0x40,0x40,0x40,0x50,0x50,0x50,
	0x60,0x60,0x60,0x70,0x70,0x70,
	0x80,0x80,0x80,0x90,0x90,0x90,
	0xa0,0xa0,0xa0,0xb0,0xb0,0xb0,
	0xc0,0xc0,0xc0,0xd0,0xd0,0xd0,
	0xe0,0xe0,0xe0,0xf0,0xf0,0xf0}
	
whitc={
	0x00,0x00,0x00,0x20,0x20,0x20,
	0x40,0x40,0x40,0x60,0x60,0x60,
	0x80,0x80,0x80,0xa0,0xa0,0xa0,
	0xc0,0xc0,0xc0,0xe0,0xe0,0xe0,
	0xf0,0xf0,0xf0,0xd0,0xd0,0xd0,
	0xb0,0xb0,0xb0,0x90,0x90,0x90,
	0x70,0x70,0x70,0x50,0x50,0x50,
	0x30,0x30,0x30,0x10,0x10,0x10}

purple={ 
	0x0c,0x0a,0x2e,0x15,0x10,
	0x43,0x1e,0x15,0x59,0x27,0x19,
	0x70,0x31,0x1b,0x88,0x3d,0x1c,
	0xa1,0x49,0x1d,0xbb,0x57,0x1c,
	0xd7,0x66,0x1a,0xeb,0x79,0x20,
	0xf1,0x8d,0x32,0xf7,0xa0,0x46,
	0xfc,0xb3,0x5b,0xff,0xc3,0x70,
	0xe8,0xf1,0xaa,0xde,0xee,0xd7,0x1a}
	
orange={ 
	0x1a,0x0c,0x0a,0x2e,0x15,0x10,
	0x43,0x1e,0x15,0x59,0x27,0x19,
	0x70,0x31,0x1b,0x88,0x3d,0x1c,
	0xa1,0x49,0x1d,0xbb,0x57,0x1c,
	0xd7,0x66,0x1a,0xeb,0x79,0x20,
	0xf1,0x8d,0x32,0xf7,0xa0,0x46,
	0xfc,0xb3,0x5b,0xff,0xc3,0x70,
	0xe8,0xf1,0xaa,0xde,0xee,0xd7}
	
orangc={
	0x1a,0x0c,0x0a,0x43,0x1e,0x15,
	0x70,0x31,0x1b,0xa1,0x49,0x1d,
	0xd7,0x66,0x1a,0xf1,0x8d,0x32,
	0xfc,0xb3,0x5b,0xe8,0xf1,0xaa,
 0xde,0xee,0xd7,0xff,0xc3,0x70,
 0xf7,0xa0,0x46,0xeb,0x79,0x20,
 0xbb,0x57,0x1c,0x88,0x3d,0x1c,
 0x59,0x27,0x19,0x2e,0x15,0x10}
 
 
black={
	0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00}
	
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
function slen(a)
	return a[1]*a[1]+a[2]*a[2]
end	
function clr(c1,c2)
	local curbnk=vbank()
	vbank(0)
	cls(c1)
	vbank(1)
	cls(c2)
	vbank(curbnk)
end
function subpix(i,a,f)
	local p=peek4(i+f)
	poke4(math.min(i-f,0x3fbf*2+1),math.max(p-a,0))
end
function frnd(a,b,s)
	return rnd(a*s,b*s)/s
end
function lerp(a, b, t)
	return a + (b - a) * t
end

dth={}

for i=1,W*H+1 do
	dth[i]=rnd(100)/100-.5
end

function quad(
 x1, y1, x2, y2, x3, y3, x4, y4,
ux1,uy1,ux2,uy2,ux3,uy3,ux4,uy4,
z,rn)
	
	rn=rn//1
	
	 x1= x1+W/2
	 x2= x2+W/2
	 x3= x3+W/2
	 x4= x4+W/2
	ux1=ux1+W/2+rnd(-rn,rn)
	ux2=ux2+W/2+rnd(-rn,rn)
	ux3=ux3+W/2+rnd(-rn,rn)
	ux4=ux4+W/2+rnd(-rn,rn)
	
	 y1= y1+H/2
	 y2= y2+H/2
	 y3= y3+H/2
	 y4= y4+H/2
	uy1=uy1+H/2+rnd(-rn,rn)+dth[(ux1+uy1*W)%#dth+1]
	uy2=uy2+H/2+rnd(-rn,rn)+dth[(ux2+uy2*W)%#dth+1]
	uy3=uy3+H/2+rnd(-rn,rn)+dth[(ux3+uy3*W)%#dth+1]
	uy4=uy4+H/2+rnd(-rn,rn)+dth[(ux4+uy4*W)%#dth+1]
--	local x1,y1,x2,y2,x3,y3,x4,y4=p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,p4.x,p4.y
	-- p1 -- p2
	-- |      |
	-- p3 -- p4
	ttri(x1, y1, x2, y2, x4, y4,
	    ux1,uy1,ux2,uy2,ux4,uy4,2,0,z,z,z)
	ttri(x1, y1, x3, y3, x4, y4,
	    ux1,uy1,ux3,uy3,ux4,uy4,2,0,z,z,z)	
end

function rot(xx,yy,r)
    local x,y=xx,yy
    x=m.cos(r)*xx-m.sin(r)*yy
    y=m.cos(r)*yy+m.sin(r)*xx
    return x,y
end

function toboolean(v)
    return v ~= nil and v ~= false
end
function xor(a, b)
    return toboolean(a) ~= toboolean(b)
end

prts={}

bmh={}
bmo={}
AREA=500





function BOOT()
	cls()
	palset(0,orange)
	palset(1,purple)
	p={}
	for i=1,PARTICLES do
		p[1]=rnd(-AREA,AREA)
		p[2]=rnd(-AREA,AREA)
		p[3]=rnd(-AREA,AREA)
		p[4]=10
		p[5]=9
		prts[i]={p[1],p[2],p[3],p[4],p[5]}
	end
	for i=1,HISTORY do
		bmh[i]=0
	end
	
end

ft=0 
tf=0
fram=0

cx=-200
cy=0
cz=500
dz=0

function sort(a,b)
	return a[3]>b[3]
end

function lim(a)
	return max(0,min(1023,a))
end

function TIC()
	fram=fram+1
	bmo=bmh
	for ii=2,#bmh,2 do 
		i=ii+fram%2
		bmh[i]=bmo[i-1]
	end
 t=time()/60000*BPM
 ti=m.floor(t)
 tf=lerp(tf,t-ti,.5)
 flc=fft(0,1023)
	low=fft(0,32)/flc
	lmid=fft(32,256)/flc
	hmid=fft(256,512)/flc
	high=fft(512,1023)/flc
 bm=fft(0,16)/flc*4
	bmh[1]=min(10,(bm*.4))
 vbank(0)
 
 vbank(0)
	memcpy(0x8000,0,16320)
	vbank(1)
	memcpy(0,0x8000,16320)
	if fram%8==0 then 
		for x=0,W do
		for y=0,H do
			i=x+y*W
			X=x/W-.5
			Y=y/H-.5
			d=X*X+Y*Y
--			c=2*dth[i%#dth+1]
			c=0+d*dth[i%#dth+1]*2
			subpix(i,c,0)
		end
		end
	end
	vbank(0)
	cls()
 
	--[[for y=0,H do 
		for x=0,W do
			X=x/W-.35
			Y=y/W-.30
			i=flr(abs(X*.8*W*(1/(X+1))))
			X,Y=rot(X,Y,(sin(t-tf*.8)*Y*cos(X-t)*10)%P2)
			X=X*W
			Y=Y*W
			mi=min(abs(X),abs(Y))
			ma=max(abs(X),abs(Y))
			mi=lim(mi)
			ma=lim(ma)
			f=fft(mi,ma)*10
			cc=bmh[i%#bmh+1]*10
			if xor(X*W,Y*H) then
				xx=16
			else
				xx=2
			end
			pix(x,y,((xx+t*10+f)//1)>>3-cc//1)
		end 
	end --]]
	fcrot(0,0,0.01,1.005+bm*.04,((t*2)//1)%2*4)
	
	fv=100-min(90,(ffts(0,16)/ffts(0,1023))*80)
	ml=0.1
	for i=1,PARTICLES do
		p=prts[i]
		ay=bm*.03
		ax=bm*.04+high*.2
		az=lmid*.2-hmid*.5
		p[1],p[3]=rot(p[1],p[3],ay*ml)
		p[2],p[3]=rot(p[2],p[3],ax*ml)
		p[2],p[1]=rot(p[2],p[1],az*ml)
		p[6]=p[1]*p[1]+p[2]*p[2]+p[3]*p[3]
		dx,dy,dz=p[1],p[2],p[3]
		dx=dx+cx
		dy=dy+cy
		dz=dz+cz
		if dz>0 then
			x=dx*(fv/dz)
			y=dy*(fv/dz)
			s=p[4]*((fv)/dz)*4
	 	x=x+W/2
			y=y+H/2
			if s>0.8 then 
				circ(x,y,2+s*bmh[min(#bmh,abs(x-W/3)//10+1)]*1.2,1)
				circ(x,y,1+s*bmh[min(#bmh,abs(x-W/3)//10+1)],min(15,(s+1)))
			end
			--pix(x,y,15)
		end
		prts[i]=p
	end
	table.sort(prts,sort)
	
	
end

function BDR(i)
	local ii=abs(i-W/2)//10
	cc=bmh[ii%#bmh+1]*10
	
	if i%2==0 then 
		poke(0x3FF9,(cc-1)*10)
	else
		poke(0x3FF9,(-cc+1)*10)
	end
	
end 


function fcrot(x,y,a,s,rn)
	local x1,y1,x2,y2,x3,y3,x4,y4=0,0,0,0,0,0,0,0
	local rx1,ry1,rx2,ry2,rx3,ry3,rx4,ry4=0,0,0,0,0,0,0,0
	
	x1=-W/2
	y1=-H/2
	x2=W/2
	y2=-H/2
	x3=-W/2
	y3=H/2
	x4=W/2
	y4=H/2
	
	x1=x1+x
	x2=x2+x
	x3=x3+x
	x4=x4+x
	y1=y1+y
	y2=y2+y
	y3=y3+y
	y4=y4+y
	
	rx1,ry1=rot(x1,y1,a)
	rx2,ry2=rot(x2,y2,a)
	rx3,ry3=rot(x3,y3,a)
	rx4,ry4=rot(x4,y4,a)
	
	rx1=rx1*s
	rx2=rx2*s
	rx3=rx3*s
	rx4=rx4*s
	ry1=ry1*s
	ry2=ry2*s
	ry3=ry3*s
	ry4=ry4*s

	rx1=rx1-x
	rx2=rx2-x
	rx3=rx3-x
	rx4=rx4-x
	ry1=ry1-y
	ry2=ry2-y
	ry3=ry3-y
	ry4=ry4-y

	quad(rx1,ry1,rx2,ry2,rx3,ry3,rx4,ry4,
	      x1, y1, x2, y2, x3, y3, x4, y4,
						0,rn)
	
end