-- Plex / BionFX
t=0
w=32639
r=240
function TIC()
	cls()
	dx=math.sin(t/33)*19
	dy=math.sin(t/29)*19
	for i=0,w do
	x=i%r-120
	y=i//r-68
	poke4(i,math.max(-16,math.min(16,x*9/(y+dx)+y*9/(x+dy))))
	end
	t=t+1.7
end