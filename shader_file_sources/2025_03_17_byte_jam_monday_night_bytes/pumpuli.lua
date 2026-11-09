-- fft test incoming :D
W,H=240,136
STP=2
m=math
exp=math.exp
log=math.log
min=math.min
max=math.max
abs=math.abs
sin=math.sin
cos=math.cos
rnd=math.random


krn={
{1,2,1},
{2,4,2},
{1,2,2}}



default={
26,28,44,93,39,93,
177,62,83,239,125,87,
255,205,117,167,240,112,
56,183,100,37,113,121,
41,54,111,59,93,201,
65,116,246,115,239,247,
244,244,244,148,176,194,
86,108,134,51,60,87}

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
function expalmix(p1,p2,t,ii)
	local pal={}
	for i=1,#p1 do
		pal[i]=lerp(p1[i],p2[i%3+1+ii*3%#p2],t)
	end
	return pal 
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
function rot(xx,yy,r)
    local x,y=xx,yy
    x=m.cos(r)*xx-m.sin(r)*yy
    y=m.cos(r)*yy+m.sin(r)*xx
    return x,y
end
function zom(xx,yy,z)
	local x,y=xx,yy
	x=x*z
	y=y*z
	return x,y
end
dth={}
for i=1,W*H+1 do
	dth[i]=m.random(100)/100-.5
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

off={}

function BOOT()

	for i=0,H+32 do
		off[i+1]=0
	end
end

palt={}
frm=0
BPM=180
function TIC()
	frm=frm+1
	t=time()/60000*BPM
	flc=fft(0,1024)
	low=fft(0,16)*flc
	palt=expalmix(default,default,low*.02,t//1)
	poke(0x3FFB,0)
 vbank(0)
	memcpy(0x8000,0,16320)
	vbank(1)
	memcpy(0,0x8000,16320)
	for xx=0,W,STP do
	for yy=0,H,STP do
		x=xx+frm%STP
		y=yy+(frm//STP)%STP
		X=x/W-.5
		Y=y/H-.5
		Y=Y/1.6
		X=X
		Y=Y*-1
		fq=W/4-abs(X*40)
		fs=ffts(fq)*log(fq,2)*160
		fn=fft(fq)*log(fq,2)*160
		X,Y=rot(X,Y,X*fs*.05)
		X,Y=zom(X,Y,.98)
		f=fs
		c=abs(X)/Y+f
		c=c/16
		if Y>0 then 
			c=c
		else
			c=c+8
		end
		c=c+fn*.01
		c=min(16,max(0,c))
		if c>2 then 
			pix(x,y,c)
		end
	end
	end
	
	vbank(0)
	
	fcrot(0,1,0.001*sin(t*.125),.99+low*0.001,1)
	
	for xxx=1,W-1,STP do
		for yyy=1,H-1,STP do
			x=xxx+(frm)%STP
			y=yyy+(frm//STP)%STP
			X=x/W-.5
			Y=y/H-.5
			l=X*X+Y*Y
			px=peek4(x+y*W)
			local nb=0
			for xx=1,3 do
				for yy=1,3 do
					px2=peek4(x+xx-2+(y+yy-2)*W)
					nb=nb+px2/krn[yy][xx]
				end
			end
			c=px/8
			c=c+nb/6
			c=c--+dth[(x+y*W)%#dth+1]*4
			c=c-l*4--*(1+dth[(x+y*W)%#dth+1])
			c=max(0,min(15,c))
			pix(x,y,c)
		end
	end
	
end

function BDR(i)
	local ii=abs(i-H/2-6)
	local f=fft(ii+8)*10*(1+ii*.2)
	f=f*.4
	off[i+1]=off[i+1]*.8+f
	
	--[
	palmix(0,palt,white,f*.1)
	palmix(1,palt,white,f*.5)
	poke(0x3ff9,off[i+1])
	--]]
end