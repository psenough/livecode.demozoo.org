--greets from Finland :D
W=240
H=136
STEP=2

rnd=math.random
flr=math.floor
abs=math.abs
max=math.max
min=math.min
sin=math.sin
cos=math.cos
atan=math.atan

skr_s={
{0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,0,0,0,0,0,0,0,0,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,0,0,0,0,0,0,0,0,1,1,1,0},
{0,1,1,1,1,1,1,1,1,0,1,1,0},
{0,1,1,1,1,1,1,1,0,1,1,1,0},
{0,1,1,1,1,1,1,1,1,0,1,1,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0}}

skr_k={
{0,0,0,0,0,0,0,0,0,2,2,2,2},
{0,1,1,1,0,1,1,1,0,2,2,2,2},
{0,1,1,1,0,1,1,1,0,2,2,2,2},
{0,1,1,1,0,1,1,1,0,2,2,2,2},
{0,1,1,1,0,1,1,1,0,0,0,0,0},
{0,1,1,1,1,0,1,1,1,1,1,1,0},
{0,1,1,1,0,1,1,1,1,1,1,1,0},
{0,1,1,1,1,0,1,1,1,1,1,1,0},
{0,1,1,1,0,0,0,0,0,1,1,1,0},
{0,1,1,1,0,2,2,2,0,1,1,1,0},
{0,1,1,1,0,2,2,2,0,1,1,1,0},
{0,1,1,1,0,2,2,2,0,1,1,1,0},
{0,0,0,0,0,2,2,2,0,0,0,0,0}}


skr_r={
{0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,0,0,0,0,0,1,1,1,0},
{0,1,1,1,1,1,1,1,1,0,1,1,0},
{0,1,1,1,1,1,1,1,0,1,1,1,0},
{0,1,1,1,1,1,1,1,1,0,1,1,0},
{0,1,1,1,0,1,1,1,0,0,0,0,0},
{0,1,1,1,0,1,1,1,0,2,2,2,2},
{0,1,1,1,0,1,1,1,0,2,2,2,2},
{0,1,1,1,0,1,1,1,0,2,2,2,2},
{0,0,0,0,0,0,0,0,0,2,2,2,2}}

skr_o={
{0,0,0,0,0,0,0,0,0,0,0,0,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,0,0,0,0,0,1,1,1,0},
{0,1,1,1,0,2,2,2,0,1,1,1,0},
{0,1,1,1,0,2,2,2,0,1,1,1,0},
{0,1,1,1,0,2,2,2,0,1,1,1,0},
{0,1,1,1,0,0,0,0,0,1,1,1,0},
{0,1,1,1,1,1,1,1,1,0,1,1,0},
{0,1,1,1,1,1,1,1,0,1,1,1,0},
{0,1,1,1,1,1,1,1,1,0,1,1,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0}}

skr_l={
{0,0,0,0,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,0,0,0,0,0,0,0,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,1,1,1,1,1,1,1,1,1,1,1,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0}}


skr_i={
{0,0,0,0,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,1,1,1,0,2,2,2,2,2,2,2,2},
{0,0,0,0,0,2,2,2,2,2,2,2,2}}


f=0
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


function BOOT()
	palset(0,orange)
	palset(1,cyan)
	clr(0,0)
end	

BPM=126
s={}
s.b=0
s.p=0
s.fl=0

skr={skr_s,skr_k,skr_r,skr_o,skr_l,skr_l,skr_i}

function TIC()
	local lt={}
	t=time()//32
	s.b=time()/60000*BPM%4
	s.op=s.p
	s.p=s.b//1
	if s.op==s.p then
		s.mm=0
		s.fl=s.fl*.8
	else
		s.mm=1
		if s.p==1 or s.p==3 then
			s.sn=1
			s.fl=15
		else
			s.sn=0
		end
	end
	f=f+1
	bm=min(1,s.fl/2)
	palmix(0,cyan,orange,bm)
	palmix(1,orange,white,bm)
	vbank(0)
	for i=0,W*H,STEP do
		subpix(i+f%STEP,rnd(-1,2),rnd(-1,1))
	end
 if s.mm==1 then
 	x=W/4*s.p
  rect(x,0,W/4,H,15)
 end
	for y=0,H,STEP do 
		for x=0,W,STEP do
			X=x-W/2
			Y=y-H/2+sin(x*.02+t*.011)*sin(t*.01+sin(abs(X+t*-1)*.2+t*.1)*abs(X*.02))*40
			f=fft(abs(X),abs(X)+2)*(20+abs(X)*.8)
			if f>abs(Y) then
				rect(x,y,STEP,STEP,15-min(14,abs(X*.2)))
			else
			end
	--		pix(x,y,(x+y+t)>>3+f//1)
		end
 end
 vbank(1) 
 cls(0)
	--for y=0,H do 
		for x=0,W,STEP do
			X=x-W/2
	  Y=sin(x*.02+t*.011)*sin(t*.01+sin(abs(X+t*-1)*.2+t*.1)*abs(X*.02))*40
			f=fft(abs(X),abs(X)+2)*(20+abs(X)*.8)
				pix(x,H/2+f-Y,15)
				pix(x+1,H/2+f-Y,15)
				pix(x,H/2-f-Y,15)
				pix(x+1,H/2-f-Y,15)
	--		pix(x,y,(x+y+t)>>3+f//1)
		end
	
	x=4
	sc=3
	y=H/2+H/3-sc*7
	for i=1,7 do
		lt=skr[i]
		for xx=1,13 do
		f=fft(7*13-(xx+(i-1)*13))*(8*(1+s.fl))
		for yy=1,13 do
			if lt[yy][xx]==1 then
				rect(x+(xx-1)*sc+(i-1)*12*sc,y+(yy-1)*sc-f*f,sc,sc,2+(xx+yy)/2)
			elseif lt[yy][xx]==0 then
		 	rect(x+(xx-1)*sc+(i-1)*12*sc,y+(yy-1)*sc-f*f,sc,sc,1+s.fl)
			end			
		end
		end
	end
-- end
end

function BDR(i)
	vbank(0)
	poke(0x3ff8,s.fl)
end