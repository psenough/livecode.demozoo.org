t=0
w=240
h=136

math.randomseed(tstamp())

cables = {
	{n = "USB cable", params = {
		0.1, 0.1, 0.2, 0.1,
		0.12, 0.2, 0.15,
		15, 13},
		c = 15,
	},
	{n = "USB B cable", params = {
		0.1, 0.1, 0.26, 0.12,
		0.12, 0.18, 0.12,
		2, 13},
		c = 2,
	},
	{n = "MIDI cable", params = {
		0.05, 0.1, 0.2, 0.12,
		0.12, 0.18, 0.12,
		15, 13},
		c = 14,
	},
	{n = "composite video cable", params = {
		0.05, 0.1, 0.2, 0.08,
		0.1, 0.14, 0.1,
		4, 13},
		c = 15,
	},
	{n = "Wii Power Cable", params = {
		0.05, 0.1, 0.2, 0.08,
		0.1, 0.14, 0.1,
		14, 15},
		c = 15,
	},
	{n = "TI-83+ Link Cable", params = {
		0.08, 0.08, 0.16, 0.14,
		0.08, 0.1, 0.05,
		15, 4},
		c = 15,
	},
	{n = "Serial cable", params = {
		0.05, 0.1, 0.14, 0.08,
		0.24, 0.4, 0.35,
		14, 13},
		c = 14,
	},
	{n = "Amiga RGB cable", params = {
		0, 0.1, 0.2, 0.08,
		0.15, 0.32, 0.28,
		14, 13},
		c = 14,
	},
}

bcolsets = {
	{11, 11, 12, 4, 4, 12},
	{12, 5, 6, 5},
	{12, 13},
	{12, 5, 6, 4},
	{10, 11, 12, 11, 10}
}

tcolsets = {
	{10, 11, 12},
	{6, 5, 12},
	{3, 4, 12},
	{2, 3, 12},
}

cable_index = math.random(1, #cables)

	-- trigeometric properties
p1 = 0.5 + 0.5 * math.random()
p2 = 2.0 - 1.0 * math.random()
a1 = 0.6
a2 = 0.3

cable_length = 100 -- number of dots
cable_sep = 0.05

s_size = 2.0
clscol = 12
bcols = {0}

init = false

function reset()
	cable_index = math.fmod(cable_index - 1, #cables) + 1

	measure_header = nil
	measure_name = nil

	bcols = bcolsets[math.random(1, #bcolsets)]
	tcols = tcolsets[math.random(1, #tcolsets)]
end

function TIC()
	if not init then
		reset()
		init = true
	end
	
	--cls(clscol)

	if btnp(4) or btnp(5) then
		cable_index = cable_index + 1
		reset()
	end
	
	-- draw stuff
	
	local tt = t * 0.05
	
	s_size = 1.2 + math.sin(0.37 * tt) * 0.4
	
	-- background
	local ampl = 2
	local thw, thh = 32, 16
	local trindex = 0
	for y = 0, h+16, 16 do
		for x = 0, w+16, 16 do
			local c = bcols[(trindex % #bcols)+1]
			local i = (x + y * w * 0.2) + t * 0.05
			local px = x + math.cos(i)*ampl
			local py = y + math.sin(i)*ampl
			tri(
				px-thw, py-thh,
				x+thw, y-thh,
				px, py+thh,
				c)
			trindex = trindex + 1
		end
	end
	
	local travel = -0.03
	
	local conn_a
	local conn_x
	local conn_y
	
	-- evaluate points along the wire
	local wc = cables[cable_index].c
	for i = 0, cable_length do
		local offset = cable_sep * i
		local x = math.cos(p1 * (tt - offset) + travel * i) * a1
		local y = math.sin(p2 * (tt - offset) + travel * i) * a2
		
		local wx, wy = x, y
		
		wx = wx * (h/w) -- aspect rcatio
 	wx = ((wx / s_size) + 0.5) * w
 	wy = ((wy / s_size) + 0.5) * h
  
  if i == 0 then
  	-- this is the connector position
   	local dx = -math.sin(p1 * tt)
				local dy = math.cos(p2 * tt)
				conn_a = math.atan(dy, dx)
				conn_x = x
				conn_y = y
  else
  	-- part of the wire
			circ(wx, wy, 5 / s_size, wc)
		end
	end
	
	-- now, draw the connector
	local params = cables[cable_index].params
	
	pixels(conn_x, conn_y, conn_a, params, false)
	
	local name = cables[cable_index].n .. "?"
	local header = "Does anyone have a"
	
	if measure_header == nil then
		measure_header = print(header, -100, -100, 0, false, 2)
		measure_name = print(name, -100, -100, 0, false, 2)
	end
	
	local tsin = math.sin(tt) * 4
	local tcos = math.cos(tt) * 4
	printfancy(0.5 * w - 0.5 * measure_header, 16 + tsin, header, 2, table.unpack(tcols))
	printfancy(0.5 * w - 0.5 * measure_name, h-24 + tcos, name, 2, table.unpack(tcols))
	
	t=t+1
end

function printfancy(x, y, text, scale, c1, c2, c3)
	
	print(text, x+3, y,   c3, false, scale)
	print(text, x-3, y,   c3, false, scale)
	print(text, x,   y+3, c3, false, scale)
	print(text, x,   y-3, c3, false, scale)
	print(text, x+2, y+2, c3, false, scale)
	print(text, x-2, y+2, c3, false, scale)
	print(text, x+2, y-2, c3, false, scale)
	print(text, x-2, y-2, c3, false, scale)
	

	print(text, x+1, y  , c2,  false, scale)
	print(text, x-1, y  , c2,  false, scale)
	print(text, x  , y+1, c2,  false, scale)
	print(text, x  , y-1, c2,  false, scale)
	
	print(text, x,   y,   c1,  false, scale)
	
end

function pixels(ox, oy, a, params, clear)
	for y = 0, h-1 do
		for x = 0, w-1 do
		
			-- origin at center
			xx = (-0.5 + (x/w)) * s_size
			yy = (-0.5 + (y/h)) * s_size 
			
			-- aspect ratio
			xx = xx * (w/h)
			
			xx = xx - ox
			yy = yy - oy
			
			--local a = t * 0.02
			xx, yy = rot(xx, yy, a)
			local c = connector(xx, yy,
				table.unpack(params))
			
			if c then
				if clear then c = clscol end
				pix(x, y, c)
			end
		end
	end
end

function connector(x, y,
		h1, h2, h3, h4, w1, w3, w4, c1, c4)
	
	-- aligned pointing to the right
	
	-- symmetry
	local y = math.abs(y)
	w1 = 0.5 * w1
	w3 = 0.5 * w3
	w4 = 0.5 * w4
	
	if x < -h1/2 then return end
	
	-- section 1
	if x < h1/2 then
		if y < w1 then return c1 else return end
	end
	
	-- section 2
	if x < h1/2 + h2 then
		local inter = math.max(0, (x - h1/2) / h2)
		local ww = w1 + inter * (w3 - w1)
		if y < ww then return c1 else return end
	end
	
	-- section 3
	
	if x < h1/2 + h2 + h3 then
		if y < w3 then return c1 else return end
	end
	
	-- section 4
	if x < h1/2 + h2 + h3 + h4 then
		if y < w4 then return c4 else return end
	end
	
	-- ...
end

function rot(x, y, a)
	local rx = math.cos(a) * x + math.sin(a) * y
	local ry = math.cos(a) * y + math.sin(a) * -x
	return rx, ry
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>