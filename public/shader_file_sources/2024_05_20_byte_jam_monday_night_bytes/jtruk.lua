-- 20240502 JTRUK MNB ByteJam
-- Greetz: ToBach, Pumpuli, Catnip
-- Reality, Alkama

M=math
S,C=M.sin,M.cos
MIN=M.min
ABS=M.abs
T=0


CAM={x=0,y=0,z=0}

function BDR(y)
 vbank(0)
	setRGB(0,ffts(y)*255,0,0)
	for i=1,15 do
	 local b=127+S(y*.03+i*.2+T*.08)*127
 	setRGB(1,80,0,b)
	end

 vbank(1)
	for i=1,15 do
	 local v=1-(i/16)
	 local r=127+S(y*.04+T*.03)*127
		setRGB(i,r*v,0,(255-r)*v)
	end
end

function TIC()
 vbank(0)
 cls()
	for i=0,120 do
	 local v=ffts(i)*70
		local ni=240-i
	 line(i,68,i,68-v,1)
	 line(i,68,i,68+v,1)
	 line(ni,68,ni,68-v,1)
	 line(ni,68,ni,68+v,1)
	end
 
 vbank(1)
	cls()
	CAM.x=S(T*.04)
	CAM.x=S(T*.03)
	CAM.z=1+S(T*.05)
	local dlist={}
 for sh=1,8 do
		local rZ=S(T*.005)*2+S(T*.008+sh*.02)
		for y=-6,6 do
		 local rY=T*.05+y*.7+sh*.1
			local linePs={}
			local fftS=6+ABS(6-y)+sh*3
		 local w=.5+(S(T*.03)+ffts(fftS))
			for i=-1,1,2 do
				local p={x=i*w,y=y+sh*.04,z=0}
				p=rotY(p,rY)
				p=rotZ(p,rZ)
				p=proj(p)
				table.insert(dlist,{
					t="circ",
					ps={p},
					c=sh,
				})
				linePs[#linePs+1]=p
			end
				table.insert(dlist,{
					t="line",
					ps=linePs,
					c=sh,
				})		
		end
	end
	
--[[	
	table.sort(dlist, function(a,b)
		return a.ps[1].z<b.ps[1].z
	end)
--]]

	for _,d in ipairs(dlist) do
		if d.t=="circ" then
		 local p=d.ps[1]
			local s=MIN(70/(p.z^2),50)
   circ(p.x,p.y,s,d.c)
--[[
			local p1=trans(p,-s,-s,0)
			local p2=trans(p,s,-s,0)
			local p3=trans(p,-s,s,0)
			local p4=trans(p,s,s,0)
			quad(p1,p2,p3,p4)
	--]]
		elseif d.t=="line" then
		 local ps=d.ps
		 local s1=MIN(10/(ps[1].z^2),50)*2
		 local s2=MIN(10/(ps[2].z^2),50)*2
			local p1x=ps[1].x-s1
			local p1y=ps[1].y-s1
			local p2x=ps[1].x+s1
			local p2y=ps[1].y+s1
			local p3x=ps[2].x-s2
			local p3y=ps[2].y-s2
			local p4x=ps[2].x+s2
			local p4y=ps[2].y+s2
			tri(p1x,p1y,p2x,p2y,p3x,p3y,d.c)
			tri(p4x,p4y,p3x,p3y,p2x,p2y,d.c)
		end
	end
-- print("jtruk", 120,120
	T=T+1
end

function quad(p1,p2,p3,p4)
	textri(p1,p2,p3)
	textri(p3,p2,p4)
end
	

function textri(p1,p2,p3)
	ttri(
		p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,
		0,0,32,0,32,32,
		2,
		-1,
		p1.z,p2.z,p3.z
	)
end

function trans(p,x,y,z)
	return {
	 x=p.x+x,
	 y=p.y+y,
	 z=p.z+z,
	}
end

function rotX(p,a)
	local s,c=S(a),C(a)
	return {
	 x=p.x,
		y=p.y*c-p.z*s,
		z=p.y*s+p.z*c,
	}
end

function rotY(p,a)
	local s,c=S(a),C(a)
	return {
		x=p.x*c-p.z*s,
	 y=p.y,
		z=p.x*s+p.z*c,
	}
end

function rotZ(p,a)
	local s,c=S(a),C(a)
	return {
		x=p.x*c-p.y*s,
		y=p.x*s+p.y*c,
	 z=p.z,
	}
end

function proj(p)
	local zD=3-(p.z-CAM.z)/1
	return {
	 x=120+(p.x-CAM.x)/zD*100,
	 y=68+(p.y-CAM.y)/zD*100,
	 z=zD,
	}
end

function setRGB(c,r,g,b)
	local a=16320+c*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end