W,H=240,136
STP=8
max=math.max
min=math.min
sin=math.sin
cos=math.cos
rnd=math.random
abs=math.abs
PI=math.pi

cls()
f={}
lf={}
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

orange2={
0x1a,0x1c,0x2c,0x5d,0x27,0x5d,
0x79,0x2e,0x5a,0x95,0x36,0x57,
0xb1,0x3e,0x53,0xc5,0x53,0x54,
0xda,0x68,0x55,0xef,0x7d,0x57,
0xf4,0x97,0x61,0xf9,0xb2,0x6b,
0xff,0xcd,0x75,0xfa,0xe0,0xb4,
0xf4,0xf4,0xf4,0x94,0xb0,0xc2,
0x56,0x6c,0x86,0x33,0x3c,0x57
}

white={
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0,
	0xf0,0xf0,0xf0,0xf0,0xf0,0xf0}

dth={}

WID=32
WI=8


function BOOT()
	for i=1,W*H+2 do
		dth[i]=rnd(100)/100-.5
	end
	for x=0,W do
		f[x+1]=0
		lf[x+1]=0
	end
	palset(0,orange2)
	palset(1,orange2)
end
frm=0
fr=0
BPM=130/2

ox=10*.4
oy=5*.4

low=0
function TIC()
	t=time()/60000*BPM
	tm=time()/600
	tm=tm%64
	t=t%16
	poke(0x3ffb,0)
	frm=frm+1
	WID=16--WI*((t//1*3)%16+1)
 fr=dt(frm,STP)
	if frm%4==0 then 
		vbank(0)
	 --cls()
		vbank(1)
		cls()
	end
	vbank(0)
	for ii=0,W*H,STP do
		i=ii+frm%STP
		subpix(i,rnd(-1,8),rnd(-1,1),13)
	end
	low=12
	lo=fft(0,64)*.3
	STP=3+lo//.4
	hi=vqt(64,512)*32
	
	
	for xx=0,W,STP do
	for yy=0,H,STP do
	--	x=xx+fr%STP
	--	y=yy+(fr//STP)%STP
		x=xx
		y=yy
		X=x/W-.5
		Y=y/H-.5
		--X,Y=rot(X,Y,.725*(t//1)%16*PI+(Y*hi*.1)%((t*4+X//1)//1)+t%PI*hi*.1)
		X,Y=rot(X,Y,X*Y*(1-lo*2))
		tt=(t)/1
	--	X,Y=rot(X,Y,PI/4*(tt//1+(tt-tt//1)^4))
		X,Y=rot(X,Y,PI/4*sin(tm*.1+X*Y)*4)
		X=abs(X)
		Y=abs(Y)
		
		f=vqt(max(Y,X)*W-WID*2)*16
		f2=vqt(abs(x/W-.5)*H)
		c=f+low-hi
		c=min(15,c)
		l=X*X+Y*Y
		cc=(min(Y*H,X*H)+t/1*WID/2)//WID
		cc=cc%2
		cc=cc*8
		co=(c/6.5)^3---cc/2
		co=min(12,co-l*l*20)
		if co>4 then 
			if cc<7 then 
				p=peek4(x+y*W)
				if co>=p then
					w=STP*(1+f*0.2)-1
					w=min(STP*3,w)
					if w>STP*2 then 
						if co>11 then 
							for ii=0,w,5 do
								circ(x-1,y-ii,w/2-ii/4,8)
							end
						end
						for ii=w,0,-1 do
							circ(x,y-ii,w/2-ii/4,co-ii/7)
						end
					else
						rect(x-w/2,y-w/2,w,w,co)
					end
				end
			end
		end
	end
	end
		vbank(0)
end





function subpix(i,a,f,c)
	local p=peek4(i+f)
	if p<c then 
		poke4(math.min(i-f,0x3fbf*2+1),math.max(p-a,0))
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
