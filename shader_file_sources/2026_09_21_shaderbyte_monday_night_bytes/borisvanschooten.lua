-- BORIS stars and spheres 21 sep 2026

-- Constants

sin = math.sin
cos = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
floor = math.floor
pi = math.pi

H = 136
W = 240
T = 0

TICPAL = {
  {  26,  28,  44}, -- #1a1c2c
  {  93,  39,  93}, -- #5d275d
  { 177,  62,  83}, -- #b13e53
  { 239, 125,  87}, -- #ef7d57
  { 255, 205, 117}, -- #ffcd75
  { 167, 240, 112}, -- #a7f070
  {  56, 183, 100}, -- #38b764
  {  37, 113, 121}, -- #257179
  {  41,  54, 111}, -- #29366f
  {  59,  93, 201}, -- #3b5dc9
  {  65, 166, 246}, -- #41a6f6
  { 115, 239, 247}, -- #73eff7
  { 244, 244, 244}, -- #f4f4f4
  { 148, 176, 194}, -- #94b0c2
  {  86, 108, 134}, -- #566c86
  {  51,  60,  87}, -- #333c57
}


function TIC()
  cls(0)
  --TIC1()
  TIC2()
  icosphere(9,T)
  icosphere(4,T+150)
  icosphere(13,T+550)
  T = T + 1
end



