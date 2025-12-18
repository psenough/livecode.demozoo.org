-- Greetz to all at Nova and fellow
-- Jammers :)

T=0
DISCS={}

function BDR(y)
 vbank(0)
 local r=.5+math.sin(T*.0014)*.5
 local g=.5+math.sin(T*.0012)*.5
 local b=.5+math.sin(T*.001+y/60)*.5
 local i=2
 local addr=0x3fc0+i*3
 poke(addr,r*255)
 poke(addr+1,g*255)
 poke(addr+2,b*255)
end

function BOOT()
	for i=1,10 do
	 addDisc()
	end
end

function addDisc()
 local dx=.5+math.random()

	DISCS[#DISCS+1]={
	 x=math.random()*239,
	 y=math.random()*135,
		a=math.random()*math.pi*2,
		scale=30+math.random()*30,
		dx=dx,
	}
end

function TIC()
 T=time()
 vbank(1)
 cls()
 rect(0,0,63,63,8)
 rect(5,3,63-10,30,1)
 local sh=20
 rect(15,63-sh,35,sh,13)
 rect(20,63-sh+3,10,sh-5,8)
 local s=5
 tri(0,63,0,63-s,s,63,0)
	print("NOVA",10,20,2,true,2)

 vbank(0)
 cls()

	for i=1,#DISCS do
  local disc=DISCS[i]
		disc.x=disc.x+disc.dx
		if(disc.x>240+disc.scale)then
		 disc.x=-disc.scale
		end
		local xc,yc=disc.x,disc.y
	 local d=disc.scale
	 local a1=disc.a+T*.001
	 local a2=a1+math.pi/2
	 local a3=a2+math.pi/2
	 local a4=a3+math.pi/2
	
	 local p1x=xc+math.sin(a1)*d
	 local p1y=yc+math.cos(a1)*d
	 local p2x=xc+math.sin(a2)*d
	 local p2y=yc+math.cos(a2)*d
	 local p3x=xc+math.sin(a3)*d
	 local p3y=yc+math.cos(a3)*d
	 local p4x=xc+math.sin(a4)*d
	 local p4y=yc+math.cos(a4)*d
		drawQ(p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y,0)
 end
 
 vbank(1)
 cls()
end

function drawQ(p1x,p1y,p2x,p2y,p3x,p3y,p4x,p4y,s)
 local sx,sy=s//2,s%2
 local sx0,sy0=sx*64,sy*64
 local sx1,sy1=sx0+63,sy0+63
 drawT(p1x,p1y,p2x,p2y,p3x,p3y,
 	sx0,sy0,sx0,sy1,sx1,sy1)
 drawT(p3x,p3y,p4x,p4y,p1x,p1y,
 	sx1,sy1,sx1,sy0,sx0,sy0)
end

function drawT(
		dx0,dy0,dx1,dy1,dx2,dy2,
		sx0,sy0,sx1,sy1,sx2,sy2)
 ttri(
 	dx0,dy0,dx1,dy1,dx2,dy2,
  sx0,sy0,sx1,sy1,sx2,sy2,
  2,0)
end