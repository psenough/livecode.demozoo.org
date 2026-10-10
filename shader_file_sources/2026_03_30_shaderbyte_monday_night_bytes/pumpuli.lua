W,H=240,136
STP=1
GAIN=3.5
BPM=174

str=string
char=str.char
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
gray2={}
green={}
red={}
white={}
for i=1,16*3,3 do
	i1=i
	i2=i+1
	i3=i+2
	gray[i1]=i/(16*3)*255
	gray[i2]=i/(16*3)*255
	gray[i3]=i/(16*3)*255
	green[i1]=i/(16*3)*255
	green[i2]=i/(16*3)*255
	green[i3]=i/(16*3)*255
	red[i1]=i/(16*3)*255
	red[i2]=i/(16*3)*255
	red[i3]=i/(16*3)*255
	white[i1]=i/(16*3)*255
	white[i2]=i/(16*3)*255
	white[i3]=i/(16*3)*255
	gray2[i1]=math.pow(sin(i/(16*3)*PI),6)*255
	gray2[i2]=math.pow(sin(i/(16*3)*PI),5)*255
	gray2[i3]=math.pow(sin(i/(16*3)*PI),4)*255
end


px={}
ft={}

function BOOT()
	for x=0,511 do
		ft[x+1]=0
	end
	for x=1,W+2 do
		px[x]={}
		for y=1,H+2 do
			px[x][y]=0
		end
	end
	cls()
	palset(0,gray)
--	palmuladd(1,gray2,{.7,.9,.2},{80,30,30},1)
	palset(1,gray)
end
offs=0

function TIC()
	offs=0
	bytejam_base("           littletheremin           ",BPM)
end

function BDR(ii)
	BDR_39(ii)
end

--=====================================
-- 'fuller' combinations of things
--=====================================


function bytejam_base(txt,bpm)
	audiosync(bpm)
	vbank(1)
	post(fr,1)
	
	hfft(true,4)
	
	
	for y=0,80,10 do
		charfft(txt,11,11+y,13-y/6,1,1)
	end
	cumulate(vbank(),fr,1,0,1)
	cls()
	
	hfft(false,15)
	for y=0,80,10 do
		charfft(txt,10,10+y,15-y/5,1,1)
	end
	cumulate(vbank(),fr,1,1,max(0.2,2-low/4))
	cls()
	
	invader(W/2+sin(tf/4)*W/3,H-H/6-low*10,16,15)
	
	cumulate(vbank(),fr,1,0,.5)
	cls()
	
	vbank(0)
	drawscr(px,2)
	
		
	charfft(txt,11,11,15,1,1)
	charfft(txt,10,10,0+low*2,1,1)
	
end

