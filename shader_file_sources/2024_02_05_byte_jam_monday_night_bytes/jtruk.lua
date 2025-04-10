-- Greetz: Violet, Vurpo, Polynomial
-- Aldroid, Mantratronic, Catnip
-- My lovely cute new keyboard
-- and the Bytejam chat crew! :)

DO_TEETH=false

local S,C,PI=math.sin,math.cos,math.pi
local ABS=math.abs
local T=0
local TAU=PI*2
local RIPPLE=0
local YTEETH=0

function BDR(y)
	ripple=0
	rippleD=ABS(y-RIPPLE)
	if rippleD<32 then
	 ripple=1-(rippleD/32)
	end

 vbank(0)
 for i=1,15 do
  local r=127+S(i*.1)*127
  local c=ripple*255
  setRGB(i,r-c,c,c/3)
 end

	poke(0x3FF9,S(ripple*PI)*8)

 vbank(1)
 for i=1,14 do
  local g=127+S(i*.1-y*.017-T*.12)*127
  local b=127+S(i*.1+y*.02+T*.08)*127
	 setRGB(i+1,0,g,b)
	end

	poke(0x3FF9,S(ripple*PI)*-8)
end

function BOOT() 
 vbank(0)
 setRGB(0,0,0,0)
 vbank(1)
 setRGB(1,0,0,0)
end

function setRGB(i,r,g,b)
 local a=16320+i*3
 poke(a,r)
 poke(a+1,g)
 poke(a+2,b)
end

function TIC()
	RIPPLE=-T%260

 vbank(0)
 cls()
 ps=getPoints(100,T*.01)
 for i=0,10 do
  local sh=i*.1
		local x=120+S(T*.08+sh)*60
		local y=68+S(T*.06+sh)*20
		local sc=60+S(T*.06+1-sh)*30
		local cSh=S(T*.1+i)
--	 drawPoints(ps,x,y,sc,cSh)
	 drawTris(ps,x,y,sc,8)
	 drawPoints(ps,x,y,sc,cSh)
	end
	
	vbank(1)
	cls(1)
	for i=0,10 do
  local sh=i*.1
		local x=120+S(T*.03-sh)*60
		local y=68-S(T*.04-sh)*20
		local sc=60+S(T*.1)*40
		local c=8+S(T*.1+i)*6
		ps1=rotAllZ(ps,S(T*.02)*TAU)
	 drawTris(ps1,x,y,sc,c)
	 drawPoints(ps1,x,y,sc,c)
	end
		
	local x=5+S(T*.1)*20
	local y=8+S(T*.08)*10
	print("Love",x,y,0,false,10)
	local x=5+S(T*.07)*20
	local y=68+S(T*.09)*10
	print("Byte",x,y,0,false,10)

	if DO_TEETH then		
		local y=ABS(S(T*.1))*30
		for x=0,240,50 do
		 rect(x,0,40,y,15)
		 rect(x,136-y,40,y,15)
		end
	 rect(0,0,240,y-20,10)
	 rect(0,156-y,240,y,10)
	end

	local x=30
	local y=130-ABS(S(T*.1))*10

 text="This weekend, folks (9-11 Feb 24) :)"
	print(text,x+1,y+1,1)
	print(text,x,y,15)
 T=T+1
end

function getPoints(nps,aShift)
 -- Gonna steal some <3 math
	local p={}
	for i=0,nps do
	 local a=i/nps*TAU+aShift
	 p[i+1]={
		 x=(16*S(a)^3)/16,
			y=-(13*C(a)-5*C(2*a)-2*C(3*a)-C(4*a))/16-.2,
		}
	end
	
	return p
end

function drawPoints(ps,xc,yc,sc,cSh)
 for i,p in ipairs(ps) do
  local x=xc+p.x*sc
  local y=yc+p.y*sc
  local c=1+(i+cSh)%15
  circ(x,y,2,c)
 end
end

function drawTris(ps,xc,yc,sc,c)
 local lastX,lastY
 for i,p in ipairs(ps) do
  local x=xc+p.x*sc
  local y=yc+p.y*sc
  if i>1 then
   tri(xc,yc,x,y,lastX,lastY,c)
  end
		lastX,lastY=x,y
 end
end

function rotAllZ(ps,a)
 local newPs={}
 for i,p in ipairs(ps) do
  newPs[i]=rotZ(p,a)
 end
 return newPs
end

function rotZ(p,a)
 return {
  x=p.x*C(a)-p.y*S(a),
  y=p.x*S(a)+p.y*C(a),
 }
end
