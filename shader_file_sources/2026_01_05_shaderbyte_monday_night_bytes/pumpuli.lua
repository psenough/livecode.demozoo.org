W,H=240,136
STP=2
GAIN=1.5

max=math.max
min=math.min
sin=math.sin
cos=math.cos
abs=math.abs
PI=math.pi
log=math.log
exp=math.exp
sqrt=math.sqrt
f={}
frm=0



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


green={
26,44,28,
28,53,32,
31,62,35,
33,72,39,
35,81,43,
37,91,46,
38,93,47,
39,102,51,
41,111,54,
59,201,93,
65,246,116,
115,247,239,
244,244,244,
148,194,176,
86,134,108,
51,87,60}

white={
0xff,0xff,0xff,0xff,0xff,0xff,
0xff,0xff,0xff,0xff,0xff,0xff,
0xff,0xff,0xff,0xff,0xff,0xff,
0xff,0xff,0xff,0xff,0xff,0xff,
0xff,0xff,0xff,0xff,0xff,0xff,
0xff,0xff,0xff,0xff,0xff,0xff,
0xff,0xff,0xff,0xff,0xff,0xff,
0xff,0xff,0xff,0xff,0xff,0xff
}

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
function BOOT()
	cls()
	local x,y=0,0
	for x=0,W do
		f[x+1]=0
	end
	for x=0,255 do
		ft[x+1]=0
	end
	for x=1,8 do
	for y=1,8 do
		m[y][x]=m[y][x]/64
	end
	end
	palset(0,blue)
	palset(1,blue)
end
cff={}
xo=0
yo=0
ox=0
xx=0
function TIC()
	poke(0x3ffb,0)
	tim=time()
	t=time()/60000*175
	ti=t//1
	tfc=t-ti
	tf=ti+tfc^4
	--if tim-tim//1<.5 then
	local x,y,xx,yy=0,0,0,0
	frm=frm+1
--	cls()
	for i=0,W*(H-1) do
	--	poke4(i,peek4(i+W))
	end
	fr=dt(frm,STP)
	for xx=0,W,STP do
		for yy=0,H,STP do
			x=xx+fr%STP
			y=yy+(fr//STP)%STP
			X=x/W-.5
			Y=y/H-.5
			l=X*X+Y*Y
			l=sqrt(l)*(1-Y/2)
			ff=f[(W/2+l*W/2)//1%#f+1]
			X,Y=zom(X,Y,1-(ff)*.002)
			X,Y=rot(X,Y,PI*(f[(l*W)//1%#f+1])*.0008)
			X,Y=rot(X,Y,x/(H+ff*.02)+t*.1)
			X,Y=rot(X,Y,tf*.1)
			l=min(abs(X),abs(Y))
			Xi=l//1
			Xf=(l-Xi)
			c=Xi+Xf
			if ((Y*H+6+ff*.1)//8)%2==((X*W+8)//16)%2 then
				dit=0.25+ff*.2
			else
				dit=ff*.1
			end
			ver=lerp(f[x%#f+1]/3/(1+l),0,min(1,max(0,(y-H/2)/H*4)))
			dit=lerp(dit,ver*2,(l*1.5+0.2/(1+abs(x/W-.5))))--vqtr(x*.5)/20
			dit=dit*(.8+.5*sin(tf+X*8+sin(Y-tf)))
			
			dit=dr(dit,x,y,3)
			pix(x,y,min(dit,12))
		end
	end
	for i=0,511 do
		ft[i+1]=fft(i)
	end
	for x=0,W do
		X=x/W
		fq=abs(x-W/2)+10
		fq=fq*1.2
		vq=vr(fq)
--		if x%2==0 then vq=vq*-1 e
		vq=max(vq,f[x+1]*.85)
		--*((0.3/5)*log((1+fq),12/5))
		f[x+1]=vq
		c=min(f[x+1],12)
		--line(x,H,x,H-f[x+1]/8,c)
	end
	--end
	--[
	vbank(1)
	for i=0,W*(H) do
		x=i%H
		poke4(i,peek4(i+W*((f[x%#f+1]*.05)//1))*(.3+math.random(10)/10))
	end
	rect(0,H-3,W,5,0)
	
--	if tfc>.1 then 
	rn=math.random(40)
		w=print("SHADE",0,-100,12,1,5)
		x=W/2+(ti*W*(.7*ti*.1))%(W-w)-W/3
		y=H/2+(ti*99)%(H/6*4)+(1-tf-ti)*10
		if tfc>.05 and tfc<.25 then 
			print("SHADE",x-w/2,(y-6*5*(1+ti*4.2))%H,12,1,5)
			print("SHADE",x-w/2+rn,(y-6*10*(1+ti*4.2))%H,12,1,5)
			print("SHADE",x-w/2-rn,(y-6*15*(1+ti*4.2))%H,12,1,5)
			print("SHADE",x-w/2+rn*4,(y-6*20*(1+ti*4.2))%H,12,1,5)
		end
		x=x+(ti%7)*40
		if tfc>.4 and tfc<.5 then
			print(" YOUR" ,x-w/2-3*5,y,12,1,5)
			print(" YOUR" ,x-w/2-3*5+rn,y-6*5,12,1,5)
			print(" YOUR" ,x-w/2-3*5-rn,y-6*10,12,1,5)
			print(" YOUR" ,x-w/2-3*5+rn*4,y+6*5,12,1,5)
		end
		x=x-(ti%6)*40
		if tfc>.75 and tfc<.9 then 
			print(" TIC"  ,x-w/2,(y+6*5*(1+ti*3))%H,12,1,5)
			print(" TIC"  ,x-w/2+rn,(y+6*15*(1+ti*3))%H,12,1,5)
			print(" TIC"  ,x-w/2-rn,(y+6*25*(1+ti*3))%H,12,1,5)
			print(" TIC"  ,x-w/2+rn*8,(y+6*10*(1+ti*3))%H,12,1,5)
		end
	--end
	
	vbank(0)
	--]]
end	

function BDR(i)
	local ff=vr(H+8-i)
	palmix(0,blue,green,ff*.01)
	--palmix(1,blue,white,-ff*.008)
end

function vr(f)
	local vtr=vqt(f)*GAIN*200
	local ftr=fft(f*5,f*5+1)*GAIN*200
	
	return lerp(vtr,ftr,f/(W*.8))
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


