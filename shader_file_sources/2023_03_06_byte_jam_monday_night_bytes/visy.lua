local lev = {
0,0,1,1,2,2,3,3,
0,0,1,1,2,2,3,3,
0,0,1,1,2,2,3,3,
0,0,1,1,2,2,3,3,
0,0,1,1,2,2,3,3,
0,0,1,1,2,2,3,3,
0,0,1,1,2,2,3,3,
0,0,1,1,2,2,3,3
}

local w = 14
local h = 14

local tile_w = 16
local tile_h = 8

xo = 112+tile_w/2

function tile(x,y,c,yo)
	local xs = xo + (x-y) * tile_w/2
	local ys = yo + (x+y) * tile_h/2



	line(xs,ys,xs-tile_h,ys+4,c)
	line(xs,ys,xs+tile_h,ys+4,c)
	line(xs-tile_w/2,ys+4,xs,ys+tile_h,c)
	line(xs,ys+tile_h,xs+tile_w/2,ys+4,c)


--	rectb(xs,ys,tile_w,tile_h,c)

end

function TIC()
	cls(0)

	t=time() % 4000

 for z=1,h do 

 for y=1,h do 
 	for x=1,w do
			local yy = 4-math.cos(x*0.5+y*0.5+t*0.01+z)*8

			for yo = 0, yy do
			 yo = math.cos(time()*0.0003)*100+yo + math.cos(2.5+y*(t*0.0004 % 16)+x*10.5+t*0.005)*2-z*8
				tile(x,y,((t*0.001+x+y)%4+time()*0.004+z)%16 ,yo)
			end
		end 
	end 
	end
end