function BDR_39(ii)
	local i=H-ii+10
	local fff=vqt(i)	
	offs=offs+fff*.2
	
	palmuladd(0,gray,{0+(i*.01)+offs*.2+fff*4,1+offs*.2,1+i*.01},{i/10,i/10,i/10},1)
	palstore(0,green)
	palmix(0,green,white,fff*fff*.1)
	local im=i%2==0 and 1 or -1

	poke(0x3ff9,ft[(i)//1%#ft+1]/100*im+(offs+fff)*2*sin(i//10*(1+fff)+t))
end

function BDR_316(ii)
	local i=abs(H/2-ii+10)
	local fff=vqt(i)	
	offs=offs+fff*.2
	local odd=i%2==0 and -1 or 1

	local fff=vqtw(H+10-i)
	
	local cm={0+(i*.01)+offs*.2+fff*4,1+offs*.2,1+i*.01}

	cm[1],cm[2],cm[3]=
	rgb2hsv(cm[1],cm[2],cm[3],1)
	cm[1],cm[2],cm[3]=
	hsv2rgb(cm[1],cm[2],cm[3],1)
	cm[1]=(cm[1]+ti//2*(.5))%4
	cm[2]=cm[2]*2
	palmuladd(0,gray,cm,{i/10,i/10,i/10},1)
	palstore(0,green)
	--palmix(0,green,white,fff*fff*.1)
	palmix(0,green,red,fff*3)
	poke(0x3ff9,fff*3+offs*(1+fff*4)*odd+odd*(ii+40)/H*offs*sin(ii/10+t*10))
end

--=====================================
-- more generic tooling
--=====================================

function audiosync(bpm)
	frm=frm+1
	poke(0x3ffb,0)
	tim=time()
	t=time()/60000*bpm
	flc=fft(0,1024)
	low=fft(4,32)
	ti=t//1
	tfc=t-ti
	tf=ti+tfc^4
	fr=dt(frm,STP)
	for i=0,511 do
		vq=vr(i,1)
		ft[i+1]=vq
	end
end

function invader(x,y,s,c)
	local i=0
	for i=-4,4 do
		line(x+i,0,x+i,y,max(0,min(15,low*(5-abs(i*2))+(2-abs(i)))))
	end
	rect(x-s/6,y-s/4,s/3,s/2,c)
	rect(x-s/2,y,s,s/2,c)
end

function charfft(txt,x,y,c,b,s)
	local t,i,l="",0,str.len(txt)
	for i=1,l do
		f=fftr(i/l*512,(i-1)/l*512)*0.2
		ch=str.byte(txt,i)
		t=t..str.char(min(255,ch+f//1))
	end
	
	print(t,x,y,c,b,s)
end

function nfft(a,c2,fr,stp)
	local xx,x,yy,y,X,Y=0,0,0,0,0,0

	for xx=0,W,stp do
		for yy=0,H,stp do
			x=xx+fr%STP
			y=yy+(fr//STP)%STP
			X=x/W-0.7
			Y=y/W-0.3
			X,Y=rot(X,Y,0.4)
			fq=min(abs(X),abs(Y))*120
			c=vr(fq-1,1)
			if a then 
			pix(x,y,c)
			else
			pix(x,y,15-c)
			end
		end
	end
end


function vfft(a,c2)
	for x=0,W do
		c=ft[x//2%#ft+1]
		if c>16 and a then 
			line(x,0,x,H,c2)
		end
		if c<16 and not a then
			line(x,0,x,H,c2)
		end
	end
end

function hfft(a,c2)
	for y=0,H do
		c=ft[y//2%#ft+1]
		if c>16 and a then 
			line(0,y,W,y,c2)
		end
		if c<16 and not a then
			line(0,y,W,y,c2)
		end
	end
end

function post(fr,st)
	for xx=0,W,st do
			for yy=0,H,st do
				x=xx+fr%st
				y=yy+(fr//st)%st
				f=vr(y//2,1)
				ox=rnd(-3,3*f//20)*4
				oy=rnd(-3,3)*.1
				mul(x,y,.9,(ox+1)//2,4+(oy+1)//2+f//80)--rnd(-3,10)//5)
				--add(x,y,-.02)
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

function cumulate(b,fr,st,a,m)
	local cb=vbank()
	vbank(b)
	for xx=0,W-1,st do
		for yy=0,H-1,st do
			x=xx+fr%st
			y=yy+(fr//st)%st
			c=peek4(x+y*W)
			if a==0 then
				add(x,y,c/4*m)
			else
				add(x,y,-c/4*m)
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
		local vtr=vqtw(f)*GAIN*200
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
	if a==3 then 
		local vtr=vqtrw(f)*GAIN*15
		return vtr
	end
	return 0
end	

function lerp(a,b,t)
	return a+t*(b-a)
end

-- "dithered" frame numberig
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

-- dithered color from a float
function dr(a,x,y,t)
	local m={
	{0 ,32,8 ,40,2 ,34,10,42},
	{48,16,56,24,50,18,58,26},
	{12,44,4 ,36,14,46,6 ,38},
	{60,28,52,20,62,30,54,22},
	{3 ,35,11,43,1 ,33,9 ,41},
	{51,19,59,27,49,17,57,25},
	{15,47,7 ,39,13,45,5 ,37},
	{63,31,55,23,61,29,53,21}
	}
	local hbc={
	{0 ,1 ,14,15},
	{3 ,2 ,13,12},
	{4 ,7 ,8 ,11},
	{5 ,6 ,9 ,10}
	}
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
		local mp=my[x%#my+1]/64
		if mp>=fa then return ia else return ia+1 end
	end
	if t==3 then
		if a>11 and a<13.5 then return ia end
		local fa=a-ia
		local my=m[y%#m+1]
		local mp=my[x%#my+1]/64
		if mp>=fa then return ia else return ia+1 end
	end
	return ia
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

--=====================================
-- Palette things
--=====================================

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