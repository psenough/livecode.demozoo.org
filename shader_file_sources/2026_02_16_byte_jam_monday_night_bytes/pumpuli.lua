W,H=240,136
STP=1
GAIN=5.5
BPM=174


max=math.max
min=math.min
sin=math.sin
cos=math.cos
abs=math.abs
PI=math.pi
log=math.log
exp=math.exp
sqrt=math.sqrt
rnd=math.random
f={}
frm=0

gray={}
for i=1,16*3,3 do
	i1=i
	i2=i+1
	i3=i+2
	gray[i1]=(i/(16*3)*180)^1.8
	gray[i2]=(i/(16*3)*30)^2.8
	gray[i3]=(i/(16*3)*30)^2
end
for i=1,2*3,3 do
	i1=i
	i2=i+1
	i3=i+2
	gray[i1]=i/(16*3)*255
	gray[i2]=i/(16*3)*255
	gray[i3]=i/(16*3)*255
end
gray2={}
for i=1,16*3,3 do
	i1=i
	i2=i+1
	i3=i+2
	gray2[i1]=math.pow(sin(i/(16*3)*PI),6)*255
	gray2[i2]=math.pow(sin(i/(16*3)*PI),5)*255
	gray2[i3]=math.pow(sin(i/(16*3)*PI),4)*255
end



m={
{0 ,32,8 ,40,2 ,34,10,42},
{48,16,56,24,50,18,58,26},
{12,44,4 ,36,14,46,6 ,38},
{60,28,52,20,62,30,54,22},
{3 ,35,11,43,1 ,33,9 ,41},
{51,19,59,27,49,17,57,25},
{15,47,7 ,39,13,45,5 ,37},
{63,31,55,23,61,29,53,21}
}

hbc={
{0 ,1 ,14,15},
{3 ,2 ,13,12},
{4 ,7 ,8 ,11},
{5 ,6 ,9 ,10}
}
ft={}
green={}
red={}
for i=1,48 do
	green[i]=0
	red[i]=0
end

px={}

function BOOT()
	for x=0,511 do
		ft[x+1]=0
	end
	for x=1,8 do
	for y=1,8 do
		m[y][x]=m[y][x]/64
	end
	end
	for x=1,W+2 do
		px[x]={}
	for y=1,H+2 do
		px[x][y]=0
	end
	end
	cls()
	palset(0,gray)	
	palmuladd(0,gray,{1,1,1},{10,10,10},1)
	palstore(0,green)
	palmuladd(1,gray2,{.7,.9,.2},{80,30,30},1)
	palstore(1,red)
end

function TIC()
	frm=frm+1
	poke(0x3ffb,0)
	tim=time()
	t=time()/60000*BPM
	flc=fft(0,1024)
	low=fft(4,32)
	ti=t//1
	tfc=t-ti
	tf=ti+tfc^4
	fr=dt(frm,STP)
	for i=0,511 do
		vq=vr(i,1)
		vq=max(vq,ft[i+1]*.1)
		ft[i+1]=vq
	end
	
	post(fr,1)
	
	
	visu(fr,2)

	cprint(" IT'S LIT",W/2-1,H/2-3,low*4,false,5,false)
	cprint(" IT'S LIT",W/2+1,H/2-3,low*4,false,5,false)
	cprint(" IT'S LIT",W/2,H/2,0,false,5,false)
--	cprint(" IT'S LIT",W/2,H/2-6,low*4,false,5,false)
	cumulate(vbank(),fr,1,0)
--	cls()
	vbank(0)
	drawscr(px,1)
end

function BDR(i)
	local fff=vqt(H+10-i)
	--palmix(0,green,red,fff*3)
end

