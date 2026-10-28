sin=math.sin
cos=math.cos
rnd=math.random

local boxX = 120
local boxY = 40
local boxV = 0
local boxD = 1

function TIC()
	
	cls(0)
	t=time()*60//1000
	
	for n=5,1,-1 do
	
		local rad = 16+8*n
		
		local x0 = rad*cos(t/9+n)
		local y0 = rad*sin(t/16+n)
	
		for y=-rad+y0,rad+y0 do
			local ly = y0-y
			local dy = ly^2
			for x=-rad+x0,rad+x0 do
			
				local lx = x0-x
				
				local r=math.atan2(ly,lx)
				local z=math.sqrt(lx*lx+dy)
				
				local w
				local form = math.abs(sin(r*n+t/9)*rad)
				if form > z then pix(x+120,y+68,n) end
				
			end
		end
	
	local boxW = 32+4*fft(9,16)
	
	boxY = boxY + boxV
	if boxY+boxW > 136 then
		boxY = 136-boxW
		boxV = -.625 - fft(9,16)/16
	else
		boxV = boxV + .005
	end
	
	boxX = boxX + boxD/4
	if boxX - boxW > 240 then
		boxX = -boxW
	end
	
	for x=boxX-boxW, boxX+boxW do
		for y=boxY-boxW, boxY+boxW do
			local c=pix(x,y)
			
			if c>0 then
				pix(x,y,(c-(rnd()*2//1))//1)
			else
				pix(x,y,1)
			end
		end
	end
		
	end

end
