-- Welcome to the Evoke ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /VioletRaccoon

function TIC()
 local t=time()*0.001
 local x0=-0.75
 local y0=0
 local r=math.sin(t)^8+1.4
 local a=t
 local rr=r*math.cos(a)/68
 local ri=r*math.sin(a)/68
	for y=0,135 do
		for x=0,239 do
			local dx=x-120
			local dy=y-68
			local cr=dx*rr-dy*ri+x0
			local ci=dy*rr+dx*ri+y0
			local dr=-1
			local di=0
			local zr=0
			local zi=0
			local n=25
			local i=0
			for j=0,n do
			 if j < 10 then 
			  local t2 = zr*zr-zi*zi+cr
					zi = 2*zi*zr+ci
					zr = t2
				else
				 local t2 = zr*zr-zi*zi+dr
					zi = 2*zr*zi+di
					zr = t2
				end
					
				if j>10 and j<20 then
  			zi=zi+math.sin(i*0.01+-t*3)*.5
					zr=zr+math.cos(i*0.01+t*2)*.5
					end
					
					if zr*zr + zi*zi > 16 then
					  break
					end
					i = j
			end
			local c = 0
			if i < n then
			  c = i
			end
			pix(x,y,c)
		end
	end

	local text="Mulia"
	local x=35
	local y=75-math.abs(math.sin(t*3)*30)
	print(text,x+1,y+1,15,false,3)
	print(text,x,y,12,false,3)
end