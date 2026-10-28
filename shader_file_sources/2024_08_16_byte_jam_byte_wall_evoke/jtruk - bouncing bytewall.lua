-- Welcome to the Evoke ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /RaccoonViolet

function TIC()
	local t=time()*.001
	for y=0,135 do
		for x=0,239 do
			local dx=120-x
			local dy=68-y
			local d=(dx^2+dy^2)^.5
			local a=math.atan2(dy,dx)
			pix(x,y,8+math.sin(d*.1+a-t)*3)
		end
	end

	local text="ByteWall!"
	local x=50
	local y=75-math.abs(math.sin(t*3)*30)
	print(text,x+1,y+1,15,false,3)
	print(text,x,y,12,false,3)
end