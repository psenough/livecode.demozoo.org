
W,H=240,136
STP=3
E=0.01
FAR=100
STEPS=100

rnd=math.random
abs=math.abs
sin=math.sin
cos=math.cos
min=math.min
max=math.max

co=.7
ed=1.2
cn=4

krn={
{co,ed,co},
{ed,cn,ed},
{co,ed,co}}

default={
26,28,44,93,39,93,
177,62,83,239,125,87,
255,205,117,167,240,112,
56,183,100,37,113,121,
41,54,111,59,93,201,
65,116,246,115,239,247,
244,244,244,148,176,194,
86,108,134,51,60,87}


trans={0x5b,0xce,0xfa,0x81,0xb6,0xe6,
0xca,0xb2,0xda,0xee,0xaa,0xc2,
0xf5,0xa9,0xb8,0xfa,0xbe,0xde,
0xfa,0xd6,0xf2,0xfa,0xe6,0xf6,
0xff,0xff,0xff,0xfa,0xe6,0xf6,
0xfa,0xd6,0xf2,0xfa,0xbe,0xde,
0xf5,0xa9,0xb8,0xee,0xaa,0xc2,
0xca,0xb2,0xda,0x81,0xb6,0xe6}

transflag={0x5b,0xce,0xfa,0x5b,0xce,0xfa,
0xf5,0xa9,0xb8,0xf5,0xa9,0xb8,0xf5,0xa9,0xb8,0xf5,0xa9,0xb8,
0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,
0xf5,0xa9,0xb8,0xf5,0xa9,0xb8,0xf5,0xa9,0xb8,0xf5,0xa9,0xb8,
0x5b,0xce,0xfa,0x5b,0xce,0xfa}


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
	
twhite={
255,255,255,255,255,255,
255,255,255,255,255,255,
255,255,255,255,255,255,
255,255,255,255,255,255,
255,255,255,255,255,255,
255,255,255,255,255,255,
255,255,255,255,255,255,
255,255,255,255,255,255,
}
	
black={
0,0,0,0,0,0,
0,0,0,0,0,0,
0,0,0,0,0,0,
0,0,0,0,0,0,
0,0,0,0,0,0,
0,0,0,0,0,0,
0,0,0,0,0,0,
0,0,0,0,0,0
}

off={}

function BOOT()
	for i=1,144 do
		off[i]=0
	end
	palset(1,trans)
	palset(0,trans)
	cls()
end

frm=0
BPM=132
lp=0
tf=0
function TIC()
	local uv,rg,ro,rd,rt,up,z,x,y=0,0,0,0,0,0,0,0,0
	for i=1,144 do
		off[i]=off[i]*.9
	end
	frm=frm+1
	fr=dt(frm,STP)
 t=time()/60000*BPM
 vbank(0)
 blur(frm,STP,1.4)
 for xx=0,W,STP do
	 for yy=0,H,STP do
			x=xx+fr%STP
			y=yy+(fr//STP)%STP
			X=x/W-.5
			Y=y/H-.5
			X,Y=rot(X,Y,3.14/4+t*.125)
			X=X+.2
			for i=0,10 do
				X=abs(X)-.2-.4*((t//1+i*0.1)%1)
				X,Y=rot(X,Y,sin(t*.125)*1.2*X*(3-i))
				Y=abs(Y)-.05*i
				X,Y=rot(X,Y,sin(t*.0125)*1.2*Y*(3-i))
			end
			X,Y=zom(X,Y,.3)
			X=X*W
			Y=Y*W
			fq=abs(X)
	 	f=ffts(fq)*(160+fq)
			f=f
			f=min(64,max(0,f))
			c=((X)//1+(Y)//1+f//1+H/2+48+t//1*16)>>4
			if c>2  then 	
				pix(x,y,c)
			end
	 end
 end
 
end

function BDR(i)
 --poke(0x3ff8,low*low)
 --[
 local ii=abs(i-(H+8)/2)
 local ff=ffts(ii/2)*(4+ii/4)
 if i%2==0 then 
	 --palmix(0,trans,default,ff*.125,true)
 else
 	--palmix(0,trans,twhite,ff*.125,true)
 end
 off[i+1]=off[i+1]*.4+ff*4---sin(t*0.1+i*0.02)*2
 --[
 vbank(0)
 if i%2==0 then 
	 poke(0x3ff9,-off[i+1])
	else
	 poke(0x3ff9,-off[i+1])
	end
	--]]
end



function blur(frm,stp,fd)
	local x,xx,xxx=0,0,0
	local y,yy,yyy=0,0,0
	for xxx=0,W,stp do
		for yyy=0,H,stp do
			x=xxx+(frm)%stp
			y=yyy+(frm//stp)%stp
			px=peek4(x+y*W)
			local nb=0
			for xx=1,3 do
				for yy=1,3 do
					px2=peek4(x+xx-2+(y+yy-2)*W)
					nb=nb+px2/krn[yy][xx]
				end
			end
			c=px/8
			c=(c+nb/8)/(1.15+fd*.1)
			c=math.max(0,math.min(15,c))
			pix(x,y,c)
		end
	end
end


function dt(f,s)
	local out=f
 local si=s//1
 local lu3={0,4,7,1,5,8,2,6,3}
 if s==3 then 
 	out=lu3[f//1%#lu3+1]
 end
 local lu4={0 ,5 ,2 , 7
           ,8 ,13,10,15
           ,3 ,6 ,11,14
           ,1 ,4 ,9 ,12}
       --[[{0 ,1 ,2 , 3
           ,4 ,5 ,6 , 7
           ,8 ,9 ,10,11
           ,12,13,14,15}--]]
 if s==4 then 
 	out=lu4[f//1%#lu4+1]
 end
	return out
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
function palmix(bnk,p1,p2,t,m)
	local mx = m or false
	local curbnk=vbank()
	local pal={}
	if m then 
		t=min(1,max(0,t))
	end
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
    x=math.cos(r)*xx-math.sin(r)*yy
    y=math.cos(r)*yy+math.sin(r)*xx
    return x,y
end
function zom(xx,yy,z)
	local x,y=xx,yy
	x=x*z
	y=y*z
	return x,y
end