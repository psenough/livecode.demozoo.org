-- pos: 0,0
t = 0
for y=0,136 do 
	for x=0,240 do
		pix(x,y,(x+y+t)>>2)
	end 
end 

function dist( x1, y1, x2, y2 )
	return (x2-x1)^2 + (y2-y1)^2
end
function TIC()
	t=time()*0.002
	for y=t%2,136,1 do 
		for x=t%2,240,1 do
		 local cc = pix(x,y)-0.1
			if cc < 0 then cc = 0 end
			pix(x,y,cc)
		end
	end	
	aa = 64+math.cos(t*0.5)*16
	for y=0,136,3 do 
		for x=0,240,2 do
		 local px = 120 + math.sin(t)*aa
		 local py = 136/2 + math.cos(t)*aa
		 c = dist(x,y,px,py)
			print(x%8,-16+t*10%16+x*8,-16+y*4+t*10%16,t*0.1+x*0.1)
			pix(x,y,t+t%(pix(x,y)-c*0.001))
			pix(x+1,y,t+t*2%(pix(x,y)-c*0.002))
			pix(x+1,y+1,t+t*3%(pix(x,y)-c*0.001))
		end 
	end 
	
	for x = 0, 240,1 do
		for y = 136/1.5,136 do
			pix(x,y,math.floor(x*0.1+y*0.1+t*2-y*0.5*math.sin(y*0.1+t*0.1)*0.1)%4 - 9+pix(x,136-y*1.01))
		end
	end
end