-- Welcome to the Deadline ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /RaccoonViolet

local S,MAX=math.sin,math.max

function TIC()
	cls()
	local t=time()*.1
	for y=0,135 do
		local o=0
		local step=MAX(32+S(S(y*.03-t*.007)+S(y*.022))*28,2)
        local xofs=S(y*.03+t*.017)*10
        local xmax=119+step
		for x=0,xmax,step do
            local x1=120-x+xofs
            local x2=120+x+xofs
            line(x1,y,x1-step,y,2+o*10)
            o=(o+1)%2
            line(x2,y,x2+step,y,2+o*10)
		end		
	end

	local text="ByteWall!"
	local x=50
	local y=75-math.abs(math.sin(t*0.03)*30)
	print(text,x-1,y-1,12,false,3)
	print(text,x+1,y+1,7,false,3)
	print(text,x,y,10,false,3)
end