--=====================================
function visu(fr,st)
	for xx=0,W,st do
			x=xx+fr%st
			X=x/W
			c=ft[x//2+1]*.5
			line(x,H,x,H-min(6*4,c*.15),15)
			line(x+1,H,x+1,H-min(6*4,c*.15),15)
	end
end

function post(fr,st)
	for xx=0,W,st do
			for yy=0,H,st do
				x=xx+fr%st
				y=yy+(fr//st)%st
				f=vr(x//2,1)
				ox=rnd(-f//40,f//40+1)
				mul(x,y,.66+min(0.05,f*.0005),0,6-min(4,f//40))--rnd(-1,1),rnd(-3,10)//5)
				add(x,y,-.02)
			end
		end
end

function drawscr(scr,st)
	for xx=0,W,st do
		x=xx+fr%st
		pt=scr[x%#scr+1]
		for yy=0,H,st do
			y=yy+(fr//st)%st
			c=pt[y%#pt+1]
			c=min(15,max(0,c))
			dit=dr(c,x,y,3)
			pix(x,y,dit)
		end
	end
end

function cumulate(b,fr,st,a)
	local cb=vbank()
	vbank(b)
	for xx=0,W-1,st do
		for yy=0,H-1,st do
			x=xx+fr%st
			y=yy+(fr//st)%st
			c=peek4(x+y*W)
			if a==0 then
				add(x,y,c/4)
			else
				add(x,y,-c/4)
			end
		end
	end
	vbank(cb)
end

function add(x,y,a)
	px[x+1][y+1]=max(0,px[x+1][y+1]+a)
end
function mul(x,y,a,ox,oy)
	px[x+1][y+1]=(px[(x+ox)%W+1][(y+oy)%H+1]*a)
	if px[x+1][y+1]<0.001 then px[x+1][y+1]=0 end
end
function cprint(text,x,y,c,f,s,sm)
	local w=print(text,x,0-s*10,c,f,s//1,sm)
	print(text,x-w/2,y-(s//1)*4.5/2,c,f,s//1,sm)
end

function vr(f,a)
	if a==0 then 
		local vtr=vqt(f)*GAIN*200
		local ftr=fft(f*5,f*5+1)*GAIN*200
		return lerp(vtr,ftr,f/(W*.8))
	end
	if a==1 then 
		local vtr=vqtw(f)*GAIN*200
		return vtr
	end
	if a==2 then 
		local ftr=fft(f*5,f*5+1)*GAIN*200
		return ftr
	end
end	

function lerp(a,b,t)
	return a+t*(b-a)
end

function dt(f,s)
	local out=f
 local si=s//1
 local lu2={0,2,3,1}
 if s==2 then
 	out=lu2[f//1%#lu2+1]
 end
 local lu3={0,4,7,1,5,8,2,6,3}
 if s==3 then 
 	out=lu3[f//1%#lu3+1]
 end
 local lu4={0 ,8 ,2 ,10,
 											12,4 ,14,6 ,
            3 ,11,1 ,9 ,
            15,7 ,13,5}
 						--[[{0 ,5 ,2 , 7
           ,8 ,13,10,15
           ,3 ,6 ,11,14
           ,1 ,4 ,9 ,12}
       --[[{0 ,1 ,2 , 3
           ,4 ,5 ,6 , 7
           ,8 ,9 ,10,11
           ,12,13,14,15}--]]
 local lu8={0 ,32,8 ,40,2 ,34,10,42,
											48,16,56,24,50,18,58,26,
											12,44,4 ,36,14,46,6 ,38,
											60,28,52,20,62,30,54,22,
											3 ,35,11,43,1 ,33,9 ,41,
											51,19,59,27,49,17,57,25,
											15,47,7 ,39,13,45,5 ,37,
											63,31,55,23,61,29,53,21}
 if s==4 then 
 	out=lu4[f//1%#lu4+1]
 end
 if s>4 and s<=8 then
 	out=lu8[f//1%#lu8+1]
 end
	return out
end

function dr(a,x,y,t)
	local ia=a//1
	if t==2 then
		local fa=a-ia
		local my=hbc[y%#hbc+1]
		local mp=my[x%#my+1]
		if mp>=fa then return ia else return ia+1 end
	end
	if t==1 then
		local fa=a-ia
		local my=m[y%#m+1]
		local mp=my[x%#my+1]
		if mp>=fa then return ia else return ia+1 end
	end
	if t==3 then
		if a>11 and a<13.5 then return ia end
		local fa=a-ia
		local my=m[y%#m+1]
		local mp=my[x%#my+1]
		if mp>=fa then return ia else return ia+1 end
	end
	return ia
end


function palset(bnk,pal)
	local curbnk=vbank()
	vbank(bnk)
	loadpal(pal)
	vbank(curbnk)
end
function palmul(bnk,pal,mul,a)
	local curbnk=vbank()
	vbank(bnk)
	loadpal2(pal,mul,a)
	vbank(curbnk)
end
function palmuladd(bnk,pal,mul,add,a)
	local curbnk=vbank()
	vbank(bnk)
	loadpal4(pal,mul,add,a)
	vbank(curbnk)
end
function paladd(bnk,pal,mul,a)
	local curbnk=vbank()
	vbank(bnk)
	loadpal3(pal,mul,a)
	vbank(curbnk)
end
function loadpal(pal)
 for i=1,48 do
  poke(0x3fc0+i-1,pal[i])
 end
end
function loadpal2(pal,mul,a)
	for i=1,16*3,3 do
		i1=i
		i2=i+1
		i3=i+2
		if a==1 then
			poke(0x3fc0+i1-1,max(0,min(255,pal[i1]*mul[1])))
			poke(0x3fc0+i2-1,max(0,min(255,pal[i2]*mul[2])))
			poke(0x3fc0+i3-1,max(0,min(255,pal[i3]*mul[3])))
		else
			poke(0x3fc0+i1-1,pal[i1]*mul[1])
			poke(0x3fc0+i2-1,pal[i2]*mul[2])
			poke(0x3fc0+i3-1,pal[i3]*mul[3])
		end
	end
end
function loadpal3(pal,mul,a)
	for i=1,16*3,3 do
		i1=i
		i2=i+1
		i3=i+2
		if a==1 then
			poke(0x3fc0+i1-1,max(0,min(255,pal[i1]+mul[1])))
			poke(0x3fc0+i2-1,max(0,min(255,pal[i2]+mul[2])))
			poke(0x3fc0+i3-1,max(0,min(255,pal[i3]+mul[3])))
		else
			poke(0x3fc0+i1-1,pal[i1]+mul[1])
			poke(0x3fc0+i2-1,pal[i2]+mul[2])
			poke(0x3fc0+i3-1,pal[i3]+mul[3])
		end
	end
end
function loadpal4(pal,mul,add,a)
	for i=1,16*3,3 do
		i1=i
		i2=i+1
		i3=i+2
		if a==1 then
			poke(0x3fc0+i1-1,max(0,min(255,pal[i1]*mul[1]+add[1])))
			poke(0x3fc0+i2-1,max(0,min(255,pal[i2]*mul[2]+add[2])))
			poke(0x3fc0+i3-1,max(0,min(255,pal[i3]*mul[3]+add[3])))
		else
			poke(0x3fc0+i1-1,pal[i1]*mul[1]+add[1])
			poke(0x3fc0+i2-1,pal[i2]*mul[2]+add[2])
			poke(0x3fc0+i3-1,pal[i3]*mul[3]+add[3])
		end
	end
end
function palstore(bnk,pal)
	local curbnk=vbank()
	vbank(bnk)
	savepal(pal)
	vbank(curbnk)
end
function savepal(pal)
	for i=1,48 do
		pal[i]=peek(0x3fc0+i-1)
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

function rgb2hsv(ir,ig,ib,ga)
	local r,g,b=ir/ga,ig/ga,ib/ga
	local h,s,v=0,0,0
	local lmax=max(r,g,b)
	local lmin=min(r,g,b)
	v=lmax
	
	if lmax==0 or lmax-lmin==0 then
		s,h=0,0
	else
		s=(lmax-lmin)/lmax
		if lmax==r then
			h=60*((g-b)/(lmax-lmin))+0
		elseif lmax==g then
			h=60*((b-r)/(lmax-lmin))+120
		else
			h=60*((r-g)/(lmax-lmin))+240
		end
	end
	if h<0 then h=h+360 end
	
	return h/2,s*255,v*255
end


function hsv2rgb(ih,is,iv,ga)
	local h,s,v=(ih%180)*2,is/255,iv/255
	local r,g,b=0,0,0
	local hi=(h//60)%6
	local f =(h/60)-hi
	local p =v*(1-s)
	local q =v*(1-s*f)
	local t =v*(1-s*(1-f))
	
	if hi==0 then 
		r,g,b=v,t,p 
	elseif hi==1 then
		r,g,b=q,v,p 
	elseif hi==2 then
		r,g,b=p,v,t
	elseif hi==3 then
		r,g,b=p,q,v 
	elseif hi==4 then
		r,g,b=t,p,v 
	elseif hi==5 then
		r,g,b=v,p,q
	end

	return r*ga,g*ga,b*ga
end