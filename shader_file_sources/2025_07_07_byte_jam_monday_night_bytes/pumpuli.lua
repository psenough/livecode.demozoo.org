W,H=240,136
STP=4
min=math.min
max=math.max
exp=math.exp
log=math.log
abs=math.abs
rnd=math.random
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


function BOOT()
	for x=0,W do
		f[x+1]=0
		lf[x+1]=0
	end
	palset(0,orange2)
	palset(1,orange2)
end
frm=0
fr=0
BPM=174
function TIC()
	frm=frm+1
	
 fr=dt(frm,STP)
 t=time()/60000*BPM
 flc=fft(0,1024)
 blur(fr,STP,8)
 for x=0,W do
 for y=0,H do
 	i=x+y*W%0x7f80-1
  of=W+W*(6-(abs(y/H-.5)*8//1)*2)
 -- of=of-(x/H-1)*4*(y>H/2 and -1 or 1)
  if y>=H/2 then 
			p=peek4(i-of)
		else
			p=peek4(i+of)
		end
  poke4(i+0x8000,p)
 end
 end
 for i=0,0x7f80 do
 	poke4(i,peek4(i+0x8000))
 end
 vbank(0)
 for xx=0,W do
 	i=xx+1
  x=xx*2+frm%2
  v=fftr(x)
  fq=exp(x/H*6)
  fq2=exp(x/H*5)
  vs=fftr(fq-1,fq+1)*(exp(x/H*3)/2000)
  vs=math.pow(vs,1.5)
 	vr=vqtr(x/1.28)
  vrs=vqtrs(x/2)   
  vs2=vr/vrs
  vs2=1-vs2
  f[i]=f[i]+vr*1
  c1=max(0,min(12,f[i]/16))
  c2=max(0,min(12,vr/16))
  c=fq>10000 and c1 or c2
 -- line(x,H/2-f[i],x,H/2+f[i],c)
 	if c>0 then 
 	line(W/2+x/H*W/2,H/2,W/2+x/H*W/2,H/2+3,c)
 	line(W/2-x/H*W/2,H/2,W/2-x/H*W/2,H/2+3,c)
 	line(W/2+x/H*W/2,H/2-1,W/2+x/H*W/2,H/2-3,c)
 	line(W/2-x/H*W/2,H/2-1,W/2-x/H*W/2,H/2-3,c)
  end
 end 
 vbank(1)
 --cls()
 for i=0,W*H,STP do
 	i=i+frm%STP
 	if rnd(100)<70 then 
 	poke4(i,max(0,peek4(i+rnd(-2,2))-4))
  end
 end
 for x=0,W do
 	i=x//2+1
 	c=f[i]/16
  yy=c
  c=min(15,c)
  xx=x/H*W/2
 	line(W/2-xx,H/2-yy,W/2-xx,H/2+yy,17-c/3)
 	line(W/2+xx,H/2-yy,W/2+xx,H/2+yy,17-c/3)
 end
 vbank(0)
	for x=0,W do
		i=x+1
	 lf[i]=0
	end
	for x=0,W do
		i=max(0,min(#f-1,(x+1)))+1
		ip=max(0,min(#f-1,(x)))+1
		ix=max(0,min(#f-1,(x+2)))+1
		lf[i]=0
		--lf[i]=f[i]*(3/4)
		lf[i]=((f[ip]+f[i]+f[ix])/4)
	end
	for x=0,W do
		i=x+1
	 f[i]=lf[i]
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

