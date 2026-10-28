-- Bytejam 2025-09-26/jtruk (Limelight 2025)
-- Greetz: All, but especially Violet^30
local M=math
local S,C,PI,ABS=M.sin,M.cos,M.pi,M.abs
local TAU=PI*2
local T=0
local CAM={x=0,y=0,z=25}

function BOOT()
 vbank(0)
	rgb(1,255,255,255)
	for i=0,13 do
	 local v=(i+1)/14
		rgb(2+i,v*100,v*255,v*100)
	end

 vbank(1)
 local sc=1
	rgb(1,sc*50,sc*100,sc*50)
	rgb(2,sc*100,sc*255,sc*100)
	rgb(3,sc*255,sc*255,sc*255)
end

function BDR(y)
	vbank(0)
	local sc=ABS(68-y)/68
	rgb(0,sc*50,0,sc*100)
end

function TIC()
	vbank(1)
	local xofs=16
	local size=64
	drawLime(size/2+xofs,size/2,10,2,size/2,.25)
	for i=0,15 do
		pix(i,0,i)
	end

	vbank(0)
	cls()
	local ps={
		{x=-1,y=-1,z=0},
		{x=-1,y=1,z=0},
		{x=1,y=-1,z=0},
		{x=1,y=1,z=0},
		{x=0,y=0,z=1.4},
	}
	local nSegs=15
	local d1=1.05
	for i=1,nSegs do
		local a=i/nSegs*TAU
		ps[#ps+1]={x=S(a)*d1,y=C(a)*d1,z=0}
	end
	local d2=.75
	for i=1,nSegs do
		local a=i/nSegs*TAU
		ps[#ps+1]={x=S(a)*d2,y=C(a)*d2,z=1}
	end

	local shs={{
		t='q',
		ps={1,2,3,4},
		ts={
			{x=xofs,y=0},
			{x=xofs+size,y=size}
		}
	}}
	for i=0,nSegs-1 do
	 local p0=5
		local p1=6+i
		local p2=6+(i+1)%nSegs
		local p3=6+nSegs+i
		local p4=6+nSegs+(i+1)%nSegs
		local c=9+S(i/nSegs*TAU)*6
		shs[#shs+1]={
			t='q',
			ps={p1,p2,p3,p4},
			ts={
				{x=c,y=0},
				{x=c+1,y=0}
			}			
		}
		shs[#shs+1]={
			t='t',
			ps={p0,p3,p4},
			ts={
				{x=c,y=0},
				{x=c+1,y=0}
			}
	 }
	end

	for i=0,20 do
		local tx=S(T*.02+i*.8)*5
		local ty=S(T*.03+i*.4)*3
		local tz=S(T*.04+i*.3)*10
		local rx=i*.2+T*.009
		local ry=i*.8+T*.004
		local rz=i*.15+T*.006
	 local pps={}
		for i,p in ipairs(ps) do
		 p.x,p.y=rot(p.x,p.y,rx)
		 p.x,p.z=rot(p.x,p.z,ry)
		 p.y,p.z=rot(p.y,p.z,rz)
			p=trans(p,{x=tx,y=ty,z=tz})
		 pps[i]=proj(p)
		end
		
		for _,sh in pairs(shs) do
		 if sh.t=='t' then
			 local p1=pps[sh.ps[1]]
			 local p2=pps[sh.ps[2]]
			 local p3=pps[sh.ps[3]]
				drawTri(p1,p2,p3,sh.ts[1],sh.ts[2])
			elseif sh.t=='q' then
			 local p1=pps[sh.ps[1]]
			 local p2=pps[sh.ps[2]]
			 local p3=pps[sh.ps[3]]
			 local p4=pps[sh.ps[4]]
				drawQuad(
					p1,p2,p3,p4,
					sh.ts[1],sh.ts[2]
				)
			end
		end
	end
	
	vbank(1)
	cls()
	local txt="JTRUK"
	local tx,ty=209,120
	print(txt,tx+1,ty+1,1)
	print(txt,tx-1,ty-1,2)
	print(txt,tx,ty,3)

 T=T+1
end

function trans(p,t)
	return {
		x=p.x+t.x,
		y=p.y+t.y,
		z=p.z+t.z,
	}
end

function rot(a,b,r)
	return
	 a*C(r)-b*S(r),
		a*S(r)+b*C(r)
end

function proj(p)
	local zD=40*(10/(CAM.z-p.z))
	return {
	 x=120+(CAM.x-p.x)*zD,
	 y=68+(CAM.y-p.y)*zD,
	 z=-zD,
	}
end

function	drawTri(px1y1,px2y1,px2y2,s1,s2)
	ttri(
		px1y1.x,px1y1.y,
		px2y1.x,px2y1.y,
		px2y2.x,px2y2.y,
		s1.x,s1.y, s2.x,s1.y, s2.x,s2.y,
		2,
		-1,
		-px1y1.z,-px2y1.z,-px2y2.z
	)				
end

function	drawQuad(px1y1,px1y2,px2y1,px2y2,s1,s2)
	ttri(
		px1y1.x,px1y1.y,
		px2y1.x,px2y1.y,
		px2y2.x,px2y2.y,
		s1.x,s1.y, s2.x,s1.y, s2.x,s2.y,
		2,
		0,
		-px1y1.z,-px2y1.z,-px2y2.z
	)		

	ttri(
		px2y2.x,px2y2.y,
		px1y2.x,px1y2.y,
		px1y1.x,px1y1.y,
		s2.x,s2.y, s1.x,s2.y, s1.x,s1.y,
		2,
		0,
		-px2y2.z,-px1y2.z,-px1y1.z
	)		
end

function drawLime(xc,yc,nSegs,dIn,dOut,dA)
	local nsegs
	circ(xc,yc,dOut,10)
	circ(xc,yc,dOut-1,1)
	local dSeg=dOut-2
	for i=0,nSegs-1 do
		local a1=TAU*i/nSegs
		local a2=a1+dA
		local a3=a1-dA
		local x1,y1=xc+S(a1)*dIn,yc+C(a1)*dIn
		local x2,y2=xc+S(a2)*dSeg,yc+C(a2)*dSeg
		local x3,y3=xc+S(a3)*dSeg,yc+C(a3)*dSeg
		tri(x1,y1,x2,y2,x3,y3,15)
	end
end


function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end