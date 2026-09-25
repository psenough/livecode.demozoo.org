-- Welcome to the Evoke ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /VioletRaccoon

--enfys woz ere :3

rnd=math.random
function TIC()
 cls()
	for i=0,20 do
	 line(0,0+rnd()*30,240,0+rnd()*30,11)
	 line(0,30+rnd()*30,240,30+rnd()*30,1)
	 line(0,60+rnd()*30,240,60+rnd()*30,13)
	 line(0,90+rnd()*30,240,90+rnd()*30,1)
	 line(0,120+rnd()*30,240,120+rnd()*30,11)
	end
	for i=0,1 do
	 print("sorry mum",15+rnd()*4,28+rnd()*4+i*2,13-i,true,4)
	 print("i'm a catgirl",2+rnd()*4,78+rnd()*4+i*2,13-i,true,3)
 end
end