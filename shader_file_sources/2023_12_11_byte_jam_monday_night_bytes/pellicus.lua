-- pos: 21,51
-- Pellicus is activated :D
-- hello everyone!!!
sin=math.sin
cos=math.cos

function palette(sinx,n, S , E)
	local d,i=n-1,sinx*3
	for j=0,d do
		poke(16320+i+j*3+0, S[1]+j*(E[1]-S[1])/d)
		poke(16320+i+j*3+1, S[2]+j*(E[2]-S[2])/d)
		poke(16320+i+j*3+2, S[3]+j*(E[3]-S[3])/d)
	end
end

-- some math
function normalize(x,y,z)
	local m = 1/(x^2+y^2+z^2)^.5
	return x*m,y*m,z*m
end
function cross(ax,ay,az,bx,by,bz)
	return ay*bz-az*by,
								az*bx-ax*bz,
								ax*by-ay*bx
end

rx,ry,rz,ox,oy,oz=0,0,0,0,0,0

function TIC()
t=time()/1000
palette(0,8,{0,0,0},{255,0,0})
palette(8,8,{0,0,0},{255,255,255})

-- some camera...
local Ox,Oy,Oz = sin(t/4)*20,
		8+sin(t/7)*4, 10+cos(t/4)*8+(10+sin(t/5)*5)
-- target camera
local Tx,Ty,Tz = 0,0,0
-- now a matrix..
	-- forward vector
	local Fx,Fy,Fz=normalize(Tx-Ox,Ty-Oy,Tz-Oz)
 -- right vector
 local Rx,Ry,Rz=cross(Fx,Fy,Fz,0,1,0)
 -- up vector
 local Ux,Uy,Uz=cross(Fx,Fy,Fz,Rx,Ry,Rz)

	-- Light Position
	local Lx,Ly,Lz = 0,8,0

	-- bouncing Sphere position and radius
	 Sx,Sy,Sz,Sr=-5,math.abs(sin(t)*4,0),3,2
	Sy=Sy+Sr
	
	local ix,iy,iz,nx,ny,nz
	local shdz,ooW,o=0,1/240,0
	local minz,obj,col
	
	for y=0,135 do for x=0,239 do
			ox,oy,oz=Ox,Oy,Oz
			ix,iy,iz = (x-120)*ooW,(y-70)*ooW,1
	
			rx,ry,rz=	Fx+Rx*ix + Ux*iy,
													Fy+Ry*ix + Uy*iy,
													Fz+Rz*ix + Uz*iy
			rx,ry,rz=normalize(rx,ry,rz)

			shd=1
			minz,obj,col,			
			ix,iy,iz,nx,ny,nz=scene(false)
						
			if minz<80 then  -- some lighting
					local lx,ly,lz=normalize(Lx-ix,Ly-iy,Lz-iz)
		 		-- floor receiving shadows
					if obj==1 then
 					ox,oy,oz=ix,iy,iz
		   	rx,ry,rz=lx,ly,lz
	 	   shd=scene(true)
					end

					local lit = nx*lx+ny*ly+nz*lz
					lit = lit>1 and 1 or (lit<0 and 0 or lit)
					col =col+  lit*shd*7 + o^2.5%1
			
			end
-- 	pix(x,y,(x+y+t)>>3)
		poke4(o,col)
		o=o+1

end end 


end

function isph(px,py,pz,r)
		local cx,cy,cz=ox-px,oy-py,oz-pz
		local b=cx*rx+cy*ry+cz*rz
		local c= cx^2+cy^2+cz^2 -r^2
		if c>0 and b>0 then return 80 end
		c=b^2-c
		if c<0 then return 80 end
		return -b - c^.5
end

function scene(shd)
			local ix,iy,iz,nx,ny,nz
			local col,minz,obj=8,80,0
			
			dz= isph(Sx,Sy,Sz,Sr)
			if dz<minz then
			if shd then return .5 end
				minz=dz
				ix,iy,iz= ox+rx*dz,oy+ry*dz,oz+rz*dz
				nx,ny,nz= normalize(ix-Sx,iy-Sy,iz-Sz)
				--col=8
				obj=2
			end
			
			if shd then return 1 end
				
			if ry<0 then
				local dz=-oy/ry
				if dz<minz then
					minz=dz
					ix,iy,iz= ox+rx*dz,oy+ry*dz,oz+rz*dz
					nx,ny,nz=0,1,0
					col=8*((ix//4+iz//4)&1)
					obj=1
				end
			end
			
			return minz,obj,col,
			ix,iy,iz,nx,ny,nz
end

