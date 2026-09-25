-- pos: 0,0
-- qwerty keyboards... :(
m=math
s=m.sin
c=m.cos

bx=0
by=0
dx=1
dy=1
-- start off boring (no wait I mean classic)
-- I cant remember how to do affine nonsense :(
-- imagine this is in a cool transform
function TIC()t=time()/200
	for x=0,240 do
		for y=0,138 do
			X=x
			Y=y
			if x>120 then t=time()/100 end -- splitscreen? uhhh
			pix(X,Y,s(s(X)/16+t)+s(Y/8)+t)
		end end
		-- sure thatll do
		-- uhh draw some stuff in front of it? 
		-- wait
		-- damn qwerty!!!!!
end

function OVR()
-- nico draws from memory 
-- nico gives up drawing from memory
		print("DVD", bx,by,12,0,2)

		bx=bx+dx
		by=by+dy
		-- this is not how to flip a vector
		-- apologies for my crimes against coding 
		-- I know yll in discord are correcting my code live 
		if bx > 240-(6*6) then dx = -1 end
		if by > 138-12 then dy = -1 end
		if bx < 0 then dx = 1 end
		if by < 0 then dy = 1 end
		
		
end