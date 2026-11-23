-- Boris - moving textures

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

-- sprites

NIBBLES_IN_SPR=8*8
SPR_SHEET_ADDR=0x4000*2 -- nibble address
FONT1_ADDR = 0x14604*8  -- bit address
FONT2_ADDR = 0x14A04*8  -- bit address


function bigspr(idx,w,h,xpos,ypos,bg,scale)
  idx = w*h*idx
  local inc = 8*scale
  for y=0,h-1 do
    for x=0,w-1 do
      spr(idx,xpos+inc*x,ypos+inc*y,bg,scale)
      idx = idx + 1
    end
  end
end

function createbigspr(idx,w,h,xpos,ypos,cols)
  local x,y,sx,sy,dx,dy,segx,segy,col,baseidx
  for y=0,8*h-1 do
    for x=0,8*w-1 do
      dx = x%8
      dy = y%8
      segx = floor(x/8)
      segy = floor(y/8)
      col = cols[x + 8*w*y]
      baseidx = 8*8*w*h*idx + 8*8*(segx + w*segy)
      poke4(SPR_SHEET_ADDR + baseidx + dx + 8*dy, col)
    end
  end
end



function createTexture(idx,w,h,func,xofs,yofs)
  coltile = {}
  for x=0,8*w do
    for y=0,8*h do
      coltile[x + 8*w*y] = func(x,y,T,xofs,yofs)
    end
  end
  createbigspr(idx,w,h,xpos,ypos,coltile)
end

---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
---------------------------------------------------


local TAU = 6.283185307179586

local CLOUD_PUFFS_NEAR = {
    {  4.0, 10.0, 5.5, 2.6 },
    {  9.5,  9.0, 6.0, 3.2 },
    { 15.5, 11.0, 7.0, 3.0 },
    { 22.0,  8.5, 6.5, 2.8 },
    { 28.5, 11.0, 5.2, 2.5 },
    { 33.0, 10.0, 4.5, 2.4 }
}

local CLOUD_PUFFS_FAR = {
    {  3.0, 22.0, 7.0, 2.0 },
    { 12.0, 20.5, 8.0, 2.4 },
    { 20.0, 23.0, 6.0, 2.2 },
    { 29.0, 21.0, 6.0, 2.0 },
    { 36.0, 22.0, 5.0, 2.0 }
}

local function mod32(v)
    return v - math.floor(v / 32.0) * 32.0
end

local function wrapdist32(a, b)
    local d = math.abs(a - b)
    d = d - math.floor(d / 32.0) * 32.0

    if d > 16.0 then
        d = 32.0 - d
    end

    return d
end

local function blob32(px, py, cx, cy, sx, sy)
    local dx = wrapdist32(px, cx) / sx
    local dy = wrapdist32(py, cy) / sy

    return math.exp(-(dx * dx + dy * dy))
end

local function cloud_layer(px, py, puffs)
    local d = 0.0

    for i = 1, #puffs do
        local p = puffs[i]
        d = d + blob32(px, py, p[1], p[2], p[3], p[4])
    end

    return d
end

local function tile_wave(px, py, phase)
    local a = TAU / 32.0

    local n = 0.0
    n = n + 0.40 * math.sin(a * (px + py) + phase)
    n = n + 0.25 * math.sin(a * (2.0 * px - py) + phase * 1.7 + 1.3)
    n = n + 0.20 * math.cos(a * (-px + 3.0 * py) + phase * 0.8)
    n = n + 0.15 * math.sin(a * (4.0 * px + 2.0 * py) + phase * 2.1 + 2.2)

    return 0.5 + 0.5 * n
end

