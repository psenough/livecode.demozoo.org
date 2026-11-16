-- Welcome to the Deadline ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /RaccoonViolet

local S,MAX=math.sin,math.max
m=math

function g(px,py,cx,cy,r)
 return m.exp(-m.pow((px-cx)/r,2)-m.pow((py-cy)/r,2))
end

function TIC()
 t=time()/500
	cls()
	print("hello deadline",40,60,12,0,2)
	print("vurpo is here",85,75,12)	
	local r = 26+8*m.sin(t)
	for y=0,136 do for x=0,240 do
		local v = 
		  g(x,y,120+61*m.sin(t*0.9984),68-16*m.sin(t*0.87),r)
			+g(x,y,120+55*m.cos(t*1.0153),68+18*m.cos(t*1.011),r)
			+g(x,y,120+58*m.cos(t*1.3523),68+20*m.sin(t*2.524),r)
		if v>0.21 then pix(x,y,v*5) end
	end end
end