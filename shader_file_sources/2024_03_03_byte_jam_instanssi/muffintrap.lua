R=math.random

balls={}
	
	for b=0, 40 do
		balls[b]={x=math.random(240), 
		y=136+math.random(200),
		c=3+R(6),
		r=4+R(12),
		p=math.pi*R()}
	end
	
function DrawBalls(cutR)

	for b=0, #balls do
		balls[b].y=balls[b].y-1
		balls[b].p=balls[b].p+0.01
		if balls[b].y<-10 then 
			balls[b].y=140+R(400) 
		end
		B=balls[b]
		c=B.c
		r=B.r+math.sin(B.p)*6
		if (cutR<0 and r<math.abs(cutR)) 
		or (cutR>0 and r>cutR) then
			x=B.x+math.cos(B.p)*120
			circ(x, balls[b].y,r, c)
			circ(x-3, balls[b].y-r*0.3,r*0.6, c-1)
			circ(x-5, balls[b].y-r/2,r*0.2, 12)
		end
	end

end

function TIC()t=time()//32

	-- THANKS FOR THE JAMSSSS
	
	-- SEE YOU TOMORROW!

	pattern=t
	sz=2
	for y=-68,68,sz do 
		for x=-120,120,sz do
			v=math.abs(x)|math.abs(x*y+pattern)
			rect(120+x,68+y,sz,sz,8+v>>2)
		end 
	end 

	
	--[[
	-- LETS TRY FFT???
	for f=0, 136 do 
		rect(0, f*10, fft()*240, 10, 12)
		print(">"..fft(f),2,f*10,12)
	end
	]]--
	DrawBalls(-5)
	
	for l=0, 12 do
		rect(math.sin(t/8+l/2)*50+120,
			l*10,10,136,12-l)
	end
	
	DrawBalls(5)
	
	for r=0, 20 do 
		ux = 10 + math.sin(t/10+r)*10
		print("Untz",ux+1,(t%12)+r*12+1,0)
		print("Untz",ux,(t%12)+r*12,12)
	end
	
	
	for r=0, 20 do 
	bx = 200 + math.cos(t*0.5+r/2)*10
	print("Bnys",bx+1,0-(t%12)+r*12+1,0)
		print("Bnys",bx,0-(t%12)+r*12,12)
	end
end
