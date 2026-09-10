
W=240
H=136
STEP=2
BPM=134
LEN=1023

m=math
min=math.min
max=math.max
sin=math.sin
cos=math.cos
abs=math.abs
rnd=math.random


whitc={
	0x00,0x00,0x00,0x20,0x20,0x20,
	0x40,0x40,0x40,0x60,0x60,0x60,
	0x80,0x80,0x80,0xa0,0xa0,0xa0,
	0xc0,0xc0,0xc0,0xe0,0xe0,0xe0,
	0xf0,0xf0,0xf0,0xd0,0xd0,0xd0,
	0xb0,0xb0,0xb0,0x90,0x90,0x90,
	0x70,0x70,0x70,0x50,0x50,0x50,
	0x30,0x30,0x30,0x10,0x10,0x10}
	
white={
	0x00,0x00,0x00,0x10,0x10,0x10,
	0x20,0x20,0x20,0x30,0x30,0x30,
	0x40,0x40,0x40,0x50,0x50,0x50,
	0x60,0x60,0x60,0x70,0x70,0x70,
	0x80,0x80,0x80,0x90,0x90,0x90,
	0xa0,0xa0,0xa0,0xb0,0xb0,0xb0,
	0xc0,0xc0,0xc0,0xd0,0xd0,0xd0,
	0xe0,0xe0,0xe0,0xf0,0xf0,0xf0}

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



ft={}

function BOOT()
	palset(0,white)
	palset(1,white)
	for i=0,LEN do
		ft[i+1]=0
	end	
end

tf=0
ttf=0
fram=0

function TIC()
	fram=fram+1
	t=time()/60000*BPM
	t=t%128
	flc=fft(0,1023)
	low=fft(0,32)/flc
	mid=fft(32,256)/flc
	hig=fft(256,1023)/flc
	bm=fft(0,8)*1
	tf=lerp(t//1,tf,0.8)
	ttf=lerp(ttf,t//2,.1)
	vbank(0)
	for i=0,W*H,STEP do 
		--subpix(i+fram%STEP,10,0)
	end
	if t-t//1<0.1 then 
		if (t//1)%2==0 then 
			for i=1,#ft do
				ft[i]=0
			end
		end
	else
		for i=1,#ft do
			ft[i]=ft[i]+fft(i-1)*(1+math.log(i))
		end
		for y=0,H do 
			for x=0,W do
				X=x/H-.5
				Y=y/H-.5
				X,Y=rot(X,Y,ttf*3.1415*.75+abs(Y))
				X=abs(X)
				Y=abs(Y)
				d=X*X+Y*Y
				X=X*(H/W)*W
				Y=Y*(H/W)*W
				f=ft[(X)//1+1]
				c=((Y-(tf*15)//1+f//1)*.05)%2
				c=c-d*(10*bm)-0.1*dth[(x+y*W)%#dth+1]
				c=max(0,c)
				if x%2==0 or y%2==0 then 
					pix(x,y,c*10+ttf*4%15)
				end
			end
	 end 
	end
	if (t//1)%32>30 then 
		--cls()
	end
	if fram%2==0 then 
		--fcrot((tf%16-8)*(W/3)//1,0,0,1.03+bm*.01,0)
		--fcrot((tf%16)*(W/3)//1-W/2,0,0,1.03+bm*.01,0)
		if t%64>=0 then 
			fcrot(0,0,0,1,0)
		else
			fcrot((tf%16-8)*(W/3)//1,0,0,1.05+bm*.01,0)
		end
	end
	grts(bm)
	vbank(1)
	cls()
	if fram%2==1 then
		--fcrot(0,0,(3.1415*.5)*ttf,.99+bm*.05,(t*2)%2)
		if t%64>=0 then 
	 	fcrot(0,0,0.05*sin(tf*.1),1.085+bm*.05,(t*2)%2)
		else
			fcrot(0,0,(3.1415*.75)*ttf,.95+bm*.05,(t*2)%2)
		end
		--fcrot(0,0,0,1.05,0)
	end
	grts(bm)
end

function grts(c)
	local i=ttf%5
	c=c*10
	c=min(15,max(0,c))
	cprint("aldroid",W-W/4,H/5*((1+i)%5),c,2)
	cprint("aldroid",W-W/4+1,H/5*((1+i)%5),c,2)
	cprint("jtruk",W-W/4,H/5*((2+i)%5),c,2)
	cprint("jtruk",W-W/4+1,H/5*((2+i)%5),c,2)
	cprint("enfys",W-W/4,H/5*((3+i)%5),c,2)
	cprint("enfys",W-W/4+1,H/5*((3+i)%5),c,2)
	cprint("pumpuli",W-W/4,H/5*((4+i)%5),c,2)
	cprint("pumpuli",W-W/4+1,H/5*((4+i)%5),c,2)

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


function cprint(tx,x,y,c,s)
	local w=print(tx,0,-100,0,1,s)
	print(tx,x-w/2+s/2,y-s*2.5,c,1,s)
end	