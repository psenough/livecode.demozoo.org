W=240
H=136
STEP=3

m=math
pi=3.14

flr=m.floor
sin=m.sin
cos=m.cos
rand=m.random
rnd=m.random
abs=m.abs
min=m.min

function drw_five(x,y,r,a,c,ii,rn)
	local i,k,t=0,0,a
	local x1,y1,x2,y2=0,0,0,0
	local px,py={},{}
	for k=0,5 do
		px[k+1]=cos(t+k*2*pi/5)*r
		py[k+1]=sin(t+k*2*pi/5)*r
	end
	for i=0,1,.5 do
		circb(x+r/30+rn,y+r/30+rn,r/5*4-i,c)
	end
	for k=0,10,2 do
		for i=0,ii do
			x1=px[k%5+1]+rand(ii)*rn
			y1=py[k%5+1]+rand(ii)*rn
			x2=px[(k+2)%5+1]+rand(ii)*rn
			y2=py[(k+2)%5+1]+rand(ii)*rn
			line(x+x1,y+y1,x+x2,y+y2,c-(i-1)/c)
		end
	end
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

function subpix(i,a,f)
	local p=peek4(i+f)
	poke4(math.min(i-f,0x3fbf*2+1),math.max(p-a,0))
end

tf=0
t2f=0
t4f=0
frm=0
BPM=133
cls()

lyr={
"I wanna go to",
"The late night",
"double feature",
"picture show"}

aud={"",
"",
"What kind of feature?",
"What kind of show??"}

white={
	0x00,0x00,0x00,0x10,0x10,0x10,
	0x20,0x20,0x20,0x30,0x30,0x30,
	0x40,0x40,0x40,0x50,0x50,0x50,
	0x60,0x60,0x60,0x70,0x70,0x70,
	0x80,0x80,0x80,0x90,0x90,0x90,
	0xa0,0xa0,0xa0,0xb0,0xb0,0xb0,
	0xc0,0xc0,0xc0,0xd0,0xd0,0xd0,
	0xe0,0xe0,0xe0,0xf0,0xf0,0xf0}

orange={ 
	0x1a,0x1c,0x2c,0x1a,0x1c,0x2c,
	0x3d,0x20,0x3d,0x5d,0x27,0x5d,
	0x72,0x3e,0x53,0x87,0x3e,0x53,
	0x9c,0x3e,0x53,0xb1,0x3e,0x53,
	0xef,0x7d,0x57,0xef,0x7d,0x57,
	0xef,0x7d,0x57,0xef,0x7d,0x57,
	0xff,0xcd,0x65,0xef,0xad,0x70,
	0x0f,0x0d,0x05,0xff,0xff,0xff}


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

vbank(1)
loadpal(orange)

function TIC()
	frm=frm+1
	t=time()/60000*BPM
	tf=lerp(tf,t//1,.1)
	t2f=lerp(t2f,t//4,.6)
	t4f=lerp(t2f,(t+.5)//4,.5)
	bm=fft(0)*10
	sn=fft(200)*300
	vbank(1)
	for i=0,W*H,STEP do
		subpix(i+frm%STEP,rnd(-1,5)*bm,rnd(-bm//1,bm//1+1)*.1)
	end
	vbank(0)
	cls()
	for ii=-10,3 do
		i=(ii+tf)%10/10
		dr=i%2*2-1
		drw_five(W/2,H/2,30+bm*10+(i*i)*5000,tf*.08*dr,3,2+sn//1*2,bm+i)
	end
	for y=0,H do 
		for x=0,W do
			X=x/W-.5
			Y=y/H-.5
			X,Y=rot(X,Y,sin(Y+tf*1.1)*.2+cos(X+tf*1.2)*.3)
			mi=min(abs(X)*100,abs(Y)*100)
			f=fft((mi-tf*10)%64)*10
			c=((abs(X*W)+abs(Y*H)+flr(tf*10)+f//1)*.1)%4+1
			if f>2-c/10 then
				pix(x,y,c)
			elseif f>1 then
				pix(x,y,c/2)
			end
		end 
	end 
	vbank(1)
	
	if t//1%2==0 then
		print(lyr[(t2f//1)%#lyr+1],W/5,H/5,15,1,2)
	end
	if t//1%2==1 then
		print(aud[(t2f//1)%#lyr+1],W/4,H-H/5,15,1,1)
	end
end
