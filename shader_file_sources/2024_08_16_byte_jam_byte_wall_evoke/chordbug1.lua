-- Welcome to the Evoke ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /VioletRaccoon

function TIC()
 cos=math.cos
 sin=math.sin
 max=math.max
 min=math.min
	local t=time()*.001
	local amt=math.floor(t*.6)
	for y=0,135 do
		for x=0,239 do
			local dx=120-x
			local pulse = 1/(t*2%1+.1)
			local dy=68-y
			--dy = dy+sin(dy/11+t)*cos(t*0.7)*4
			local d=(dx^2+dy^2)^.5
			local c=0
			if d<5 then
			  c=2.6+t
			else
		  	d=max(50,d)
		  	local a=math.atan2(dy,dx)
					local n=8
		  	c=100/d+sin(a*n+t)*0.6+t
			end
			c = math.floor(c%3)*3+1
			pix(x,y,c)
			-- pix(x,y,8+math.sin(d*.1+a-t)*3)
		end
	end

	local text="foldr.moe"
	for i=1,#text do
	  local y=75-math.abs(sin(t*3+i/3)*30)
	for dx=-1,1 do for dy=-1,1 do
	print(text:sub(i,i),30+i*16+dx,y+dy,dx+dy+1,false,3)
	end end
	
	print(text:sub(i,i),30+i*16,y,12,false,3)
	--print(text,x,y,12,false,3)
	end
end