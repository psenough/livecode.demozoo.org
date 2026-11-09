-- pos: 0,0
sin=math.sin
cos=math.cos
rnd=math.random
pi =math.pi
max=math.max

zMax = 15

function setcolor(num, r, g, b)

	poke(16320+num*3+0, r)
	poke(16320+num*3+1, g)
	poke(16320+num*3+2, b)

end

function getcolor(num)

	local r=peek(16320+num*3+0)
	local g=peek(16320+num*3+1)
	local b=peek(16320+num*3+2)
	
	return r,g,b

end

for i=0,47 do
	poke(16320+i,i*5)
end

-- z,dx,dy,x,y
local tiles={}

function newTile(z)
	
	local ang=(rnd()^2)*pi*2
	
	local dx = 1
	local dy = sin(ang)/4
	
	local x=-5-z
	local y=rnd()*196-64
	
	return {z,dx,dy,x,y}
end

tDebug=0
cls()
function TIC()

	t=time()*60//1000
	
	for band=0,2 do
		if rnd()<.025 then
			local r,g,b = getcolor(15)
			if band==0 then
				r=rnd()*256
			elseif band==1 then
				g=rnd()*256
			else
				b=rnd()*256
			end
			setcolor(15,r,g,b)
		end
	end
	
	table.insert(tiles,newTile(rnd()*zMax//1))
	
	for x=0,239 do
		for y=0,135 do
			local c=pix(x,y)
			if c==0 then
				pix(x,y,rnd()*15)
			else
				pix(x,y,max(c-1,0))
			end
		end
	end
	
	for z=0,zMax do
		for n=1,#tiles do
			local tile=tiles[n]
			if tile[1] <= z then
				rectb(tile[4]-z,tile[5]-z,11,11,z)
			end
		end
	end
	
	local tilesNew = {}
	for ind, point in pairs(tiles) do
		
		local z,dx,dy,x,y = table.unpack(point)
		
		x=x+dx*max(1,fft(0,9))
		y=y+dy*max(1,fft(0,9))
		
		if x<256 then
			table.insert(tilesNew, {z,dx,dy,x,y})
		end
		
	end
	
	tiles=tilesNew
end
