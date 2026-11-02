W,H=240,136
STP=2
GAIN=5.5


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

blue={
26,28,44,28,32,53,
31,35,62,33,39,72,
35,43,81,37,46,91,
38,47,93,39,51,102,
41,54,111,59,93,201,
65,116,246,115,239,247,
244,244,244,148,176,194,
86,108,134,51,60,87}


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
bluewhite={
0xff,0xff,0xff,0xff,0xff,0xff,
31,35,62,33,39,72,
35,43,81,37,46,91,
38,47,93,39,51,102,
41,54,111,59,93,201,
65,116,246,115,239,247,
244,244,244,148,176,194,
0xff,0xff,0xff,0xff,0xff,0xff}




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
pxc={}
ft={}
function BOOT()
	for y=1,H+1 do
		pxc[y]={}
		for x=1,W+1 do
			pxc[y][x]=0
		end
	end
	for x=0,511 do
		ft[x+1]=0
	end
	for x=1,8 do
	for y=1,8 do
		m[y][x]=m[y][x]/64
	end
	end
	cls()
	palset(0,blue)
end

function TIC()
	frm=frm+1
	poke(0x3ffb,0)
	tim=time()
	t=time()/60000*(170)
	flc=fft(0,1024)
	low=fft(4,32)
	ti=t//1
	tfc=t-ti
--	palmix(0,blue,bluewhite,tfc>.9 and min(1,1*low) or 0)
	tf=ti+tfc^4
	fr=dt(frm,STP)
	for i=0,511 do
		vq=vr(i,0)
		vq=max(vq,ft[i+1]*.4)
		ft[i+1]=vq
	end
	for xx=0,W,STP do
		for yy=0,H,STP do
			x=xx+fr%STP
			y=yy+(fr//STP)%STP
			pp=pxc[y%#pxc+1]
			c=pp[x%#pp+1]
			X=x/W-.4
			Y=y/W-.3
			X,Y=rot(X,Y,-PI/2)--+low*4*sin((X*4+t*.005)*40+low*.2)*.01)
			l=X*X+Y*Y
			X,Y=zom(X,Y,1+vqt(l*W)*PI/4*(l%2-1)*.1)			
			_X=X
			_Y=Y
			z=Y>0 and 1 or 0
			for i=0,5 do
				X=abs(X)-.05-i*.01
				Y=abs(Y)-.05
				X,Y=rot(X,Y,t*PI/7+X)
			end
			--X,Y=rot(X,Y,X+tf*PI/2)
			fq=abs(X)--max(abs(X),abs(Y))
			ff=0
			ff=ff+((l<low*.03 and l>low*.015) and 4 or 0)
			ff=ff+(flc*.08+low*.1)*.01*ft[((fq*W)//1)%#ft+1]*(1-_Y*4)
		--	ff=ff+.01*ft[(((l)*W*2)//1)%#ft+1]*(1+_Y*2)
			c=c+ff*.6*(.3/abs(_Y))--ff*.01*((ff*Y)*.1)
			c=min(max(0,abs(c)),12-max(0,_Y*7))--*rnd(1,2)))
			c=max(0,c)
			dit=dr(c,x,y,3)
			pix(x,y,dit)
			pxc[(y)%#pxc+1][x%#pxc[(y)%#pxc+1]+1]=c*.8--*rnd(1,2)
		end
	end
	
	
	
	
end


function vr(f,a)
	if a==0 then 
		local vtr=vqt(f)*GAIN*200
		local ftr=fft(f*5,f*5+1)*GAIN*200
		return lerp(vtr,ftr,f/(W*.8))
	end
	if a==1 then 
		local vtr=vqt(f)*GAIN*200
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