function icosphere(basecol,T)
	-- Build a subdivided icosahedron once.
	if not ICOSPHERE_MESH then
		local phi = (1 + math.sqrt(5)) / 2

		local vertices = {
			{-1, phi, 0},
			{ 1, phi, 0},
			{-1,-phi, 0},
			{ 1,-phi, 0},
			{ 0,-1, phi},
			{ 0, 1, phi},
			{ 0,-1,-phi},
			{ 0, 1,-phi},
			{ phi, 0,-1},
			{ phi, 0, 1},
			{-phi, 0,-1},
			{-phi, 0, 1}
		}

		local faces = {
			{1,12,6}, {1,6,2},  {1,2,8},  {1,8,11}, {1,11,12},
			{2,6,10}, {6,12,5}, {12,11,3},{11,8,7}, {8,2,9},
			{4,10,5}, {4,5,3},  {4,3,7},  {4,7,9},  {4,9,10},
			{5,10,6}, {3,5,12}, {7,3,11}, {9,7,8},  {10,9,2}
		}

		local function normalize(v)
			local length = math.sqrt(
				v[1] * v[1] +
				v[2] * v[2] +
				v[3] * v[3]
			)

			return {
				v[1] / length,
				v[2] / length,
				v[3] / length
			}
		end

		local function midpoint(a, b)
			return normalize({
				(a[1] + b[1]) * 0.5,
				(a[2] + b[2]) * 0.5,
				(a[3] + b[3]) * 0.5
			})
		end

		for i = 1, #vertices do
			vertices[i] = normalize(vertices[i])
		end

		local triangles = {}

		local function subdivide(a, b, c, depth)
			if depth == 0 then
				triangles[#triangles + 1] = {a, b, c}
				return
			end

			local ab = midpoint(a, b)
			local bc = midpoint(b, c)
			local ca = midpoint(c, a)

			subdivide(a,  ab, ca, depth - 1)
			subdivide(b,  bc, ab, depth - 1)
			subdivide(c,  ca, bc, depth - 1)
			subdivide(ab, bc, ca, depth - 1)
		end

		for i = 1, #faces do
			local face = faces[i]

			subdivide(
				vertices[face[1]],
				vertices[face[2]],
				vertices[face[3]],
				2
			)
		end

		ICOSPHERE_MESH = triangles
	end

	--cls(13)

	local angleY = T * 0.018
	local angleX = T * 0.011

	local cy = math.cos(angleY)
	local sy = math.sin(angleY)
	local cx = math.cos(angleX)
	local sx = math.sin(angleX)

	local screenX = 120 + 60*sin(0.012*T)
	local screenY = 68 + 40*sin(0.009*T)
	local cameraDistance = 4.2 + 1.0*sin(0.023*T)
	local projectionScale = 104

	local transformed = {}

	local function rotate(v)
		-- Rotate around the Y axis.
		local x1 = v[1] * cy + v[3] * sy
		local y1 = v[2]
		local z1 = -v[1] * sy + v[3] * cy

		-- Rotate around the X axis.
		local x2 = x1
		local y2 = y1 * cx - z1 * sx
		local z2 = y1 * sx + z1 * cx

		return {x2, y2, z2}
	end

	local function project(v)
		local depth = v[3] + cameraDistance
		local scale = projectionScale / depth

		return {
			screenX + v[1] * scale,
			screenY - v[2] * scale,
			depth
		}
	end

	for i = 1, #ICOSPHERE_MESH do
		local source = ICOSPHERE_MESH[i]

		local a = rotate(source[1])
		local b = rotate(source[2])
		local c = rotate(source[3])

		local abx = b[1] - a[1]
		local aby = b[2] - a[2]
		local abz = b[3] - a[3]

		local acx = c[1] - a[1]
		local acy = c[2] - a[2]
		local acz = c[3] - a[3]

		local nx = aby * acz - abz * acy
		local ny = abz * acx - abx * acz
		local nz = abx * acy - aby * acx

		local centerX = (a[1] + b[1] + c[1]) / 3
		local centerY = (a[2] + b[2] + c[2]) / 3
		local centerZ = (a[3] + b[3] + c[3]) / 3

		local viewX = -centerX
		local viewY = -centerY
		local viewZ = -cameraDistance - centerZ

		-- Keep only triangles facing the camera.
		if nx * viewX + ny * viewY + nz * viewZ > 0 then
			local normalLength = math.sqrt(nx * nx + ny * ny + nz * nz)

			nx = nx / normalLength
			ny = ny / normalLength
			nz = nz / normalLength

			-- Directional light.
			local light = nx * -0.35 + ny * -0.55 + nz * -0.76
			light = math.max(0, light)

			local colors = {8, 9, 10, 11, 12}
			local colorIndex = 1 + math.floor(light * 4)
			local color = colors[colorIndex]

			local pa = project(a)
			local pb = project(b)
			local pc = project(c)

			transformed[#transformed + 1] = {
				a = pa,
				b = pb,
				c = pc,
				depth = (pa[3] + pb[3] + pc[3]) / 3,
				color = color
			}
		end
	end

	-- Painter's algorithm: draw distant triangles first.
	table.sort(
		transformed,
		function(a, b)
			return a.depth > b.depth
		end
	)

	for i = 1, #transformed do
		local face = transformed[i]
		local a = face.a
		local b = face.b
		local c = face.c

		tri(
			a[1], a[2],
			b[1], b[2],
			c[1], c[2],
			basecol+face.color
		)

		-- Dark wireframe edges.
		line(a[1], a[2], b[1], b[2], 0)
	 line(b[1], b[2], c[1], c[2], 0)
		line(c[1], c[2], a[1], a[2], 0)
	end
end



--------------------------------------
-- 2 starfield -----------------------
--------------------------------------

STARS = {}
STAR_COUNT = 50
ROTATION_SPEED = 0.018

function BOOT()
    for i = 1, STAR_COUNT do
        STARS[i] = {
            x = math.random() * 7 - 2,
            y = math.random() * 7 - 1.5,
            z = math.random() * 7 - 2,
            size = math.random() * 8 + 2,
            phase = math.random() * math.pi * 2
        }
    end
end

-- Projects a 3D point onto the 240x136 TIC-80 screen.
function project(x, y, z)
    local distance = 4
    local scale = distance / (z + distance + 2.5)

    return 120 + x * 42 * scale,
           68 + y * 42 * scale,
           scale
end

-- Draws a five-point star.
function drawStar(cx, cy, radius, angle, color)
    local previousX
    local previousY

    for i = 0, 10 do
        local pointRadius

        if i % 2 == 0 then
            pointRadius = radius
        else
            pointRadius = radius * 0.42
        end

        local pointAngle =
            angle + i * math.pi / 5 - math.pi / 2

        local x = cx + math.cos(pointAngle) * pointRadius
        local y = cy + math.sin(pointAngle) * pointRadius

        if i > 0 then
            line(previousX, previousY, x, y, color)
        end

        previousX = x
        previousY = y
    end
end


function TIC2()

    local rotation = T * ROTATION_SPEED / 1

    -- Static background stars
    math.randomseed(8)

    for i = 1, 45 do
        local x = math.random(0, 239)
        local y = math.random(0, 135)
        local color = 1

        if math.random() > 0.7 then
            color = 13
        end

        pix(x, y, color)
    end

    for i = 1, STAR_COUNT do
        local star = STARS[i]

        -- Rotate around the Y axis.
        local x =
            star.x * math.cos(rotation) -
            star.z * math.sin(rotation)

        local z =
            star.x * math.sin(rotation) +
            star.z * math.cos(rotation)

        -- Rotate around the X axis.
        local y =
            star.y * math.cos(rotation * 0.63) -
            z * math.sin(rotation * 0.63)

        z =
            star.y * math.sin(rotation * 0.63) +
            z * math.cos(rotation * 0.63)

        local screenX, screenY, scale = project(x, y, z)

        local color
        if z > 0 then
            color = 4
        elseif i % 2 == 0 then
            color = 12
        else
            color = 10
        end
        color = 11 - (1.0*z)
        if (color > 11) then color = 11 end
        if (color < 8) then color = 8 end
        
        drawStar(
            screenX,
            screenY,
            star.size * scale,
            rotation * 1.4 + star.phase,
            color
        )
    end

end



