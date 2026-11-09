-- ByteJam at Field-FX/EMF 2024
-- Greetz:    ^
-- lsquared, tobach, wbcbz7
-- aldroid, Stormcaller, Violet
-- and YOU!
-- Built with Alice fork v0.0.5

M=math
S,C,PI=M.sin,M.cos,M.pi
TAU=PI*2
ABS=M.abs
T=0

O1=0
O2=0
O3=0

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

function BDR(y)
	vbank(0)
	rgb(0,O1*255,O2*255,(1-O3)*255)
	for i=1,15 do
		local v=i/15
		local r=127+S(O1+i*.1+y*0.05-T*.04)*127
		local g=127+S(O2+i*.15+y*0.04+T*.03)*127
		local b=127+S(O3+i*.15-y*0.04+T*.03)*127
		rgb(i,O1*r,O2*g,O3*b)
	end
end

function shuffle()
 O1=M.random(0,1)
 O2=M.random(0,1)
 O3=M.random(0,1)
end

function TIC()
	vbank(0)
 cls()
	
 poke(0x3FFB,0)

	if T%100==0 then
	 shuffle()
	end
	
	for i=0,135 do
	 local v=fft(i+T*.1)*300
		for x=1,v do
		 doPix(121-x,i)
		 doPix(120+x,i)
		end
	end

 local x=T*1.3
 local y=T*1.8
 drawTrack(x,y)

 for i=0,3 do
 	local x=120+S(i*1+T*.02)*80
 	local y=68+S(i*1.2+T*.017)*50
  local s=.6+S(i*.06+T*.015)*.4
	 drawWheel(x,y,s,T*.01)

		local x=120+S(i*.8+T*.019)*280
		local y=68+S(i*.7+T*.021)*100
	 local s=.6+S(i*.82+T*.017)*.4
		drawSymbol(x,y,s,T*.01)
	end
	drawBlades(120,68,2,T*.03)
	
	vbank(1)
	cls()
	local t="Field-FX at EMF!"
	local x=120-166/2
	local y=112-ABS(S(T*.08)*12)
	w=print(t,x+1,y+1,15,false,2)
	print(t,x,y,12,false,2)

	local t="jtruk"
	local x=208
	local y=128
	print(t,x+1,y+1,15)
	print(t,x,y,13)
 T=T+1
end

function drawBlades(x,y,s,a)
 drawBlade(x,y,s,a)
 drawBlade(x,y,s,a+TAU*1/3)
 drawBlade(x,y,s,a+TAU*2/3)
end

function drawBlade(x,y,s,a1)
 s1=s*0
 s2=s*35
 for d=0,1,.005 do
  local pd=s1+(s2-s1)*d
  local nDots=20
	 for iDot=0,nDots do
		 local a=a1+iDot*S(d*PI)*.02
	  local sa,ca=S(a),C(a)
	  local px=x+pd*sa
	  local py=y+pd*ca
		 doPix(px,py)
	 end
	end
end

function drawTrack(x,y)
 for px=0,239,10 do
	 for py=0,15 do
	 	local dx,dy=x+px-py*2,y+py+px*.57
			for w=0,8 do
			 doPix(dx+w,dy)
			end
		end
 end
end

function drawWheel(x,y,s,a)
 drawRing(x,y,0,s*.15,30,a,0,TAU)
 drawRing(x,y,s*.15,s*.8,10,a,0,TAU)
 drawRing(x,y,s*.8,s,150,a,0,TAU)
end

function drawSymbol(x,y,s,a)
 drawRing(x,y,s*.8,s,150,a,0,TAU)
 local xo=S(a)*s*12
 local yo=C(a)*s*12
 local aOfs=TAU/4
 drawRing(x+xo,y+yo,s*.2,s*.3,30,a,-aOfs+PI/2,aOfs*2)
 drawRing(x-xo,y-yo,s*.2,s*.3,30,a,aOfs+PI/2,aOfs*2)
end


function drawRing(x,y,s1,s2,n,aO,a1,as)
 s1=s1*50
 s2=s2*50
 for d=s1,s2 do
	 for i=1,n do
	 	local a=a1+i*as/n+aO
	  local sa,ca=S(a),C(a)
	  local px=x+d*sa
	  local py=y+d*ca
		 doPix(px,py)
	 end
	end
end

function doPix(x,y)
	x=x%240
	y=y%136
 local c=pix(x,y)
	pix(x,y,c+1)
end