-- mantratronic + jtruk here
-- greets to HeNeArXn, Aldroid, Catnip

M=math
S=M.sin
C=M.cos
A=M.abs
function rot(x,y,a)
 return {x*C(a)-y*S(a),y*C(a)+x*S(a)}
end
cls(12)	

T=0
fftm={}
fftn={}
for i=0,255 do
	fftm[i]=0
	fftn[i]=0
end
LA={}
nLA=10
for i=1,nLA do
LA[i]={x=0.1+i,y=0,z=0,a=10,b=28,c=8/3,dt=0.005}
end

ARCS={}

function addArc(s,a,aDelta,c)
	ARCS[#ARCS+1]={s=s,a=a,aDelta=aDelta,c=c}
end

function BOOT()
	for i=0,20 do
	 local s=i*.5
		local aDelta=.05*((math.random(200)/100)-1)
	 local a=i*.1
		local c=i
		addArc(s,a,aDelta,c)
	end

	vbank(0)
	setRGB(0,0,0,0)

	vbank(1)
	setRGB(1,0,0,0)
end


function mBDR(y)
 vbank(0)
 local ry=S(y/200+T/100)*48+48
 local gy=S(y/200+T/100+2)*48+48
 local by=S(y/200+T/100+4)*48+48
 for i=12,15 do
  poke(0x3fc0+i*3, (i-12)/2.1*ry)
  poke(0x3fc0+i*3+1, (i-12)/2.1*gy)
  poke(0x3fc0+i*3+2, (i-12)/2.1*by)
 end
 for i=1,5 do
 poke(0x3fc0+i*3, (i/11+1)*by)
 poke(0x3fc0+i*3+1, (i/11+1)*ry)
 poke(0x3fc0+i*3+2, (i/11+1)*gy)
 end
 for i=6,11 do
 poke(0x3fc0+i*3, (i/11+1)*gy)
 poke(0x3fc0+i*3+1, (i/11+1)*by)
 poke(0x3fc0+i*3+2, (i/11+1)*ry)
 end
end
function mTIC()
 vbank(0)
 memcpy(0x8000,0,120*136)
	cls(12)	
 memcpy(120,0x8000,120*135)
	for x=0,240 do
		pix(x,y,12+fftn[x]*3)
	end
	
	for i=0,99 do
	 local x=M.random(240)-1
	 local y=M.random(136)-1
		local col = pix(x,y)
		if col <13 then
 		circb(x,y,2,col)
  end
	end
	
	-- this will take some looking up
	for i=1,nLA do
	 for j=1,fftn[(i/nLA*10)//1]*5+1 do
 	 local xt = LA[i].x + LA[i].dt*LA[i].a*(LA[i].y-LA[i].x)
 		local yt = LA[i].y + LA[i].dt*(LA[i].x*(LA[i].b-LA[i].z)-LA[i].y)
 		local zt = LA[i].z + LA[i].dt*(LA[i].x*LA[i].y-LA[i].c*LA[i].z)
 		LA[i].x=xt
 		LA[i].y=yt
 		LA[i].z=zt
 		local P=rot(LA[i].x,LA[i].y, T/100+i/nLA*2*M.pi)
 		local sx=P[1]*3
 		local sy=P[2]*2.5
 		
 		circ(sx+120,sy+68,1+LA[i].z/50,i+1)
  end
	end
end


function BDR(y)
 mBDR(y)
 jBDR(y)
end


function TIC()
	T=time()/100
	for i=0,255 do
		fftm[i]=M.max(fftm[i]-0.0001*(1-(i+1)/256)^2,fft(i))
		fftn[i]=(fft(i)/fftm[i])*.2 + fftn[i]*.8
	end

 mTIC()
 jTIC()
end


function jBDR(y)
	vbank(1)
	for i=2,15 do
		local f=1-(i/15)
		local r=(127+S(i*.2+y*.007+T/10)*127)*f
		local g=(127+S(1+i*.24+y*.009-T/12)*127)*f
		local b=(127+S(2+i*.3+y*.008+T/15)*127)*f
		setRGB(i,r,g,b)
	end
end

function jTIC()
	updateArcs()
	vbank(1)
	cls(0)
	
	for i,arc in ipairs(ARCS) do
		drawArc(arc)
	end
end

function updateArcs()
 for i,arc in ipairs(ARCS) do
		arc.a=arc.a+arc.aDelta
 end
end

function drawArc(arc)
 local dMax=40+S(getSeed(arc,8))*30
	local steps=20
 local w,h=30,30
	local arcInc=(6.28-2)/steps
 for r=1,12 do
 	local z=1.03+getSeed(arc,30)*.05
  local d=dMax/r^z
	 local ps={}
	 for i=0,steps do
			local a=arc.a+i*arcInc+r
			local d1=d
			local d2=d1+d1*.05
			local x=S(getSeed(arc,10))
			local y=S(getSeed(arc,12))
			local o=S(getSeed(arc,22))*5
			ps[#ps+1]={
				i=getP(x,y,a,d1,o),
				o=getP(x,y,a,d2,o)
			}
	 end
	
	 local c=1+r+arc.c
		for i=2,#ps do
		 local ps1=ps[i-1]
		 local ps2=ps[i]
			tri(
				120+ps1.i.x*w,68+ps1.i.y*h,
				120+ps1.o.x*w,68+ps1.o.y*h,
				120+ps2.i.x*w,68+ps2.i.y*h,
				c
			)
			tri(
				120+ps1.o.x*w,68+ps1.o.y*h,
				120+ps2.i.x*w,68+ps2.i.y*h,
 			120+ps2.o.x*w,68+ps2.o.y*h,
				c
			)
		end
	end
end

function getP(x,y,a,d,o)
	p=rot(x,y,o)
	return {
	 x=p[1]+S(a)*d,
	 y=p[2]+C(a)*d,
	}
end

function getSeed(arc,div)
	return (T-arc.s)/div
end

function setRGB(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end
-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

