-- pos: 19,12

t=0

cls(2)

function TIC()

	for y = 0, 250,2 do
	 memcpy(y*60,y*60-1,120)
	end

	for x = 0, 239 do

		pix(x,136//2-vqts((x+t)%256)*50,10+vqts((x+t)%256)*4)
		pix(x,136//2+vqts((x+t)%256)*50,10+vqts((x+t)%256)*4)	
	end

	for y = 0, 135 do
	for x = 0, 239 do
		c = pix(x,y)
		c = math.max(c-1,0)
		pix(x,y,c)
	end
	end

	t=t+1
end
