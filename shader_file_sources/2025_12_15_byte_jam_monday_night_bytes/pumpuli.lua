W,H=240,136
STP=3
BPM=174/2

abs=math.abs
min=math.min
max=math.max
cos=math.cos
sin=math.sin
rnd=math.random

blue={
26,28,44,
28,32,53,
31,35,62,
33,39,72,
35,43,81,
37,46,91,
38,47,93,
39,51,102,
41,54,111,
59,93,201,
65,116,246,
115,239,247,
244,244,244,
148,176,194,
86,108,134,
51,60,87}


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
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0}


bm={}

function BOOT()
	for i=1,100 do
		bm[i]=0
	end
	palset(1,blue)
	palset(0,default)
	cls()
end
PIR=3.1415/180
frm=0
ox,oy=0,0
function TIC()
--	cls()
	frm=frm+1
	fr=dt(frm,STP)
	if fr==0 then 
		vbank(0)
		cls()
		cls()
	end
	vbank(1)
	for i=0,W*H do
		if rnd(80)<10 then
			p=peek4(i)-1
			if p<=8 then p=0 end
			poke4(i,p)
		end
	end
	t=time()/60000*BPM
	ti=t//1
	tr=t-ti
	tf=ti+tr*tr*tr*tr
	bm[1]=fft(0,24)
	for i=100,2,-1 do
		bm[i]=bm[i-1]*.99
	end	
	for xx=0,W,STP do
	for yy=0,H,STP do
		x=xx+fr%STP
		y=yy+(fr//STP)%STP
		X=x/W-0.5
		Y=y/H-0.5
		Y=Y/(W/H)
		l=X*X+Y*Y
		for i=0,4 do
			X,Y=abs(X)-.05*i,abs(Y)-.005-.2*i
			X,Y=rot(X,Y,(10+6*tf*(1+i))*PIR*(1+l/1.2))
		end
		oX=vqt(abs(X)*W)*30
		fq=abs(X*124)
		f=vqt(fq)
		f=min(f*f*f*f,1)*1000
		c=oX+min(f,12)
		if abs(Y*124)>f then 
			c=oX
		end
		if c>1 and c<13 then 
			vbank(1)
			pix(x,y,c)
		else
			vbank(0)
			c=(c/16)%4*2
			pix(x,y,c)
		end
	end
	end	
	vbank(0)
	a=90
	r=40
	x=W/2
	y=H/2
	for an=0,359 do
		rad=(a+an)*(3.1415/180)
		wx=ox
		wy=oy
		fq=abs(an-180)/2
		f=vqt(fq)*10
		r=40+f
		ox=x+cos(rad)*r//1
		oy=y+sin(rad)*r//1
		line(ox,oy,wx,wy,r)
	end
	--[[
	local hx,hy,ha,hr,hpx,hpy=0,0,0,0,{},{}
	cn=5
	for i=0,cn-2 do
		hx=W/cn+W/cn*i
		hy=H/2
		ha=bm[i+1]
		hr=2+bm[1]*2
		flake(hx,hy,ha,hr,1,0)
	end
	for x=1,100 do
		--pix(x,1,bm[x])
	end	--]]
end

function flake(x,y,a,r,l,m)
	local hx,hy,ha,hr,hpx,hpy=0,0,0,0,{},{}
	hx=x
	hy=y
	ha=a-l
	hr=r/l
	c=bm[(l%#bm)+1]
	hpx,hpy=hex(hx,hy,ha,hr)
	if l>m then 
		for ii=1,6 do
			hi=(ii)%6+1
			line(hpx[ii],hpy[ii],hpx[hi],hpy[hi],8+c)
		end
	else
		for i=1,6 do
			hi=i%6+1
			flake(hpx[hi],hpy[hi],a,r/l,l+1,m)
		end
			--line(hpx[hi],hpy[hi],hx,hy,8+c)
	end			
end


function hex(x,y,a,r)
	local ox,oy={},{}
	local rad=0
	local i=1
	for an=0,359,60 do
		rad=(a+an)*(3.1415/180)
		ox[i]=x+cos(rad)*r//1
		oy[i]=y+sin(rad)*r//1
		i=i+1
	end
	
	return ox,oy
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