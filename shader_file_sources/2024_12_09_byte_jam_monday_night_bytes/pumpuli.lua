W=240
H=136
BPM=130
STEP=4
SS=6
HISTORY=100


default={
26,28,44,93,39,93,
177,62,83,239,125,87,
255,205,117,167,240,112,
56,183,100,37,113,121,
41,54,111,59,93,201,
65,116,246,115,239,247,
244,244,244,148,176,194,
86,108,134,51,60,87}

oranged={
26,28,44,47,33,60,
70,35,80,93,39,93,
120,40,89,150,50,86,
177,62,83,199,94,84,
215,110,86,239,125,87,
243,160,97,250,180,105,
255,205,117,255,230,180,
255,240,200,255,255,255
}


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
function distance(p1,p2)
	local dx,dy=p2.x-p1.x,p2.y-p1.y
	return dx*dx+dy*dy
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
	dth[i]=(rnd(100)/100-.5)*.001
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

bmh={}
bmo={}

ft=0 
tf=0
fram=0

function lim(a)
	return max(0,min(1023,a))
end

function BOOT()
	palset(0,oranged)
	palset(1,oranged)
	for i=1,HISTORY do
		bmh[i]=0
	end
	
end


function TIC()
	fram=fram+1
	t=time()/60000*BPM
	tf=lerp(flr(t)*10,tf,.8)
	flc=fft(0,1023)
	bm=fft(0,32)/flc
	palmix(0,oranged,white,bm*10)
	palmix(1,oranged,white,bm*4)
	
	
 vbank(0)
	memcpy(0x8000,0,16320)
	vbank(1)
	memcpy(0,0x8000,16320)
	
	
	vbank(0)
	cls()
	fcrot(0,0,0.00+sin(tf/32)*.025,1.005-bm*.1+max(0,t%32-29)*.1,((t*2)//1)%2*4)
	for ii=0,W*H,STEP do
		if rnd(100)<2 then
			i=ii+fram%STEP
			pix(i%W,i//W,1)
		end
	end
	SS=8+bm*10
	SS=SS//1
	for yy=0,H,SS do 
		for x=0,W,SS do
			y=yy
			d=dth[(x+y*W)%#dth+1]
			X=x/W-.5
			Y=y/H-.5
			ds=X*X+Y*Y
			X,Y=rot(X,Y,(10*ds*sin(tf*.01)*0.3+Y*4+X)*2)
			X=abs(X)*HISTORY
			Y=abs(Y)*HISTORY
			f=fft(X)*10+fft(Y)*10
			c=((X+Y)-ft+f)//10%15-ds*d*0.001
			c=max(0,c)
			if (c*3)%15>8 and (fram+x+y)%2==0 then
				circ(x,y,SS/2,c+d*bm)
				circb(x,y,SS/2,1)
			end
		end 
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