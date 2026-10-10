-- ps says banana!!!

local acc=0

function TIC()
	poke (0x3FFB,0)
	local t=time()//128
	cls(t)
	poke(0x3FF8,t)
	acc = acc + fft(2)
	if acc > 50 then acc = 0 end
	--for y=0,136 do
		for x=0,240 do
	
			local tsl = 1--time()//32
			circ(x,fft(x)*200//1,acc,(x>>3+tsl)%16)
			circ(x,135-fft(x)*200//1,acc,(x>>3+tsl)%16)

			local c = 8+math.sin(time()//1000)*8
			local w = 14+math.sin(x*2+time()/400)*12 +
														math.sin(time()/2000+x/4+acc)*2
													-math.sin(x/14+time()/1000)*8
			circ(x,
								68+math.sin(time()/1000)*(fft(1)/2)*w*(x%3-1)*4,
								w,
								c+w/2)
		end

		math.randomseed(time()/2000//4)
  local sf =	3+math.random()*3//1
  math.randomseed(time())
		for x=0,240,sf do
			if math.random()>fft(1)+fft(2)+fft(3) then
					local c=pix(x,68)
					local sx=math.sin(time()/1000+x/16)*20*fft(0)
													-math.sin(x/14+time()/1000)*88*fft(2)
					rect(x,0,2,30+sx,c)
					rect(x,137-(30+sx),2,30+sx,c)
			
			end
		end

		math.randomseed(time()//200)
		for i=0,100 do
			local x=math.random(240)
			local y=math.random(136)
			local c=pix(x,y)
			local len = 3+30*fft(1)
			local len2 = 3+50*fft(4)
			if fft(0) > 0.05 then c = 0 end
			line(x-len,y,x+len,y,c)
			line(x,y-len,x,y+len,c)
			circ(x,y,len2,c)
		end
		
		vbank(1)
		cls(0)
	 
	 math.randomseed(time()//200)
		for i=0,100 do
			local x=math.random(240)
			local y=math.random(136)
			local c=pix(x,y)
			local len = 3+30*fft(1)
			local len2 = 3+50*fft(4)
			if fft(0) > 0.05 then c = 0 end
			circ(x,y,len2/2,12)
		end
		
		local wx = math.sin(time()/200)*5
		local wy = math.sin(time()/400)*30
		print("banana worm is real!",11+wx,65+1+wy,15,false,2)		
		print("banana worm is real!",10+wx,65+wy,12,false,2)


		vbank(0)


-- end
end

function BDR(l)
--	for x=0,240 do
--		pix(x,l-1,pix(x,l+math.sin(time()/200+fft(3)*10)*1.5))
--	end
	
 poke(0x3FF9,math.sin(acc+l*2)*math.sin(time()/2000+fft(0))*3)
end