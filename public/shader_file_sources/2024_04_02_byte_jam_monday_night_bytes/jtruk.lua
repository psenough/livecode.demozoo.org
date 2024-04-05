local SIN,COS=math.sin,math.cos
local PI=math.pi
local TAU=PI*2
local MIN,MAX=math.min,math.max
local ATAN2=math.atan2

function BDR(y)
 vbank(0)
 local sl=y%4>=2
 local r=30+SIN(T*.01+y*.01)*30
 local g=30+SIN(T*.017+y*.007)*30
 local b=(sl and 30 or 80)+SIN(T*.023-y*.006)*30
 setRGB(0,r,g,b)
	for c=1,15 do
		local v=c/15*.5*SIN(T*.009)+.5
		local r=v*(127+SIN(c*.1+T*.01+y*.03)*127)
		local g=v*(127+SIN(c*.12-T*.02+y*.024)*127)
		local b=v*(127+SIN(c*.15+T*.03-y*.02)*127)
	 setRGB(c,r,g,b)
	end
end

function setRGB(i,r,g,b)
	local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end

T=0
function TIC()
	vbank(1)
	for y=0,63 do
	 for x=0,63 do
		 local dx,dy=x-32,y-32
			local a=ATAN2(dy,dx)+PI
			local d=(dx^2+dy^2)^.8
		 local c=a*2+d*.02-T*.2
	  pix(x,y,8+SIN(c)*7)
		end
	end
	local x,y=8,12
	print("=)",x-1,y-1,0,false,8)
	print("=)",x,y,15,false,8)
	
	vbank(0)
	cls()
	for i=0,100 do
		local p=proj({
			x=SIN(i*.2+T*.04),
			y=SIN(i*.12+T*.02),
			z=(i*2+T*.1)%12-8,
		})
	
	 local sc=4/p.z^2
	 local s=MAX(0,MIN(sc,10))
		circ(p.x,p.y,s,8+SIN(i*.1)*7)
	end
	
	local a=T*.01
	local boom=fft(1)*2
	local tCube={
		x=SIN(T*.02)*.4,
		y=SIN(T*.012)*.2,
		z=SIN(T*.017)*2-1,
	}
 drawSide(a,0,0,0,tCube,boom)
	drawSide(a,.5,0,.5,tCube,boom)

 drawSide(a,.25,0,.5,tCube,boom)
 drawSide(a,.75,0,.5,tCube,boom)

 drawSide(a,0,.25,.5,tCube,boom)
 drawSide(a,0,.75,.5,tCube,boom)
				
	vbank(1)
	cls()
	print("jtruk",210,130,15)
	T=T+1
end

function drawSide(a,rX,rY,rZ,t,boom)
	local nPsWide=10
	local points={}
	for yT=0,nPsWide do
		for xT=0,nPsWide do
		 local xP=xT/nPsWide
		 local yP=yT/nPsWide
			local xPh,yPh=xP-.5,yP-.5
  	local mul=boom*.5+((.5-(xPh^2+yPh^2)^.5)*boom^.5)*.5
   mul=.5+MAX(mul,0)
			table.insert(points,{
			 x=xP-.5,
			 y=yP-.5,
			 z=mul,
				xP=xP,
				yP=yP,
			})
		end
	end
	
	for i,p in ipairs(points) do
		-- happy day of trans visibility
		-- (close enough!)
  p=rotX(p,rX*TAU)
  p=rotY(p,rY*TAU)
  p=rotZ(p,rZ*TAU)
  p=trans(p,t)
  p=rotX(p,SIN(a*1.2))
  p=rotY(p,SIN(a*2))
  p=rotZ(p,SIN(a*1.6))
		p=proj(p)
		points[i].tr=p
	end

 local c=0
 local span=nPsWide+1
	for yT=0,nPsWide-1 do
		for xT=0,nPsWide-1 do
		 local p00=points[yT*span+xT+1]
		 local p01=points[yT*span+(xT+1)+1]
		 local p10=points[(yT+1)*span+xT+1]
		 local p11=points[(yT+1)*span+(xT+1)+1]
			local p00t=p00.tr
			local p01t=p01.tr
			local p10t=p10.tr
			local p11t=p11.tr

			local tX,tY=64,64
			ttri(
				p00t.x,p00t.y,
				p10t.x,p10t.y,
				p11t.x,p11t.y,
				p00.xP*tX,p00.yP*tY,
				p10.xP*tX,p10.yP*tY,
				p11.xP*tX,p11.yP*tY,
				2,
				-1,
				p00t.z,
				p10t.z,
				p11t.z
			)

			ttri(
				p11t.x,p11t.y,
				p01t.x,p01t.y,
				p00t.x,p00t.y,
				p11.xP*tX,p11.yP*tY,
				p01.xP*tX,p01.yP*tY,
				p00.xP*tX,p00.yP*tY,
				2,
				-1,
				p11t.z,
				p01t.z,
				p00t.z
			)
		end
	end
end

function proj(p)
 local zD=2-p.z/3
 return {
 	x=120+p.x/zD*100,
  y=68+p.y/zD*100,
  z=zD,
 }
end

function rotX(p,a)
	local sa,ca=SIN(a),COS(a)
	return {
	 x=p.x,
		y=p.y*ca-p.z*sa,
	 z=p.y*sa+p.z*ca,		
	}
end

function rotY(p,a)
	local sa,ca=SIN(a),COS(a)
	return {
	 x=p.x*ca-p.z*sa,
	 y=p.y,
	 z=p.x*sa+p.z*ca,
	}
end

function rotZ(p,a)
	local sa,ca=SIN(a),COS(a)
	return {
	 x=p.x*ca-p.y*sa,
	 y=p.x*sa+p.y*ca,		
	 z=p.z,
	}
end

function trans(p,t)
	return {
	 x=p.x+t.x,
	 y=p.y+t.y,
	 z=p.z+t.z,
	}	
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>