W,H=240,136
STP=2
TYP=2
BPM=148

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

typN={"none","fire","blur","fade"}

f={}
frm=0

gray={}
for i=1,16*3,3 do
	i1=i
	i2=i+1
	i3=i+2
	gray[i1]=i/(16*3)*263
	gray[i2]=i/(16*3)*263
	gray[i3]=i/(16*3)*263
end
gray2={}
for i=1,16*3,3 do
	i1=i
	i2=i+1
	i3=i+2
	gray2[i1]=255-i/(16*3)*263
	gray2[i2]=255-i/(16*3)*263
	gray2[i3]=255-i/(16*3)*263
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
pntX=0
pntY=0
kX=0
kY=0
pnts={
{rnd(W),rnd(H)},
{rnd(W),rnd(H)},
{rnd(W),rnd(H)},
{rnd(W),rnd(H)},
{rnd(W),rnd(H)},
{rnd(W),rnd(H)},
{rnd(W),rnd(H)},
{rnd(W),rnd(H)},
{rnd(W),rnd(H)}
}

red={}
px={}
scr={}
function BOOT()
	for x=1,8 do
	for y=1,8 do
		m[y][x]=m[y][x]/64
	end
	end
	for x=0,W+8 do
		scr[x+1]={}
		px=scr[x+1]
		for y=0,H+8 do
			scr[x+1][y+1]=0
		end
	end
	cls()
	palset(0,gray)	
	palmuladd(0,gray,{4,1.8,.8},{0,-30,-30},1)
	palstore(0,red)
	palset(0,gray)
	--palmuladd(0,gray,{.8,.7,.3},{30,60,80},1)
	--palstore(0,green)
	--palmuladd(1,gray,{.7,.9,.2},{80,30,30},1)
	--palstore(1,red)
	--music(0,-1,-1,true,true)
end
BG=0

