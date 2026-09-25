-- PotcFdk @ Deadline 2024

local W,H=240,136

function ROT(i,r)
	return {
		x = math.cos(r)*i.x + 0 + math.sin(r)*i.z,
		y = 0 + 1*i.y + 0,
		z = (-math.sin(r))*i.x + 0 + math.cos(r)*i.z
	}
end

function c3D2D (i)
	return {
		x = i.x/(i.z+W)*W/2+W/2,
		y = i.y/(i.z+H)*H/2+H/2,
	}
end

local stars={}

function cStar()
	local x,y=math.random()*W*20-W*10,math.random()*H*20-H*10
	return {x=x,y=y,z=math.random()*3000}
end

for i=1,300 do
	table.insert(stars, cStar())
end

local SP = {
	{x=-100,y= 50,z=-100},
	{x= 100,y= 50,z=-100},
	{x=-100,y= 50,z= 100},
	{x= 100,y= 50,z= 100},
	{x=   0,y=-50,z=  0}
}

function sP (iter, rot, col, big)
	local p = {
		x = math.random(),
		y = math.random(),
		z = math.random()
	}
	for i=1,iter do
	 local proj = c3D2D(ROT(p,rot))
		if big then
			circ(proj.x*2-W/2, proj.y*1.5-50, big, col)
		else
			pix(proj.x*2-W/2, proj.y*1.5-50, col)
		end
		--end
		local r=SP[math.floor(math.random()*5)+1]
		p.x=(p.x+r.x)/2
		p.y=(p.y+r.y)/2
		p.z=(p.z+r.z)/2
	end
end

cls()

function cls()
	for x=0,W do
		for y=0,H do
		 local c = pix(x,y)-1
			pix(x,y,c < 0 and 0 or c)
		end
	end
end

local _b2
function TIC()
 if _b2 then
		cls()
	end
	_b2 = not _b2
	for idx, star in next, stars do
	 local proj=c3D2D(star)
			circ(proj.x, proj.y, 1, 12)
		star.z=star.z-4
		if star.z <= 0 then
			stars[idx] = cStar()
		end
	end

	sP(1e3,time()/1e3,0, 5)	
	sP(2e4,time()/1e3,1)
	print("PotcFdk",57,100,0,false,3)
	--print(text,x,y,10,false,3)
end