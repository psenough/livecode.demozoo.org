-- Greetz: Aldroid, ToBach+Nico
-- Polynomial, RaccoonViolet

T=0
P={}
C={}
M=math
SIN,COS,MIN,MAX=M.sin,M.cos,M.min,M.max

function BDR(y)
	vbank(0)
	setRGB(0,0,0,0)

	for i=1,7 do
	 local v=i/7
		local u=.5+SIN(y/20)*.5
	 setRGB(i,v*128,u*255,0)
	 setRGB(i+8,0,v*128,u*255)
	end
	
	vbank(1)
	for i=1,7 do
	 local v=i/7
		local u=.5+SIN(y/20)*.5
	 setRGB(i,127+v*127,u*255,0)
	 setRGB(i+8,0,127+v*127,u*255)
	end
end

function BOOT()
	init()
		
	cls()
end

function TIC()
 decay()

	for x=0,239 do
		for y=0,135 do
			i=y*240+x
			P[i]=P[i]+.1*SIN(T/7*.1+x/20)
				+.15*SIN(T/10*.9+y/15)
		end
	end

	for i=0,20 do
		local xd=120+SIN(i+T/35)*100
		local yd=68+COS(i+T/20)*60
		local d=i%2==0 and 1 or -1 
		doLump(xd,yd,20,d*(1+fft(0)))
	end
	
	pattern()
	cap()

 draw()
 T=T+1
end

function	doLump(xc,yc,r,v)
 for yd=-r,r do
	 for xd=-r,r do
		 local d=(xd^2+yd^2)^.5
		 if d<r then
			 x,y=xc+xd,yc+yd
			 if x>=0 and x<=239 and y>=0 and y<=135 then
				 local i=y//1*240+x//1
				 P[i]=P[i]+v*(d/r)
				end
			end
		end
	end
end

function init()
	for i=0,0x7fff do
		P[i]=0
		C[i]=0
	end
end

function decay()
	for i=0,0x7fff do
		P[i]=P[i]*.95
	end
end

function pattern()
	local i=0
	local xc,yc=120+SIN(T/30)*100,68+SIN(T/20)*100
	local s=5+SIN(T/15)*4.8
 for y=0,135 do
	 for x=0,239 do
		 C[i]=((((xc-x)*s)//16+((yc-y)*s)//16))%2==0 and 1 or 0
			i=i+1
		end
	end
end

function cap()
	for i=0,0x7fff do
		P[i]=MAX(0,MIN(1,P[i]))
	end
end

function draw()
	vbank(0)	
	local i=0
 for y=0,135 do
	 for x=0,239 do
		 c=0
		 if P[i]<0 then
			 c=-P[i]*7+C[i]*7+1
			end
			pix(x,y,c)
			i=i+1
		end
	end

	vbank(1)	
	i=0
 for y=0,135 do
	 for x=0,239 do
		 c=0
		 if P[i]>=0 then
			 c=P[i]*7+C[i]*7+1
			end
			pix(x,y,c)
			i=i+1
		end
	end
end

function setRGB(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end