
W,H=240,136
STP=3

rnd=math.random
abs=math.abs
sin=math.sin
cos=math.cos
min=math.min
max=math.max

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
	for i=1,144 do
		off[i]=0
	end
	palset(0,orange)
	palset(1,orange)
	cls()
end

frm=0
BPM=135
lp=0
tf=0
function TIC()
	for i=1,144 do
		off[i]=off[i]*.9
	end
	frm=frm+1
	fr=dt(frm,STP)
 t=time()/60000*BPM
 low=fft(0,32)
 lp=lp+ffts(0,1023)
 ti=t//1	
 tf=lerp(ti,tf,0.2)
 tr=t-t//1
 poke(0x3FFB,0)
	memcpy(0x8000,0,16320)
	vbank(1)
	memcpy(0,0x8000,16320)
 vbank(0)
	blur(fr,STP,2)
 if rnd(100)>40 then
 	--line(rnd(W),rnd(H),rnd(W),rnd(H),15)
 end
 for xx=0,W,STP do
	 for yy=0,H,STP do
			x=xx+fr%STP
			y=yy+(fr//STP)%STP
			X=x/W-.5
			X2=X
			Y=y/H-.5
			Y=Y/(W/H)
			X,Y=zom(X,Y,1.5)
			l=X*X+Y*Y
			X,Y=rot(X,Y,abs(Y)+sin(lp*.00001)*1)
			for i=0,5 do
				X=abs(X)-0.2+i*0.005
				X,Y=rot(X,Y,0.2+lp*.0001+i*.01)
			end
			X=X*(0.5+l*10)
			Y=Y*(0.5+l*10)
			--X,Y=rot(X,Y,lp*.005)
			fq=(abs(X*W/2))%32
			f=ffts(fq,fq+l*8)*math.log(fq,1.5)
			c=f*16-l*40
			c=min(15,max(0,c))
			if l>.05+low*.02 then 
				if f>abs(Y) then
					if c>1+dth[(x+y*W+t//1)%#dth+1]*4 then 
						pix(x,y,c*(abs(X2*2)-tr))
					end
				end
			else
				if l<.05 then
					if c<1 then
						pix(x,y,15)
					end
				end
			end
	 end
	end
 vbank(1) 
 if frm%(STP*STP)==0 then
	 cls()
 end
 
 fcrot(0,0,math.pi,1,0)
end

function BDR(i)
 --poke(0x3ff8,low*low)
 local ii=abs(i-(H+8)/2)
 local ff=ffts(ii/2)*10
 palmix(0,default,orange,ff*.5)
 palmix(1,white,orange,ff)
 off[i+1]=off[i+1]+ff-sin(t*0.1+i*0.02)*2
 vbank(0)
 if i%2==0 then 
	 poke(0x3ff9,-off[i+1])
	else
	 poke(0x3ff9,off[i+1])
	end
	vbank(1)
 if i%2==0 then 
	 poke(0x3ff9,off[i+1]*.2)
	else
	 poke(0x3ff9,-off[i+1]*.2)
	end
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