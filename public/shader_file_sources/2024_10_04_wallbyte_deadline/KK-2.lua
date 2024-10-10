-- Welcome to the Deadline ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /RaccoonViolet

local S,MAX=math.sin,math.max
local cos=math.cos
local sin=math.sin

function TIC()
	cls()
	local t=time()*.01
	local x0=240/2
	local y0=136/2
	for z=100,10,-1 do
		for a=0,499 do
			local aa=(a+z/8)/500*2*3.141593
			local r=10*150
			local zz=z+t*10
			r=r*(1+.3*cos(aa*7-t)*sin(zz)
				*sin(t/3))
			local x=cos(aa)*r/z
			local y=sin(aa)*r/z
			local x2=x*2
			local y2=y*2
			--
   line(x+x0,y+y0,x2+x0,y2+y0,zz%16)
		end		
	end

end