-- Welcome to the Evoke ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /VioletRaccoon
sin=math.sin
cos=math.cos
function TIC()
	local t=time()*.001
	for y=0,135 do
		for x=0,239 do
			local dx=120-x
			local dy=68-y
			local d=(dx^2+dy^2)^.5
			local a=math.atan2(dy,dx)
			d = math.sin(d*.1)
			local c = math.sin(d*.1+a-t)*13

  	tt = t + a
			dx2 = cos(tt) * dx + sin(tt) * dy
			dy2 = cos(tt) * dy + sin(tt) * dx
			dy=dy2
			dx=dx2

			local z = 2 + math.sin(t*4)
			dx = dx * z / 3
			dy = dy * z / 3
			c = math.sin(dx*.03+a+cos(t*3.2))
			   +math.sin(dy*.03+a+sin(t*2))
			pix(x,y,c*16)
		end
	end

	local text="rubix"
	local x=-150+cos(t)*300
	local y=-175-math.sin(t)*300
	print(text,x+1,y+1,15,false,3)
	print(text,x,y,12,false,3)
end