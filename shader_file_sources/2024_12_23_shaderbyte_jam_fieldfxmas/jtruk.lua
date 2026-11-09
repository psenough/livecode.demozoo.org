local M=math
local S,C,PI,R=M.sin,M.cos,M.pi,M.random
local A=M.abs
local TAU=PI*2
local T=0
local CAM={x=0,y=0,z=5}

function BOOT()
 vbank(0)
	rgb(15,0,0,0)

 vbank(1)
	rgb(0,150,200,255)
	rgb(1,0,0,0)
end

function TIC()
	cls()

	CAM.x=-1.5+S(T*.03)*.5
	CAM.z=5+S(T*.03)*2

	vbank(0)
	drawMoire()
	local y=A(S(T*.1)*5)
	print("MERRY\n XMAS\n  ALL!",90,20-y,15,false,5)
	print("JTRUK",209,128,15)

	vbank(1)
	
	for i=0,0 do
	 x=i*2
		z=i*2
		tc={
			wobble=0,--S(T*.1)*.5,
			t={x=x,y=S(T*.2)*.4,z=z},
		}
		drawTree(tc)
	end
			
 T=T+1
end

function drawTree(c)
	local treeRY=T*.02
	local treeRZ=S(T*.1)*.2
	local treeH=3
	local hsteps=8
	local branchH=.4
	local branchG=.3
	local branchR=1.5
	for y=0,hsteps do
	 local ty=treeH/2-(y/hsteps)*treeH
		local branchL=.2+((y/hsteps)^1.3)*branchR
		
		local pc={x=c.xc,y=ty+branchH,z=0}
		pc.x=c.wobble*(hsteps-y)/hsteps
		ppc={x=pc.x,y=pc.y,z=pc.z}
		ppc.x,ppc.z=rot(ppc.x,ppc.z,treeRY)
		ppc.x,ppc.y=rot(ppc.x,ppc.y,treeRZ)
		ppc=trans(ppc,c.t)
		ppc=proj(pc)
		
		local nSpokes=3+y*2
		for x=1,nSpokes do
			local a1=(x-branchG)/nSpokes*TAU
			local a2=(x+branchG)/nSpokes*TAU
			local branchSeed=((x^9.3+y^3.2)%100)/100
		 local branchY=ty-(.75+.25*branchSeed)*branchH
			local w=(.9+.1*branchSeed)*branchL
			p1={x=pc.x+S(a1)*w,y=branchY,z=pc.z+C(a1)*w}
			p2={x=pc.x+S(a2)*w,y=branchY,z=pc.z+C(a2)*w}
			p1.x,p1.z=rot(p1.x,p1.z,treeRY)
			p2.x,p2.z=rot(p2.x,p2.z,treeRY)
			p1.x,p1.y=rot(p1.x,p1.y,treeRZ)
			p2.x,p2.y=rot(p2.x,p2.y,treeRZ)
			p1=trans(p1,c.t)
			p2=trans(p2,c.t)
			pp1=proj(p1)
			pp2=proj(p2)
			tri(
				ppc.x,ppc.y+branchSeed*10,
				pp1.x,pp1.y,
				pp2.x,pp2.y,
				1
			)
		end
	end
end

function drawMoire()
 local ps={}
 
 local x1=120+S(T*.02)*70
 local y1=68+S(T*.028)*40
 local x2=120+S(T*.03)*70
 local y2=68+S(T*.022)*40
	for y=0,136 do
		for x=0,239 do
			local d1=(((x-x1)^2+(y-y1)^2)^.5)
			local d2=(((x-x2)^2+(y-y2)^2)^.5)
			ps[y*240+x]=d1/5%2//1+d2/5%2//1
		end
	end

	for y=0,136 do
		for x=0,239 do
			pix(x,y,ps[y*240+x])
		end
	end
end

function proj(p)
	local zD=100/(CAM.z-p.z)
	return {
	 x=120+(CAM.x-p.x)*zD,
		y=68+(CAM.y-p.y)*zD,
		z=zD,
	}
end

function rot(a,b,r)
	local c,s=C(r),S(r)
	return a*c-b*s,a*s+b*c
end

function trans(p,t)
	return {x=p.x+t.x,y=p.y+t.y,z=p.z+t.z}
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r)	poke(a+1,g)	poke(a+2,b)
end
