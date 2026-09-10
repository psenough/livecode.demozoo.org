t=0

particle = {}

function add(x,y)
	local p = {}
	p.x = x+0.0
	p.y = y+0.0
	p.ox = x+0.0
	p.oy = y+0.0
	p.ax = 0.0
	p.ay = 0.0
	p.radius = 4.0+math.random(8)
	p.t = 0.0
	table.insert(particle,p)
end

function updatePos(k,p,dt)
	local vx = p.x - p.ox
	local vy = p.y - p.oy
	
	p.ox = p.x
	p.oy = p.y
	p.x = p.x + vx + p.ax * (dt * dt)
	p.y = p.y + vy + p.ay * (dt * dt)

	p.radius = p.radius-0.02
	
	if p.radius <= 0 then
		return true
	end
	p.ax = 0
	p.ay = 0
	return false
end

function accel(p,ax,ay)
	p.ax = p.ax + ax
	p.ay = p.ay + ay
end

tt = 0
gravity = 0.5
frame_dt = 1.0/60.0
sub_steps = 4

function applyGravity()
	for k,p in pairs(particle) do
		accel(p,0,gravity)
	end
end

function applyConstraint()
	local cx = 128
	local cy = 64
	local cr = 64
	
	for k,p in pairs(particle) do
		local tx = cx - p.x
		local ty = cy - p.y
		local distance = math.sqrt(tx*tx + ty*ty)
		
		if (distance > math.abs(cr-p.radius)) then
			local nx = tx / distance
			local ny = ty / distance
			p.x = cx - nx * (cr - p.radius)
			p.y = cy - ny * (cr - p.radius)
		end
	end
end

function checkCollisions(dt)
	local resp_coef = 0.75
	k2 = 0
	for k,p in pairs(particle) do
		obj_1 = particle[k]
		k2=k+1
		if (k2 > 0 and k2 <= #particle) then
			obj_2 = particle[k2]	
			local vx = obj_1.x - obj_2.x
			local vy = obj_1.y - obj_2.y
			local dist2 = vx * vx + vy * vy
			local min_dist = obj_1.radius + obj_2.radius
			
			if (dist2 < min_dist * min_dist) then
				local dist = math.sqrt(dist2)
				local nx = vx / dist
				local ny = vy / dist
				local mass_ratio_1 = obj_1.radius / (obj_1.radius + obj_2.radius)
				local mass_ratio_2 = obj_2.radius / (obj_1.radius + obj_2.radius)
				local delt = 0.5 * resp_coef * (dist - min_dist)

 			obj_1.x = obj_1.x - (nx * (mass_ratio_2 * delt))
				obj_1.y = obj_1.y - (ny * (mass_ratio_2 * delt))

				obj_2.x = obj_2.x + (nx * (mass_ratio_1 * delt))
				obj_2.y = obj_2.y + (ny * (mass_ratio_1 * delt))

			end
		end
	end
end

function update(dt)
	removed = {}
	for k,p in pairs(particle) do
		if updatePos(k,p,dt) then
		 table.insert(removed,k)
		end
	end

	for k2,i in pairs(removed) do
		table.remove(particle,i)
	end	
end


function solve(dt)
	tt = tt + dt
 applyGravity()
 checkCollisions()
 applyConstraint()
 update(dt)
end

function particles(dt)

	solve(dt)

	for k,p in pairs(particle) do
	 local x = math.floor(p.x)
	 local y = math.floor(p.y)
	 circ(x,y,p.radius,10+p.radius % 6)
	end

end

deltat=0
et=0
st=0
accu = 0

add(130,40)

function TIC()
cls()
t=time()//32
st = t
deltat = st-et
accu = accu + deltat
if accu > 0 then
	accu = 0
	add(90+math.random(64),64)
end
particles(deltat)
et = time()//32
end