function cloud_sky_color(x, y, t, xofs, yofs)
    xofs = xofs or 0
    yofs = yofs or 0

    -- Far background sky moves slowly for parallax.
    local sky_x = x + xofs * 0.18 + t * 0.015
    local sky_y = y + yofs * 0.18

    local sky_noise = tile_wave(sky_x, sky_y, t * 0.02)
    local sky_band = 0.5 + 0.5 * math.sin(TAU * sky_y / 32.0 + 0.7)
    local sky_mix = sky_band * 0.65 + sky_noise * 0.35

    local sky_color = 10 -- #41a6f6

    if sky_mix > 0.72 then
        sky_color = 11 -- #73eff7
    elseif sky_mix < 0.25 then
        sky_color = 9 -- #3b5dc9
    end

    -- Near clouds move almost one-to-one with the offset.
    local near_x = mod32(x + xofs * 1.00 + t * 0.070)
    local near_y = mod32(y + yofs * 1.00 + math.sin(t * 0.023) * 1.25)

    -- Far clouds move more slowly, giving parallax.
    local far_x = mod32(x + xofs * 0.55 + t * 0.035 + 9.5)
    local far_y = mod32(y + yofs * 0.55 + math.sin(t * 0.017 + 1.4) * 0.85)

    local near_density = cloud_layer(near_x, near_y, CLOUD_PUFFS_NEAR)
    local far_density = cloud_layer(far_x, far_y, CLOUD_PUFFS_FAR)

    -- Tileable detail modulation.
    local detail = tile_wave(
        x + xofs * 0.85 + t * 0.050,
        y + yofs * 0.85,
        t * 0.040
    )

    local density = near_density * 0.82 + far_density * 0.60 + (detail - 0.5) * 0.33

    -- Cloud coloring.
    if density > 1.25 then
        return 12 -- white, #f4f4f4
    elseif density > 1.02 then
        if detail > 0.42 then
            return 12 -- white highlight
        else
            return 13 -- light grey, #94b0c2
        end
    elseif density > 0.78 then
        return 13 -- soft cloud edge / shadow
    elseif density > 0.65 then
        return 11 -- pale blue fringe
    end

    return sky_color
end


