function TIC()
	local t=time()*.001
	for y=0,135 do
		for x=0,239 do
			local dx=x*0.4
			local dy=y*0.8


			pix(x,y,1+math.sin(dx+dy*(t+dx)))
		end
	end

	local text="HALLO!"
	local text2='WAS?'
	local x=78
	local y=75-math.abs(math.sin(t*3)*30)
	local y2=78-math.abs(math.cos(t*4)*35)
	
	print(text,x-50,y+1,12,false,5)
	print(text2,x,y2,19,false,7)
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>