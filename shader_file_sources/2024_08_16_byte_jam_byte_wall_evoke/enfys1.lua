-- Welcome to the Evoke ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /VioletRaccoon
sin=math.sin
function TIC()
	t=time()/100
	cls()
	for y=0,135,2 do
	 for x=0,240,3 do
		 sv=sin(y/64+sin(x/43+t)+t/13)*sin(y/33+t/3)*32
			pix(x,y,sv%7)
		end
	end
end