function post(typ,t,fr,ox,oy)
	vbank(1)
	if typ==0 then 
		for x=0,W do
			for y=0,H do
				mul(x,y,0,0,0)
			end
		end
	end
	if typ==1 then
		--	scr=blur(scr,1,fr)
		for xx=0,W,STP do
			for yy=0,H,STP do
				x=xx+fr%STP
				y=yy+(fr//STP)%STP
				mul(x,y,.96,rnd(-1,1)*ox,(rnd(-3,10)//5*oy)//1)
			end
		end
	elseif typ==2 then
		scr=blur(scr,1,fr,1)
		for xx=0,W,STP do
			for yy=0,H,STP do
				x=xx+fr%STP
				y=yy+(fr//STP)%STP
				mul(x,y,.95,ox,oy)--rnd(-1,1),rnd(-3,10)//5)
			end
		end
	elseif typ==3 then
		for xx=0,W,STP do
			for yy=0,H,STP do
				x=xx+fr%STP
				y=yy+(fr//STP)%STP
				mul(x,y,.9,ox,oy)--rnd(-1,1),rnd(-3,10)//5)
			end
		end
	else
		for xx=0,W,STP do
			for yy=0,H,STP do
				x=xx+fr%STP
				y=yy+(fr//STP)%STP
				mul(x,y,0,ox,oy)
			end
		end
	end
	cls()
end

function cumulate(b)
	local cb=vbank()
	vbank(b)
	for x=0,W-1 do
		for y=0,H-1 do
			c=peek4(x+y*W)
			add(x,y,c/16)
		end
	end
	vbank(cb)
end

function drawpoints()

	kX=lerp(kX,pnts[t//1%#pnts+1][1],.1)
	kY=lerp(kY,pnts[t//1%#pnts+1][2],.1)
	pntX=lerp(pntX,kX,.05)
	pntY=lerp(pntY,kY,.05)
	circ(pntX,pntY,3,15)
	for i=1,#pnts do
		pix(pnts[i][1],pnts[i][2],15)
	end
end

function drawscr()
	if TYP==0 then 	
		cls(BG)
	else
		for xx=0,W,STP do
			x=xx+fr%STP
			px=scr[x%#scr+1]
			for yy=0,H,STP do
				y=yy+(fr//STP)%STP
				c=px[y%#px+1]
				c=min(15,max(0,c))
				dit=dr(c,x,y,3)
				if dit>3 and TYP==1 then 
					vbank(1)
					pix(x,y,dit)
					vbank(0)
				end
				pix(x,y,dit)
			end
		end
	end
end

txt={"BANG","YOUR","DONK","ON","IT","OR","YOU","WILL"}

function TIC()
	s_t=time()
	frm=frm+1
	poke(0x3ffb,0)
	t=time()/60000*BPM--peek(0x13FFC+2)
	low=fft(0,32)
	hi=fft(128,512)*.3
	ti=t//1
	tf=t-ti
	if tf>=.5 then STP=4 else STP=2 end
	fr=dt(frm,STP)
	post(3,t,fr,low//1-hi//1,3-tf*6//1,0.1)
	post(1,t,fr,2-tf*2//1,0.1)
--	drawpoints()
	cprint(txt[t//1%#txt+1],W/2,H/4+tf*75,15-tf*15,1,12-tf*7)


	for x=0,W do
		f=vqt(x/2)*32
		c=min(15,f)
		line(x,H-8,x,H,c)
	end
	
	if TYP>0 then 
		cumulate(vbank())
	end
	cls()
	vbank(0)
	--BG=7.5+sin(t/1000)*8
	--cprint(txt[t//1%#txt+1],W/2,H/4+tf*75,3,1,12-tf*7)

	drawscr()
	d_t=time()-s_t
	vbank(0)
end

function BDR(i)
	local ff=vqt(H-i)*1.7
	palmix(0,gray,red,0.2+ff*.8)
	--palmix(0,green,red,fff*3)
	local dit=dr(max(0,min(15,BG)),0,i,3)
	poke(0x03FF8,dit)--BG)
end

--=====================================


function cprint(text,x,y,c,f,s,sm)
	local w=print(text,x,0-s*10,c,f,s//1,sm)
	print(text,x-w/2,y-(s//1)*4.5/2,c,f,s//1,sm)
end

function add(x,y,a)
	scr[x+1][y+1]=max(0,scr[x+1][y+1]+a)
end
function mul(x,y,a,ox,oy)
	local yy=max(0,min(H,(y+oy)))
	scr[x+1][y+1]=(scr[(x+ox)%W+1][yy+1]*a)
	if scr[x+1][y+1]<0.001 then scr[x+1][y+1]=0 end
end
function blur(scr,a,frm,s)
	local cr,br,ct=1.5*s,1.8*s,1.8*s
	local px,xx,yy,x,y,xxx,yyy=0,0,0,0,0
	if a==1 then
		for xxx=1,W,STP do
			for yyy=1,H,STP do
				x=xxx+frm%STP
				y=yyy+(frm//STP)%STP
				px=scr[x+1][y+1]*ct
				px=px+scr[x][y+1]*br
				px=px+scr[x+2][y+1]*br
				px=px+scr[x+1][y]*br
				px=px+scr[x+1][y+2]*br
				px=px/(br*4+ct)
				scr[x+1][y+1]=px
			end
		end
		return scr
	else
		local krn={
			{cr,br,cr},
			{br,ct,br},
			{cr,br,cr}}
		for x=1,W do
			for y=1,H do
				px=0
				for xx=1,3 do
				for yy=1,3 do
					px=px+scr[x+xx-1][y+yy-1]*krn[xx][yy]
				end
				end
				px=px/(cr*4+br*4+ct)
				scr[x+1][y+1]=px
			end
		end
		return scr
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
		if a>15 and a<16 then return ia end
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

function set1bpp()
 poke4(2 * 0x3ffc, 8) -- 0b1000
end

function set4bpp()
 poke4(2 * 0x3ffc, 2) -- 0b0010
end