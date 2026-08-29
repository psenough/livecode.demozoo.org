-- Plex / BionFX
t=0
w=32639
r=240
function TIC()
	cls()
	dx=math.sin(t/37)*99
	dy=math.sin(t/23)*49
	for i=0,w do
	x=i%r-120
	y=i//r-68
	poke4((i+math.max(-80,math.min(80,x*9/(y+dx)+y*9/(x+dy))))%w,(x~y)/4)
	end
	t=t+1.7
end