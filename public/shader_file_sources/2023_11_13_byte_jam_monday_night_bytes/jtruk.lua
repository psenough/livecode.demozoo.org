-- Greets:
--	MANTRATRONIC   GASMAN
-- DOCTOR SOFT   VISY
-- LYNN   EVILPAUL 
--	LEX   TOBACH
-- VIOLET   ALDROID

T=0
SIN,COS=math.sin,math.cos
X,Y,Z=0,0,0

P={
	{x=-1,y=-1,z=0},
	{x=1,y=-1,z=0},
	{x=1,y=1,z=0},
	{x=-1,y=1,z=0},
}


function BDR(y)
 vbank(0)
 local addr=0x3fc0+2*3
 poke(addr,y)
 poke(addr+1,(.5+SIN(y*.1+T*.1)*.5)*128)
 poke(addr+2,(.5+SIN(y*.14+T*.16)*.5)*128)
end

function TIC()
	vbank(1)
	cls()

	sc=1+(SIN(T*.05)/math.pi)*1
 cakeW,cakeH=100,100
	drawCake(cakeW,cakeH,sc)

	vbank(0)
	cls()

	for i=0,8 do
  local u0x,u0y=(i%3)/3,(i//3)/3
  local u1x,u1y=u0x+1/3,u0y+1/3
  local p0x,p0y=u0x*2-1,u0y*2-1
  local p1x,p1y=u1x*2-1,u1y*2-1
  P={
  	{x=p0x,y=p0y,z=0},
  	{x=p1x,y=p0y,z=0},
   {x=p1x,y=p1y,z=0},
   {x=p0x,y=p1y,z=0}
  }

		pT={}
 	rX=T*0.014+SIN(i*.06+T*.03)
  rY=T*0.022+SIN(i*.03+T*.05)
  rZ=T*0.03+SIN(i*.04+T*.03)
	 for i=1,#P do
		 p=P[i]
			pT[i]=proj(
				rotZ(rotY(rotX(p,rX),rY),rZ)
			)
		end
		drawQ(
		 pT[1].x, pT[1].y, pT[1].z,
		 pT[2].x, pT[2].y, pT[2].z,
		 pT[3].x, pT[3].y, pT[3].z,
		 pT[4].x, pT[4].y, pT[4].z,
			u0x*cakeW,u0y*cakeH,u1x*cakeW,u1y*cakeH
		)
	end
	
	vbank(1)
	cls()

	print("HAPPY",96,101,3,false,2)
	print("BYTEJAMMIVERSARY",31,116,3,false,2)

	print("HAPPY",95,100,12,false,2)
	print("BYTEJAMMIVERSARY",30,115,12,false,2)
	
	T=T+1
end

function drawCake(w,h,s)
	local wh,hh=w/2,h/2
	local cakeW=s*60
	rect(0,0,w,h,2)
	elli(wh,hh+s*20,cakeW/2,5*sc,12)
	elli(wh,hh-s*10,cakeW/2,5*sc,12)
	rect(wh-cakeW/2,hh-s*10,cakeW+2,s*30,12)
	rect(wh-2,hh-s*30,4,20*s,12)
end

function drawQ(
	d0x,d0y,d0z,
	d1x,d1y,d1z,
	d2x,d2y,d2z,
	d3x,d3y,d3z,
	s0x,s0y,s1x,s1y
)
	drawT(d0x,d0y,d0z,d1x,d1y,d1z,d2x,d2y,d2z, s0x,s0y,s1x,s0y,s1x,s1y)
	drawT(d2x,d2y,d2z,d3x,d3y,d3z,d0x,d0y,d0z, s1x,s1y,s0x,s1y,s0x,s0y)
end

function drawT(d0x,d0y,d0z,d1x,d1y,d1z,d2x,d2y,d2z,s0x,s0y,s1x,s1y,s2x,s2y)
	ttri(
		d0x,d0y,d1x,d1y,d2x,d2y,
		s0x,s0y,s1x,s1y,s2x,s2y,
		-- huh. Maybe come back to z correcton later!
		2,-1,1,1,1
	)
end

function proj(p)
 local zF=1/(6-p.z)
  
 return {
 	x=120+(p.x/zF)*10,
  y=68+(p.y/zF)*10,
  z=p.z/zF
 }
end

function rotX(p,r)
 return {
  x=p.x,
  y=p.y*COS(r)-p.z*SIN(r),
  z=p.y*SIN(r)+p.z*COS(r),
 }
end

function rotY(p,r)
 return {
  x=p.x*COS(r)-p.z*SIN(r),
  y=p.y,
  z=p.x*SIN(r)+p.z*COS(r),
 }
end

function rotZ(p,r)
 return {
  x=p.x*COS(r)-p.y*SIN(r),
  y=p.x*SIN(r)+p.y*COS(r),
  z=p.z
 }
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

