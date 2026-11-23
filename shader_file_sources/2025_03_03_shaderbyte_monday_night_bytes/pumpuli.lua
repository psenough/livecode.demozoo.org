--
W,H=240,136
STP=2

m=math
min=math.min
max=math.max
sin=math.sin
cos=math.cos
abs=math.abs
rnd=math.random

orange={
26,28,44,47,33,60,
70,35,80,93,39,93,
120,40,89,150,50,86,
177,62,83,199,94,84,
215,110,86,239,125,87,
243,160,97,250,180,105,
255,205,117,255,230,180,
255,240,200,255,255,255
}

white={
	0x00,0x00,0x00,0x10,0x10,0x10,
	0x20,0x20,0x20,0x30,0x30,0x30,
	0x40,0x40,0x40,0x50,0x50,0x50,
	0x60,0x60,0x60,0x70,0x70,0x70,
	0x80,0x80,0x80,0x90,0x90,0x90,
	0xa0,0xa0,0xa0,0xb0,0xb0,0xb0,
	0xc0,0xc0,0xc0,0xd0,0xd0,0xd0,
	0xe0,0xe0,0xe0,0xff,0xff,0xff}
	

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

function frnd(a,b,s)
	return math.rnd(a*s,b*s)/s
end
function lerp(a, b, t)
	return a + (b - a) * t
end

function subpix(i,a,f)
	local p=peek4(i+f)
	poke4(math.min(i-f,0x3fbf*2+1),math.max(p-a,0))
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



ffth={}
fftn={}
fftm={}

off={}

function BOOT()
	for i=0,H+32 do
		off[i+1]=0
	end
	for i=0,1025 do
		ffth[i+1]=0
		fftn[i+1]=0
		fftm[i+1]=0
	end
	vbank(0)
	cls()
	vbank(1)
	cls()
	palset(1,white)
	palset(0,white)
	
end

function fftc(a,b)
	local aa,bb=min(1023,max(0,a)),min(1023,max(0,b))
	
	
	return fft(aa,bb)
end
function fftc(a)
	local aa=min(1023,max(0,a))
	return fft(aa)
end

BPM=160
frm=0

function TIC()
	frm=frm+1
	t=time()/60000*BPM
	flc=fft(0,1023)
	palmix(0,white,orange,flc/32)
 vbank(0)
	memcpy(0x8000,0,16320)
	vbank(1)
	memcpy(0,0x8000,16320)
	for xx=0,W do
		for yy=0,H do
			x=xx+frm%2
			y=yy
			if x%STP==0 and y%STP==0 then
				pix(x,y,0)
			end
			if x%STP==1 and y%STP==1 then
				pix(x,y,0)
			end
		end
	end
	for xx=0,W,STP do
		for yy=0,H,STP do
		
			x=xx+frm%STP
			y=yy+(frm//STP)%STP
			X=x/W-.5
			Y=y/H-.5
			X=X+sin(t*.2)*.5
			Y=Y+cos(t*.1)*.5
			X,Y=rot(X,Y,X*sin(t*.2))
			X,Y=rot(X,Y,t*0.05+Y*cos(t*.21)*2)
			Y=Y+sin(X*80*Y+t*10)*.0004*flc
			X=(X+1)%2-1
			Y=(Y+1)%2-1
			aX=abs(X)
			aY=abs(Y)
			f=fftc(((aY or aX)*W)%128)*20
			f=f*f
			c=f
			c=min(15,max(0,c))
			--pix(x,y,15-c)		
			pix(xx+frm%STP,yy+(frm//STP)%STP,c)
		
		end
	end
	vbank(0)
	
	
	fcrot(0,0,0,.98+flc*0.001,1)
	
end

function BDR(i)
	local ii=abs(i-H/2-6)
	local f=fftc(ii+8)*10*(1+ii*.2)
	off[i+1]=off[i+1]*.8+f*.2
	palmix(0,white,orange,f*.2)
	palmix(1,white,orange,f)
	poke(0x3ff9,off[i+1])
	
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