t=0
r=240
cls()
function TIC()
	t=t+1
	d=.1+math.sin(t/97)^2*39
	for i=0,32639 do
		x=i%r-120
		y=i//r-68
		pix(x+120,y+68,pix(x-y/d+120,y+x/d+68)+1)
	end
	print("Plex was here!",10,2)
end