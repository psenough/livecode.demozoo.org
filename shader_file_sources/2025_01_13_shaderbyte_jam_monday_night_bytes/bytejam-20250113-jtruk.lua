-- Bytejam 20250113 (jtruk)
-- Thx: Aldroid, Sam Aaron
-- Greetz: weatherman115 pumpuli
--   g22kou enfys totetmatt AndU

local T,M=0,math
local S,C,PI,ATAN=M.sin,M.cos,M.pi,M.atan2
local R=M.random
local TAU=2*PI
local CAM={x=0,y=0,z=-1}
local CAMZOOM
local FFTSPLIT
local XI,YI,ZI
local XTI,YTI,ZTI
local WW
local R1,G1,B1
local XS

function shuffle()
	CAMZOOM=R(1,3)
	FFTSPLIT=R(5,20)
	XI=(1+R(100))/200
	YI=(1+R(100))/200
	ZI=(1+R(100))/200
	XTI=(1+R(100))/1000
	YTI=(1+R(100))/1000
	ZTI=(1+R(100))/1000
	WW=R(5,20)
	R1=R(0,255)
	G1=R(0,255)
	B1=R(0,255)
	XS=R(1,3)

	vbank(1)
	rgb(1,64-R1/4,64-G1/4,64-B1/4)

	vbank(0)
	for i=1,15 do
		local v=i/15
		rgb(i,v*R1,v*G1,v*B1)
	end
end

function BOOT()
	vbank(0)
	rgb(0,0,0,0)
	
	vbank(1)
	rgb(1,50,0,0)
end

function TIC()
	if T%50==0 then
	 shuffle()
	end

	vbank(1)
	cls()
	for i=0,135 do
		local v=ffts((T+i)%80)*120
		line(120-v,i,120+v,i,1)
	end

	vbank(0)
	cls()
	CAM.z=3+ffts(4)^.4*CAMZOOM
 local lp
	for n=-XS,XS do
	 local xo=n/XS*2
		for i=0,100 do
			local p={x=xo+S(xo+i*XI+T*XTI),y=S(i*YI+T*YTI),z=1+S(i*ZI+ZTI)}
			local p=proj(p)
			if i>0 then
			 poke4(0x3ff0*2+1,1+(15-(i/8)%15))
				drawLine(p,lp,i)
			end
			lp=p
		end
	end
	
	vbank(1)
	print("JTRUK",209,129,1)

	T=T+1
end

function drawLine(p1,p2,i)
	local d=ATAN(p1.x-p2.x,p1.y-p2.y)
	local dx,dy=C(d)*WW*p1.z,S(d)*WW*p1.z
	local tp1={x=p1.x-dx,y=p1.y+dy,z=p1.z}
	local tp2={x=p1.x+dx,y=p1.y-dy,z=p1.z}
	local tp3={x=p2.x-dx,y=p2.y+dy,z=p2.z}
	local tp4={x=p2.x+dx,y=p2.y-dy,z=p2.z}
	local y0=(i*FFTSPLIT)%120
	local y1=y0+FFTSPLIT
	local uv1={x=120-50,y=y0}
	local uv2={x=120+50,y=y0}
	local uv3={x=120-50,y=y1}
	local uv4={x=120+50,y=y1}
	drawTri(tp1,tp2,tp3,uv1,uv2,uv3)
	drawTri(tp3,tp2,tp4,uv3,uv2,uv4)
end

function drawTri(p1,p2,p3,uv1,uv2,uv3)
	ttri(
		p1.x,p1.y,
		p2.x,p2.y,
		p3.x,p3.y,
		uv1.x,uv1.y,
		uv2.x,uv2.y,
		uv3.x,uv3.y,
		2,
		0
	)
end

function proj(p)
	local zD=5/(p.z-CAM.z)
	return {
	 x=120+(p.x-CAM.x)/zD*60,
	 y=68+(p.y-CAM.y)/zD*60,
		z=zD,
	}
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end
