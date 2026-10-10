-- Welcome to the Deadline ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /RaccoonViolet

local S,MAX=math.sin,math.max
local sin=math.sin
local cos=math.cos

function TIC()
	cls()
	local tt=time()*.002
	local x,y,z
	local xp=sin(tt)+2.5
	local xs=0--sin(tt)
	local ys=0--sin(tt)
	local zs=0--sin(tt)
	for u=40,239-40,2 do
		for v=0,139,2 do
			local dx=(u-240/2)/136*2
			local dy=v/136*2-1
			local dl=math.sqrt(dx*dx+dy*dy+1)
			dx=dx/dl
			dy=dy/dl
			local dz=1/dl
			local t=0
			for s=1,20 do
				x=dx*t
				y=dy*t
				z=dz*t
				local b
				local a=tt
				local c=cos(a)
				local s=sin(a)
				z=z-xp
				--
				b=x*c+z*s
				z=z*c-x*s	x=b
				--
				a=tt*.11
				b=y*c+z*s
				z=z*c-y*s	y=b
				local sx=x-xs
				local sy=y-ys
				local sz=z-zs
				local ds=math.sqrt(sx*sx+sy*sy+sz*sz)-1.3
				local d=math.abs(x)-1
				local d2=math.abs(y)-1
				local d3=math.abs(z)-1
				if d2>d then d=d2 end
				if d3>d then d=d3 end
				if -ds>d then d=-ds end
				t=t+d
				if t>9 or d<.02 then break end
			end
			if t<9 then
				local c=sin(x*2)*sin(y*2)
					*sin(z*2)*10
				pix(u,v,c)
				--pix(u+1,v,c)
				--pix(u,v+1,c)
				--pix(u+1,v+1,c)
			end
		end		
	end
end