function animated_circles_32x32(x, y, t, xofs, yofs)
    local size = 32

    xofs = xofs or 0
    yofs = yofs or 0

    -- Wrap coordinates so offsets remain tileable.
    local px = (x + xofs) % size
    local py = (y + yofs) % size


    local background = 15

    -- Colorful circle colors.
    local colors = {
        2, 3, 4, 5, 6, 7, 9, 10, 11, 1
    }

    -- Small deterministic pseudo-random function.
    -- This avoids needing any global random state.
    local function rand(a, b)
        local v = math.sin(a * 127.1 + b * 311.7) * 43758.5453123
        return v - math.floor(v)
    end

    -- Toroidal / wrapped distance.
    -- This makes the effect tile smoothly across all edges.
    local function wrapped_distance(ax, ay, bx, by)
        local dx = math.abs(ax - bx)
        local dy = math.abs(ay - by)

        if dx > size / 2 then
            dx = size - dx
        end

        if dy > size / 2 then
            dy = size - dy
        end

        return math.sqrt(dx * dx + dy * dy)
    end

    local best_strength = 0
    local best_color = background

    local circle_count = 9
    local period = 72
    local stagger = 9

    for i = 0, circle_count - 1 do
        local local_time = t + i * stagger
        local cycle = math.floor(local_time / period)
        local age = local_time - cycle * period
        local phase = age / period

        -- Fade in and out smoothly.
        local fade = math.sin(phase * math.pi)

        if fade > 0 then
            -- New deterministic center each cycle.
            local cx = rand(i * 19 + cycle * 37, i * 11 + cycle * 13) * size
            local cy = rand(i * 23 + cycle * 17, i * 29 + cycle * 31) * size

            -- Circle expands over time.
            local radius = 1.0 + phase * 23.0

            -- Starts a bit thicker, becomes thinner as it expands.
            local thickness = 3.2 - phase * 1.8

            local d = wrapped_distance(px, py, cx, cy)

            -- Ring strength.
            local ring = 1.0 - math.abs(d - radius) / thickness

            if ring > 0 then
                local strength = ring * fade

                if strength > best_strength then
                    best_strength = strength

                    local color_index = 1 + ((i + cycle) % #colors)
                    best_color = colors[color_index]

                    -- Occasional bright highlight at the strongest part of a ring.
                    if strength > 0.82 then
                        if best_color == 10 or best_color == 11 then
                            best_color = 12
                        end
                    end
                end
            end
        end
    end

    -- Keep weak edges from flickering too much.
    if best_strength < 0.12 then
        return background
    end

    return best_color
end


function wavy_rainbow_bar(x, y, t, xofs, yofs)
    xofs = xofs or 0
    yofs = yofs or 0

    local pi = math.pi
    local tau = pi * 2

    -- Wrap coordinates to the 32x32 tile.
    local xx = (x + xofs) % 32
    local yy = (y + yofs) % 32

    -- Normalized tile coordinates, periodic over 32 pixels.
    local u = xx / 32
    local v = yy / 32

    -- Time value. Adjust these divisors/speeds to taste.
    local tt = t / 48

    -- Tileable wave distortion.
    -- All wave inputs are periodic, so the effect wraps smoothly.
    local wave =
        3.0 * math.sin(tau * (u + tt)) +
        1.5 * math.sin(tau * (u * 2 - tt * 0.7)) +
        1.0 * math.sin(tau * (u + v + tt * 0.35))

    -- Vertical rainbow bar coordinate, animated over time.
    local p = (yy + wave + t * 0.18) % 32

    -- 32-step cyclic rainbow ramp using the provided 0-based palette indices:
    --
    -- 0  = #1a1c2c
    -- 1  = #5d275d
    -- 2  = #b13e53
    -- 3  = #ef7d57
    -- 4  = #ffcd75
    -- 5  = #a7f070
    -- 6  = #38b764
    -- 7  = #257179
    -- 8  = #29366f
    -- 9  = #3b5dc9
    -- 10 = #41a6f6
    -- 11 = #73eff7
    -- 12 = #f4f4f4
    -- 13 = #94b0c2
    -- 14 = #566c86
    -- 15 = #333c57
    local ramp = {
        2, 2, 3, 3,
        4, 4, 5, 5,
        6, 6, 7, 7,
        10, 10, 11, 11,
        10, 10, 9, 9,
        8, 8, 1, 1,
        1, 2, 2, 3,
        3, 2, 2, 2
    }

    local i = math.floor(p) + 1
    return ramp[i]
end


function nebula32(x, y, t, xofs, yofs)
    xofs = xofs or 0
    yofs = yofs or 0

    local pi = math.pi
    local size = 32

    local function clamp(v, a, b)
        if v < a then return a end
        if v > b then return b end
        return v
    end

    local function wrap32(v)
        return v - math.floor(v / size) * size
    end

    local function hash(n)
        local v = math.sin(n * 12.9898) * 43758.5453
        return v - math.floor(v)
    end

    local function torus_dist2(ax, ay, bx, by)
        local dx = math.abs(ax - bx)
        local dy = math.abs(ay - by)

        if dx > size / 2 then dx = size - dx end
        if dy > size / 2 then dy = size - dy end

        return dx * dx + dy * dy
    end

    -- Offset the nebula itself by full pixel offsets.
    local u = wrap32(x + xofs)
    local v = wrap32(y + yofs)

    local ax = 2 * pi * u / size
    local ay = 2 * pi * v / size

    local tt = t * 0.025

    -- Fully periodic plasma field.
    local p =
        0.36 * math.sin(ax + 0.70 * math.sin(ay) + tt) +
        0.28 * math.sin(2 * ay - tt * 1.30) +
        0.22 * math.sin(2 * ax + 3 * ay + tt * 0.70) +
        0.14 * math.sin(3 * ax - 2 * ay - tt * 0.90)

    p = p * 0.5 + 0.5

    -- Extra cloudy variation, also tileable.
    local cloud =
        0.5 + 0.5 * math.sin(
            1.6 * math.sin(ax) +
            1.3 * math.cos(ay) +
            0.8 * math.sin(ax + ay) +
            tt * 0.8
        )

    p = clamp(p * 0.72 + cloud * 0.28, 0, 1)

    -- 0-based palette indices using the supplied 16-color palette.
    -- The function returns a value in 0..15, which is within the requested 0..31 range.
    local ramp = {
        0,   -- deep space
        15,  -- dark blue-gray
        8,   -- navy
        1,   -- purple
        2,   -- red/magenta
        3,   -- orange
        4,   -- yellow highlight
        10,  -- bright blue
        11   -- cyan glow
    }

    local ri = math.floor(p * (#ramp - 1)) + 1
    local col = ramp[ri]

    -- Stars with parallax.
    -- They use different offset scales from the nebula, so they drift separately.
    local best_star = 0

    for layer = 1, 2 do
        local parallax
        local count
        local radius

        if layer == 1 then
            parallax = 0.25
            count = 13
            radius = 0.46
        else
            parallax = 0.55
            count = 9
            radius = 0.72
        end

        local sx_sample = wrap32(x + xofs * parallax)
        local sy_sample = wrap32(y + yofs * parallax)

        for i = 1, count do
            local n = i + layer * 97

            local sx = hash(n * 2.13 + 1.7) * size
            local sy = hash(n * 5.71 + 9.2) * size

            local d2 = torus_dist2(sx_sample, sy_sample, sx, sy)
            local r2 = radius * radius

            if d2 < r2 then
                local twinkle = 0.68 + 0.32 * math.sin(t * 0.11 + i * 1.91 + layer * 2.4)
                local b = (1 - d2 / r2) * twinkle

                if b > best_star then
                    best_star = b
                end
            end
        end
    end

    -- Star colors override the nebula.
    if best_star > 0.82 then
        return 12 -- white
    elseif best_star > 0.55 then
        return 11 -- cyan
    elseif best_star > 0.32 then
        return 13 -- pale blue-gray
    end

    return col
end



function cloud_sky(x, y, t, xofs, yofs)
    -- Palette indices are assumed to be 0-based:
    -- 9  = deep blue
    -- 10 = sky blue
    -- 11 = cyan
    -- 12 = white
    -- 13 = light gray

    local pi = math.pi
    local tau = pi * 2

    -- Wrap coordinates so offsets tile cleanly over 32x32
    local function wrap32(v)
        return v % 32
    end

    -- Smoothstep helper
    local function smoothstep(a, b, v)
        local n = (v - a) / (b - a)
        if n < 0 then n = 0 end
        if n > 1 then n = 1 end
        return n * n * (3 - 2 * n)
    end

    -- Periodic wave noise.
    -- Every term uses integer frequencies, so it loops perfectly at 32 pixels.
    local function pnoise(px, py, time)
        local ax = tau * px / 32
        local ay = tau * py / 32

        local n = 0

        n = n + 0.42 * math.sin(ax * 1.0 + time * 0.021)
        n = n + 0.34 * math.cos(ay * 1.0 - time * 0.017)

        n = n + 0.25 * math.sin(ax * 2.0 + ay * 1.0 + time * 0.013)
        n = n + 0.21 * math.cos(ax * 1.0 - ay * 2.0 - time * 0.019)

        n = n + 0.16 * math.sin(ax * 3.0 + ay * 2.0 + time * 0.011)
        n = n + 0.13 * math.cos(ax * 2.0 - ay * 3.0 + time * 0.007)

        -- Normalize roughly to 0..1
        return 0.5 + n * 0.33
    end

    xofs = xofs or 0
    yofs = yofs or 0

    -- Background sky gradient, also tile-safe vertically.
    -- This is subtle so the top/bottom seam stays smooth.
    local gy = 0.5 + 0.5 * math.sin(tau * y / 32 - pi * 0.5)
    local sky = smoothstep(0.15, 0.95, gy)

    -- Parallax cloud layers.
    -- Different offset multipliers make layers slide at different speeds.
    local x1 = wrap32(x + xofs * 0.45 + t * 0.018)
    local y1 = wrap32(y + yofs * 0.45)

    local x2 = wrap32(x + xofs * 0.85 - t * 0.026)
    local y2 = wrap32(y + yofs * 0.85 + 9)

    local x3 = wrap32(x + xofs * 1.25 + t * 0.011)
    local y3 = wrap32(y + yofs * 1.25 + 17)

    local n1 = pnoise(x1, y1, t)
    local n2 = pnoise(x2, y2, t + 91)
    local n3 = pnoise(x3, y3, t + 173)

    -- Make cloudy blobs.
    local main_clouds = smoothstep(0.56, 0.76, n1)
    local soft_clouds = smoothstep(0.60, 0.82, n2) * 0.65
    local wisps       = smoothstep(0.67, 0.92, n3) * 0.45

    local cloud = main_clouds + soft_clouds + wisps
    if cloud > 1 then cloud = 1 end

    -- Slight brightening near the upper part of the tile,
    -- but still periodic and seamless.
    local highlight = 0.5 + 0.5 * math.sin(tau * y / 32 + pi * 0.25)

    -- Return palette index.
    if cloud > 0.82 then
        return 12 -- white cloud highlight
    elseif cloud > 0.62 then
        return 13 -- pale gray cloud edge
    elseif cloud > 0.42 then
        return 11 -- faint cyan haze
    else
        if sky > 0.72 then
            return 11 -- lighter blue
        elseif sky > 0.35 then
            return 10 -- sky blue
        else
            return 9 -- deeper blue
        end
    end
end

function mountain_range_color(x, y, t, xofs, yofs)
    local TAU = 6.283185307179586

    xofs = xofs or 0
    yofs = yofs or 0
    t = t or 0

    local function wrap32(v)
        return v - math.floor(v / 32) * 32
    end

    local function periodic_grain(u, v)
        return
            0.55 * math.sin(TAU * (u * 7 + v * 3) / 32) +
            0.35 * math.sin(TAU * (u * 11 - v * 5) / 32) +
            0.20 * math.sin(TAU * (u * 2 + v * 13) / 32)
    end

    local function ridge_height(u, base, amp, phase)
        return base + amp * (
            0.50 * math.sin(TAU * (u + phase) / 32) +
            0.30 * math.sin(TAU * (2 * u - phase * 0.7) / 32) +
            0.20 * math.sin(TAU * (3 * u + phase * 1.3) / 32)
        )
    end

    local function sample_mountain_layer(rate, base, amp, thickness, phase, colors)
        local u = wrap32(x + xofs * rate)
        local v = wrap32(y + yofs * rate)

        local r = wrap32(ridge_height(u, base, amp, phase))

        -- Wrapped vertical distance below the ridge.
        -- This makes the mountain layer tile vertically as well as horizontally.
        local d = wrap32(v - r)

        if d >= thickness then
            return nil
        end

        local g = periodic_grain(u + phase, v - phase)
        local shade = d / thickness + g * 0.12

        -- Snow / bright ridge line
        if d < 1.15 then
            return colors.snow
        end

        -- Thin lit edge below snow
        if d < 2.35 then
            return colors.edge
        end

        if shade < 0.28 then
            return colors.high
        elseif shade < 0.55 then
            return colors.mid
        elseif shade < 0.78 then
            return colors.low
        else
            return colors.dark
        end
    end

    -- Foreground mountain, moves fastest with offsets.
    local c = sample_mountain_layer(
        1.00,
        17.0,
        6.5,
        17.5,
        3.0,
        {
            snow = 12, -- white
            edge = 13, -- pale blue-gray
            high = 5,  -- light green
            mid  = 6,  -- green
            low  = 7,  -- teal
            dark = 15  -- dark slate
        }
    )

    if c ~= nil then
        return c
    end

    -- Mid mountain layer.
    c = sample_mountain_layer(
        0.58,
        13.5,
        5.5,
        15.0,
        11.0,
        {
            snow = 12,
            edge = 13,
            high = 14,
            mid  = 8,
            low  = 7,
            dark = 15
        }
    )

    if c ~= nil then
        return c
    end

    -- Far background mountain layer, moves slowest.
    c = sample_mountain_layer(
        0.27,
        9.5,
        4.0,
        12.0,
        21.0,
        {
            snow = 13,
            edge = 10,
            high = 9,
            mid  = 8,
            low  = 15,
            dark = 0
        }
    )

    if c ~= nil then
        return c
    end

    -- Tileable sky.
    local su = wrap32(x + xofs * 0.10 + t * 0.035)
    local sv = wrap32(y + yofs * 0.05)

    local sky_wave =
        0.70 * math.sin(TAU * (sv / 32 - 0.18)) +
        0.20 * math.sin(TAU * ((su * 2 + sv) / 32 + t * 0.002)) +
        0.10 * math.sin(TAU * ((su - sv * 2) / 32))

    local cloud =
        math.sin(TAU * ((su * 2 + sv) / 32 + t * 0.004)) +
        0.55 * math.sin(TAU * ((su * 5 - sv * 2) / 32 - t * 0.002))

    local star =
        math.sin(TAU * ((su * 7 + sv * 11) / 32 + t * 0.001)) +
        math.sin(TAU * ((su * 13 - sv * 5) / 32))

    -- Small stars in darker sky regions.
    if sky_wave < -0.25 and star > 1.88 then
        return 12
    end

    -- Soft clouds / glow.
    if cloud > 1.12 and sky_wave > -0.45 then
        return 11
    elseif cloud > 0.95 and sky_wave > -0.55 then
        return 10
    end

    -- Base sky colors.
    if sky_wave > 0.48 then
        return 10 -- bright blue
    elseif sky_wave > 0.05 then
        return 9  -- blue
    elseif sky_wave > -0.55 then
        return 8  -- dark blue
    else
        return 0  -- very dark navy
    end
end


function cloud_color(x, y, t, xofs,yofs)
  local sin = math.sin
  local TAU = 6.283185307179586

  -- Keep coordinates inside the 32x32 torus.
  x = x % 32
  y = y % 32

  local u = x / 32
  local v = y / 32
  local time = t or 0

  -- Periodic moving wave-noise.
  -- All spatial frequencies are integers, so the pattern tiles perfectly
  -- across both x and y over a 32x32 area.
  local n = 0

  n = n + 0.42 * sin(TAU * ( 1 * u +  1 * v + 0.010 * time))
  n = n + 0.31 * sin(TAU * ( 2 * u + -1 * v - 0.014 * time) + 1.7)
  n = n + 0.23 * sin(TAU * (-1 * u +  3 * v + 0.018 * time) + 2.4)
  n = n + 0.17 * sin(TAU * ( 4 * u +  2 * v - 0.011 * time) + 0.5)
  n = n + 0.11 * sin(TAU * ( 7 * u + -3 * v + 0.023 * time) + 3.1)

  -- Normalize roughly to 0..1.
  local density = 0.5 + 0.5 * (n / 1.24)

  -- Soft shaping for puffier clouds.
  density = density * density * (3 - 2 * density)

  -- A second tileable modulation gives the clouds soft bands and motion.
  local puff = 0.09 * sin(TAU * (2 * u + 1 * v - 0.009 * time))
             + 0.06 * sin(TAU * (-3 * u + 2 * v + 0.012 * time) + 2.0)

  local c = density + puff

  -- Cloud colors.
  if c > 0.82 then
    return 12 -- white cloud highlight
  elseif c > 0.75 then
    return 13 -- pale grey cloud body/shadow
  elseif c > 0.68 then
    return 11 -- cyan cloud edge
  end

  -- Tileable sky variation.
  local sky = 0.5
            + 0.30 * sin(TAU * (1 * u + 1 * v + 0.004 * time))
            + 0.20 * sin(TAU * (3 * u - 2 * v - 0.006 * time) + 1.2)

  if sky < 0.34 then
    return 9  -- deeper blue
  elseif sky > 0.82 then
    return 11 -- bright cyan-blue
  else
    return 10 -- main sky blue
  end
end


function flame(x, y, t, xofs,yofs)
    local sin = math.sin
    local cos = math.cos
    local floor = math.floor

    local TAU = 6.283185307179586
    local s = TAU / 32

    -- Convert the 32x32 pixel position into circular coordinates.
    -- Because all spatial terms use integer multiples of s,
    -- the pattern wraps smoothly at x=0/31 and y=0/31.
    local ax = x * s
    local ay = y * s

    -- Animated vertical flame roll.
    -- This makes the fire appear to rise while remaining vertically tileable.
    local rise = ay - t * 0.095

    -- Horizontal waviness for flame tongues.
    local wobble =
        1.20 * sin(ax * 2.0 + t * 0.047) +
        0.70 * sin(ax * 5.0 - t * 0.031)

    -- Main rolling flame body.
    local lick = 0.5 + 0.5 * cos(rise + wobble * 0.55)
    lick = lick * lick

    -- Periodic turbulence, also fully tileable.
    local n = 0.5
    n = n + 0.20 * sin(ax * 3.0 + ay * 2.0 - t * 0.073)
    n = n + 0.15 * sin(ax * -2.0 + ay * 5.0 + t * 0.041)
    n = n + 0.10 * sin(ax * 5.0 + sin(ay * 3.0 - t * 0.050) + t * 0.110)

    -- Tall flame tongue shapes.
    local tongues = 0.5 + 0.5 * sin(ax * 3.0 + 2.1 * sin(ay - t * 0.060))
    tongues = tongues * tongues

    -- Combine the layers into a heat value.
    local heat = 0.58 * lick + 0.27 * n + 0.15 * tongues

    -- Clamp.
    if heat < 0 then
        heat = 0
    elseif heat > 1 then
        heat = 1
    end

    -- 0-based color indices for the provided palette.
    -- Uses dark purple/red/orange/yellow/white flame colors.
    local ramp = {
        0,  -- #1a1c2c
        1,  -- #5d275d
        1,  -- #5d275d
        2,  -- #b13e53
        2,  -- #b13e53
        3,  -- #ef7d57
        3,  -- #ef7d57
        4,  -- #ffcd75
        4,  -- #ffcd75
        12  -- #f4f4f4
    }

    local i = floor(heat * (#ramp - 1)) + 1
    return ramp[i]
end

---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
---------------------------------------------------



function drawtex(idx,w,h,xpos,ypos,repx,repy)
  for y=0,repy-1 do
    for x=0,repx-1 do
      bigspr(idx,w,h, xpos + 8*w*x, ypos + 8*h*y,-1,1)
    end
  end 
end

SPRX = 4
SPRY = 4

funcs = {
  animated_circles_32x32,
  nebula32,
  wavy_rainbow_bar,
  cloud_sky_color,
  --cloud_sky,
  mountain_range_color,
  --cloud_color,
  --flame,
}

REPX = 3
REPY = 2

function TIC()
  T = T + 1
  cls(0)
  gxofs = floor(W*sin(0.02*T))
  --local gx = -W + T % (2*W)
  for f=1,#funcs do
     createTexture(f,SPRX,SPRY,funcs[f],gxofs,0)
  end
  for reps=0,1 do
    for f=1,#funcs do
       local xpos = -W + (gxofs + (f-1)*REPX*8*SPRX) % (2*W)
       local ypos = 2*8*SPRX*reps--floor((f-1)/2)
       drawtex(1+(f-1+2*reps)%#funcs,SPRX,SPRY, xpos, ypos, REPX,2)
       --drawtex(f,SPRX,SPRY, -gx+xpos*4*8*SPRX, ypos*H, 4,4)
    end
  end
  --bigspr(0,SPRX,SPRY,0,0,0,1)
end

