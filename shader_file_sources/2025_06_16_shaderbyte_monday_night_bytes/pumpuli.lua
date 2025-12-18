W,H=240,136
STP=4
BPM=178/4

co=.7
ed=1.2
cn=4
krn={
{co,ed,co},
{ed,cn,ed},
{co,ed,co}}
abs=math.abs
sin=math.sin
PI=math.pi
max=math.max
min=math.min
tan=math.atan

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
	0x00,0x00,0x00,0x04,0x04,0x04,
	0x08,0x08,0x08,0x0c,0x0c,0x0c,
	0x10,0x10,0x10,0x18,0x18,0x18,
	0x20,0x20,0x20,0x30,0x30,0x28,
	0x40,0x40,0x30,0x60,0x60,0x40,
	0x80,0x80,0x60,0xa0,0xa0,0x80,
	0xc0,0xc0,0x90,0xd0,0xd0,0xa0,
	0xe0,0xe0,0xe0,0xff,0xff,0xff}

function BOOT()
	palset(1,white)
	palset(0,white)
	cls()
end

frm=0

function TIC()
	frm=frm+1
	fr=dt(frm,STP)
	t=time()/60000*BPM
	ti=t//1
	tf=t-ti
	te=tf*tf*tf*tf*tf*tf
	for yy=0,H,STP do 
		for xx=0,W,STP do
			x=xx+fr%STP
			y=yy+(fr//STP)%STP
			Y=y/H-.5
			Y=Y/(W/H)
			X=x/W-.5
			l=X*X+Y*Y
			a=sin(((tf+ti)*PI)*.0125)*l*10
			fq2=abs(tan(Y/X)/PI*100)
			f2=fft(min(1024,max(0,fq2%1024)))*100
			X,Y=rot(X,Y,a-(te*(1-l*10))*.1)
			for i=0,8 do 
				X=abs(X)-0.4--*(1-l*2)
				Y=abs(Y)-0.2--*(1-l*2)
				X=X+.2
				X,Y=rot(X,Y,sin((te+tf+ti*2)*.02)*10)
				X=X-.2
			end
			fq=abs(Y*Y)*(W*8)+8
			fq=fq%(1024*.95)
			f=fft(fq,fq*1.05)*4--(1+fq)
			c=f+8
			
			c=(c%6//1*3)+f*.3
			c=l>(.01+f2*.001) and c or min(16,c+8)
			c=max(0,min(15,c))
			
			pix(x,y,c)
		end 
	end 
end


function BDR(i)
 --poke(0x3ff8,low*low)
 --[
 local ii=abs(i-(H+8)/2)
 local ff=ffts(ii/2)*(4+ii/4)
 if i%2==0 then 
	 --palmix(0,white,default,ff*.4,false)
 else
 	--palmix(0,trans,twhite,ff*.125,true)
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