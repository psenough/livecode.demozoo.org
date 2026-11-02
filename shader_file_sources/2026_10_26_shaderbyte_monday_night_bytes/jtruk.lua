-- Bytejam 26/10/2026
-- Thanks Havoc (host),
--        i.v. (scary bleeps)
-- Greetz: Gasman, Canmom, Aart!

T=0
M=math
R=M.random
MIN,MAX=M.min,M.max
SIN,COS=M.sin,M.cos
PI=M.pi
CAM={x=0,y=0,z=10}
ROT={x=0,y=0,z=0}
MOUTH={
	{x=-1,y=-.5,z=0},
	{x=-.3,y=-.3,z=0},
	{x=-.3,y=-.1,z=0},
	{x=.3,y=-.1,z=0},
	{x=.3,y=-.3,z=0},
	{x=1,y=-.5,z=0},
	{x=.6,y=.5,z=0},
	{x=.4,y=.5,z=0},
	{x=.4,y=.3,z=0},
	{x=.2,y=.3,z=0},
	{x=.2,y=.5,z=0},
	{x=-.7,y=.5,z=0},
	{x=-1,y=-.5,z=0},
}

MOUTH_TRIS={
	{1,2,3},{1,3,12},
	{3,10,4},{3,10,12},
	{10,12,11},
	{5,6,8},
	{6,7,9},
	{5,10,9},
	{8,9,7},
}

NOSE={
	{x=-.2,y=-.3,z=0},
	{x=.2,y=-.3,z=0},
	{x=.5,y=.3,z=0},
	{x=-.5,y=.3,z=0},	
	{x=-.2,y=-.3,z=0},
}

NOSE_TRIS={{1,2,3},{1,3,4}}

EYE1={
	{x=-.4,y=-.3,z=0},
	{x=.5,y=.3,z=0},
	{x=0,y=.5,z=0},
	{x=-.5,y=-.3,z=0},
	{x=-.4,y=-.3,z=0},
}

EYE1_TRIS={{1,2,3},{1,3,4}}

EYE2={
	{x=.4,y=-.3,z=0},
	{x=-.5,y=.3,z=0},
	{x=0,y=.5,z=0},
	{x=.5,y=-.3,z=0},
	{x=.4,y=-.3,z=0},
}

EYE2_TRIS={{1,2,3},{1,3,4}}

function BOOT()
	vbank(0)
	for i=0,15 do
		rgb(i,i/15*255,0,0)
	end

	vbank(1)
	for i=0,15 do
		rgb(i,i/15*255,i/15*120,0)
	end
end

function TIC()	
	CAM.x=1.4*(SIN(T*.004)+SIN(T*.006))
	CAM.y=SIN(T*.02)
	CAM.z=10+SIN(SIN(T*.004)*4)*5
	ROT.x=COS(T*0.02)*.3+PI/2
	ROT.y=COS(T*0.04)*.3+PI/2

	local eye1tr={x=-.8,y=-.7,z=0}
	local eye2tr={x=.8,y=-.7,z=0}
	local nosetr={x=0,y=0,z=0}
	local mouthtr={x=0,y=1,z=0}

	vbank(0)
	cls(1)

	local parts={
		{t=moveP(eye1tr),scx=1},
		{t=moveP(eye2tr),scx=1},
		{t=moveP(nosetr),scx=.8},
		{t=moveP(mouthtr),scx=4},
	}
	
	for i=1,15,.1 do
		for m,l in ipairs(parts) do
			local s=(15-i)*(.6+SIN(m*2+T*.02)*.4)
			local sx=s*l.scx
			local sy=s
			elli(
				l.t.x+SIN(i*i*.85+T*.012)*5,
				l.t.y+SIN(i*i*.95+T*.02)*5,
				sx,sy,i
			)		
		end
	end

	vbank(1)
	cls(3)

	drawDark(NOSE,nosetr,NOSE_TRIS)
	drawDark(EYE1,eye1tr,EYE1_TRIS)
	drawDark(EYE2,eye2tr,EYE2_TRIS)
	drawDark(MOUTH,mouthtr,MOUTH_TRIS)
	
	projLine(EYE1,eye1tr)
	projLine(EYE2,eye2tr)
	projLine(NOSE,nosetr)
	projLine(MOUTH,mouthtr)

	T=T+1
end

function moveP(op)
	local p={x=op.x,y=op.y,z=op.z}
	p.x,p.y=rotP(p.x,p.y,ROT.x)
	p.x,p.z=rotP(p.x,p.z,ROT.y)
--	p.y,p.z=rotP(p.y,p.z,PI/4)
	p=proj(p)
	return p
end

function transPs(l,tr)
	local tPs={}
	for _,op in ipairs(l) do
		local p={x=op.x+tr.x,y=op.y+tr.y,z=op.z+tr.z}
		tPs[#tPs+1]=moveP(p)
	end
	return tPs
end

function projLine(l,tr)	
	local lastPb,lastPf
	for _,op in ipairs(l) do
		local p={x=op.x+tr.x,y=op.y+tr.y,z=op.z+tr.z}
		local pb=moveP(p)
		local pf=moveP({x=p.x,y=p.y,z=p.z-.4})

		local c=1--10+SIN(ROT.y)*5
		if lastPb then
			tri(lastPb.x,lastPb.y,pb.x,pb.y,lastPf.x,lastPf.y,c)
			tri(pf.x,pf.y,pb.x,pb.y,lastPf.x,lastPf.y,c)
		end
		lastPb,lastPf=pb,pf
	end
end

function drawDark(ps,tr,tris)
	local tps=transPs(ps,tr)
	for _,tr in ipairs(tris) do
		local p1=tps[tr[1]]
		local p2=tps[tr[2]]
		local p3=tps[tr[3]]
		tri(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,0)
	end
end	

function rotP(a,b,r)
	local s,c=SIN(r),COS(r)
	return a*s+b*c,a*c-b*s
end

function proj(p)
	local dz=240/(p.z-CAM.z)
	return {x=120+(p.x-CAM.x)*dz,y=68+(p.y-CAM.y)*dz,z=dz}
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end