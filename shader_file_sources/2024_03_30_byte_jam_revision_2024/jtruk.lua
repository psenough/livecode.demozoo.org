T=0
local SIN,COS,PI=math.sin,math.cos,math.pi
local TAU=PI*2
local ABS=math.abs

local RINGS={
 {
 	rI=10,
 	rO=20,
 	b={
	 	1,1,1,1,1,1,1,1,
	 	1,1,1,1,1,1,1,1,
	 	1,1,1,1,1,1,1,1,
	 	1,1,1,1,1,1,1,1,
		},
 },
 {
 	rI=20,
 	rO=30,
 	b={
	 	0,0,0,0,0,0,0,0,
	 	0,0,0,0,0,0,0,0,
	 	0,1,1,1,1,1,0,0,
	 	0,0,0,0,0,0,0,0,
		},
 },
 
 {
 	rI=30,
 	rO=40,
 	b={
   0,1,1,1,0,0,0,0,
   0,0,1,1,1,0,0,0,
		},
 },
 {
 	rI=50,
 	rO=60,
 	b={
   1,1,1,1,1,1,1,1,
   1,1,1,1,1,1,1,1,
		},
 },
 {
 	rI=60,
 	rO=70,
 	b={
   0,0,0,0,0,1,1,1,1,1,1,1,1,
   0,0,0,0,0,0,0,0,0,0,0,0,0,
   1,1,1,1,1,1,1,1,0,0,0,0,0,
   0,0,0,0,0,0,0,0,0,0,0,0,0,
		},
 },
}

local XCAM,YCAM,ZCAM=0,0,0

function BDR(y)
 vbank(0)
 for i=0,15 do
  local a=16320+i*3
  local int=i/15
  local r=127+SIN(T*.05+y*.01)*128
  local g=127+SIN(T*.04+y*.021)*128
  local b=127+SIN(T*.03+y*.017)*128
  
		poke(a,r*int)
		poke(a+1,g*int)
		poke(a+2,b*int)
	end
end

function TIC()
	XCAM=SIN(T*.02)*10
	YCAM=-ABS(SIN(T*.08))*10

 vbank(0)
 cls()
	for i=0,10 do
	 local z=(ZCAM+i*25)
		z=z%280
		drawSquare(0,0,z,50)
	end

	vbank(1)
	cls()
 local a=T/32
 local z=600+SIN(T/40)*200
 for _,ring in ipairs(RINGS) do
  local rI=ring.rI
  local rO=ring.rO
		drawRing(0,0,z,rI,rO,a,ring.b)
	end

 T=T+1
 ZCAM=ZCAM+2
end

function drawSquare(xc,yc,zc,d)
 local sc=1.6
 local iTiles=10
 local c=getC(zc)
	for i=-iTiles,iTiles do
	 local o=(i/iTiles)*d
		local p={
			x=xc+o/sc,
			y=yc-d,
			z=zc
		}
		p=proj(p)
		pix(p.x,p.y,c)

		local p={
			x=xc+o/sc,
			y=yc+d,
			z=zc
		}
		p=proj(p)
		pix(p.x,p.y,c)

		local p={
			x=xc-d/sc,
			y=yc+o,
			z=zc
		}
		p=proj(p)
		pix(p.x,p.y,c)

		local p={
			x=xc+d/sc,
			y=yc+o,
			z=zc
		}
		p=proj(p)
		pix(p.x,p.y,c)
	end
	
	print("close enough",170,128,14)
end

function getC(z)
	return (z/280)*15
end

function drawRing(xc,yc,zc,rI,rO,aStart,bits)
 local iPoints=#bits
 local pILast = nil
 local pOLast = nil
 local rY=time()/600
 for i,b in ipairs(bits) do
  local a=aStart + (i-1)/#bits * TAU
  local sina=SIN(a)
  local cosa=COS(a)
  local pI={x=sina*rI,y=cosa*rI,z=0}
  local pO={x=sina*rO,y=cosa*rO,z=0}

		pI=rotY(pI,rY)
		pO=rotY(pO,rY)
		
		local tr={x=xc,y=yc,z=zc}
		pI=trans(pI,tr)
		pO=trans(pO,tr)
  
  pI=proj(pI)
  pO=proj(pO)
  
  if i>1 and b>0 then
	  tri(
				pI.x,pI.y,
				pO.x,pO.y,
				pILast.x,pILast.y,
				12)
	  tri(
				pO.x,pO.y,
				pILast.x,pILast.y,
				pOLast.x,pOLast.y,
				12)
		end
  pILast=pI
  pOLast=pO
 end
end

function proj(p)
	local zD=3-p.z/100
	return {
	 x=120+(p.x-XCAM)/zD,
		y=68+(p.y-YCAM)/zD,
	}
end

function rotY(p,a)
	return {
		x=p.x*COS(a)-p.z*SIN(a),
		y=p.y,
		z=p.x*SIN(a)+p.z*COS(a),
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