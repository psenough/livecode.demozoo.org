-- Boris  Particle effects test

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

nrprt = 1000
prt = {}
nextprt = 1

for i=0,nrprt do
  prt[i] = {
    alive=false,
    x=0,
    y=0,
    delay=0,
    size=1,
    color=1,
  }
end

function addParticle(x,y,delay,size,color,move)
  for i=1,nrprt do
    if not prt[nextprt].alive then
      prt[nextprt] = {
        alive=true,
        x=x,
        y=y,
        delay=delay,
        size=size,
        color=color,
        move=move,
      }
      return
    end
    nextprt = (nextprt + 1) % nrprt
  end
end

--addParticle(100,100,10,2,5,function(p)
--  p.x = p.x + 1
--  p.y = p.y + 1
--end)
--addParticle(90,90,100,2,6,function(p)
--  p.x = p.x + 1
--  p.y = p.y + 1
--end)

function createExplosion(x, y, count)
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local speed = 0.5 + math.random() * 2.5
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed
        local life = 20 + math.random(10)
        local startSize = 1 + math.random(2)

        addParticle(x, y, 0, startSize, 10, function(p)
            if p.life == nil then
                p.life = life
                p.vx = vx
                p.vy = vy
                p.maxLife = life
            end

            p.x = p.x + p.vx
            p.y = p.y + p.vy

            p.vx = p.vx * 0.92
            p.vy = p.vy * 0.92

            p.life = p.life - 1

            local t = p.life / p.maxLife

            if t > 0.66 then
                p.color = 10
            elseif t > 0.33 then
                p.color = 9
            else
                p.color = 8
            end

            p.size = math.max(1, math.floor(startSize * t))

            if p.life <= 0 then
                p.alive = false
            end
        end)
    end
end


function createSquareGridParticles(cx, cy, count, spacing, delayStep, size, age)
  spacing = spacing or 4
  delayStep = delayStep or 0
  size = size or 2
  age = age or 40
  
  local side = math.ceil(math.sqrt(count))
  local total = 0

  for gy = 0, side - 1 do
    for gx = 0, side - 1 do
      if total < count then
        local ox = (gx - (side - 1) / 2) * spacing
        local oy = (gy - (side - 1) / 2) * spacing

        local startX = cx + ox
        local startY = cy + oy

        local dist = math.max(math.abs(gx - (side - 1) / 2), math.abs(gy - (side - 1) / 2))
        local delay = dist * delayStep

        addParticle(startX, startY, delay, size, (total % 15) + 1, function(p)
          if p.baseX == nil then
            p.baseX = startX
            p.baseY = startY
            p.age = 0
          end

          p.age = p.age + 1
          if p.age > age then
            p.alive = false
          end
          local expand = 1 + p.age * 0.03

          p.x = cx + ox * expand
          p.y = cy + oy * expand

          p.color = ((p.age // 4) % 15) + 1
        end)

        total = total + 1
      end
    end
  end
end

function createSpiralParticles(cx, cy, count)
    local total = count or 40

    for i = 1, total do
        local angleOffset = (i / total) * math.pi * 2
        local delay = i * 2
        local startSize = 3 - (i / total) * 1.5
        local colorCycle = {8, 9, 10, 11} -- red to yellow tones

        addParticle(cx, cy, delay, startSize, colorCycle[(i - 1) % #colorCycle + 1],
            (function(offset, index)
                local life = 0
                local maxLife = 50 + index

                return function(p)
                    life = life + 1

                    local radius = life * 0.5
                    local angle = offset + life * 0.18

                    p.x = cx + math.cos(angle) * radius
                    p.y = cy + math.sin(angle) * radius

                    if life % 4 == 0 then
                        local c = ((math.floor(life / 4) + index) % #colorCycle) + 1
                        p.color = colorCycle[c]
                    end

                    p.size = math.max(0.5, startSize - life * 0.03)

                    if life >= maxLife then
                        p.alive = false
                    end
                end
            end)(angleOffset, i)
        )
    end
end


-- Creates a red-yellow glowing spiral particle effect.
--
-- Parameters:
--   centerx, centery   : center position of the effect
--   nr_particles       : number of particles to spawn
--   radius_step        : how fast the spiral expands per particle
--   angle_step         : angular distance between spawned particles
--   start_delay_step   : additional delay between each spawned particle
--   life_min           : minimum lifetime in frames
--   life_max           : maximum lifetime in frames
--   size_min           : minimum particle size
--   size_max           : maximum particle size
--   swirl_speed        : angular speed of the particle motion
--   drift_speed        : outward drift speed
--
-- Example:
-- YourFunction(120, 68, 60, 0.7, 0.35, 1, 20, 40, 1, 3, 0.18, 0.25)

function createSpiral2(centerx, centery, nr_particles,
                      radius_step, angle_step, start_delay_step,
                      life_min, life_max, size_min, size_max,
                      swirl_speed, drift_speed)

    radius_step      = radius_step or 0.7
    angle_step       = angle_step or 0.35
    start_delay_step = start_delay_step or 1
    life_min         = life_min or 20
    life_max         = life_max or 40
    size_min         = size_min or 1
    size_max         = size_max or 3
    swirl_speed      = swirl_speed or 0.18
    drift_speed      = drift_speed or 0.25

    for i = 1, nr_particles do
        local base_angle = (i - 1) * angle_step
        local base_radius = (i - 1) * radius_step
        local delay = (i - 1) * start_delay_step
        local size = size_min + math.random() * (size_max - size_min)
        local life = math.random(life_min, life_max)

        -- Red-yellow glow palette range:
        -- 2 = red, 3 = orange, 4 = yellow
        local glow_colors = {2, 3, 4}
        local start_color = glow_colors[math.random(1, #glow_colors)]

        local start_x = centerx + math.cos(base_angle) * base_radius
        local start_y = centery + math.sin(base_angle) * base_radius

        addParticle(start_x, start_y, delay, size, start_color,
            (function()
                local age = 0
                local angle = base_angle
                local radius = base_radius
                local flicker_timer = 0

                return function(p)
                    age = age + 1
                    flicker_timer = flicker_timer + 1

                    angle = angle + swirl_speed
                    radius = radius + drift_speed

                    p.x = centerx + math.cos(angle) * radius
                    p.y = centery + math.sin(angle) * radius

                    -- Slight shrinking over lifetime
                    local t = age / life
                    p.size = math.max(0.5, size * (1.0 - t))

                    -- Flickering red-orange-yellow glow
                    if flicker_timer % 2 == 0 then
                        p.color = glow_colors[math.random(1, #glow_colors)]
                    end

                    -- Kill particle when life ends
                    if age >= life then
                        p.alive = false
                    end
                end
            end)()
        )
    end
end

function createSpirals3(centerx, centery, nr_particles, radius_step, angle_step, lifetime, base_size, start_delay)
  radius_step = radius_step or 1.5   -- how fast particles move outward
  angle_step  = angle_step  or 0.01   -- spiral rotation speed
  lifetime    = lifetime    or 40     -- frames before particle dies
  base_size   = base_size   or 2      -- initial particle size
  start_delay = start_delay or 0      -- delay before particle starts

  local spiral_count = 2

  for i = 1, nr_particles do
    local spiral_index = (i - 1) % spiral_count
    local spiral_offset = (math.pi * 2 / spiral_count) * spiral_index
    local initial_angle = (i / nr_particles) * math.pi * 2 + spiral_offset
    local initial_radius = (i - 1) * 0.15
    local delay = start_delay + math.floor((i - 1) / spiral_count)

    addParticle(centerx, centery, delay, base_size, 3, function(p)
      if p.age == nil then
        p.age = 0
        p.angle = initial_angle
        p.radius = initial_radius
      end

      p.age = p.age + 1
      p.angle = p.angle + angle_step
      p.radius = p.radius + radius_step

      p.x = centerx + math.cos(p.angle) * p.radius
      p.y = centery + math.sin(p.angle) * p.radius

      if p.age < lifetime * 0.33 then
        p.color = 2   -- deep red
      elseif p.age < lifetime * 0.66 then
        p.color = 3   -- orange-red
      else
        p.color = 4   -- yellow glow
      end

      local size_fade = 1 - (p.age / lifetime)
      p.size = math.max(1, math.floor(base_size * size_fade + 0.5))

      if p.age >= lifetime then
        p.alive = false
      end
    end)
  end
end


function createExplo2(centerx, centery, nr_particles, radius, baseSize, delayStep, lifetime, colors)
  radius = radius or 18
  baseSize = baseSize or 3
  delayStep = delayStep or 1
  lifetime = lifetime or 40
  colors = colors or {3, 4, 12, 13, 14}

  for i = 1, nr_particles do
    local angle = (math.pi * 2 * i) / nr_particles
    local speed = radius * (0.6 + math.random() * 0.8)
    local phase = math.random() * math.pi * 2
    local wobble = 2 + math.random() * 4
    local particleLife = lifetime + math.random(0, 15)
    local startSize = math.max(1, baseSize + math.random(-1, 1))
    local delay = (i - 1) * delayStep

    addParticle(centerx, centery, delay, startSize, colors[1], function(p)
      if p.age == nil then
        p.age = 0
        p.vx = math.cos(angle) * speed
        p.vy = math.sin(angle) * speed
        p.startSize = p.size
      end

      p.age = p.age + 1

      local t = p.age / particleLife
      if t >= 1 then
        p.alive = false
        return
      end

      local slowdown = 1 - t
      local wave = math.sin(p.age * 0.35 + phase) * wobble * slowdown

      local dirx = math.cos(angle)
      local diry = math.sin(angle)
      local perpx = -diry
      local perpy = dirx

      p.x = p.x + p.vx * 0.08 + perpx * wave * 0.08
      p.y = p.y + p.vy * 0.08 + perpy * wave * 0.08

      p.vx = p.vx * 0.94
      p.vy = p.vy * 0.94

      local colorIndex = math.floor(t * #colors) + 1
      if colorIndex > #colors then colorIndex = #colors end
      p.color = colors[colorIndex]

      p.size = math.max(1, math.floor(p.startSize * (1 - t) + 0.5))
    end)
  end
end


function createSmoke1(centerx, centery, nr_particles, spread, min_size, max_size, min_delay, max_delay)
    -- Defaults
    spread = spread or 6
    min_size = min_size or 2
    max_size = max_size or 4
    min_delay = min_delay or 0
    max_delay = max_delay or 20

    for i = 1, nr_particles do
        local startx = centerx + math.random(-spread, spread)
        local starty = centery + math.random(-spread, spread)
        local delay = math.random(min_delay, max_delay)
        local size = math.random(min_size, max_size)

        -- Grey palette choices: 12, 13, 14, 15
        local grey_colors = {12, 13, 14, 15}
        local color = grey_colors[math.random(1, #grey_colors)]

        local vx = math.random(-10, 10) / 30
        local vy = -(math.random(10, 25) / 20)
        local life = math.random(30, 60)
        local age = 0

        addParticle(startx, starty, delay, size, color, function(p)
            age = age + 1

            p.x = p.x + vx
            p.y = p.y + vy

            -- Smoke spreads slightly as it rises
            vx = vx + (math.random(-2, 2) / 50)

            -- Slow upward movement over time
            vy = vy * 0.98

            -- Gradually shrink particle
            if age % 12 == 0 and p.size > 1 then
                p.size = p.size - 1
            end

            -- Kill particle after its lifetime
            if age >= life then
                p.alive = false
            end
        end)
    end
end

function createFlower1(centerx, centery, nr_particles, amplitudeX, amplitudeY, speed, lifetime, baseSize)
  amplitudeX = amplitudeX or 24
  amplitudeY = amplitudeY or 22
  speed = speed or 0.08
  lifetime = lifetime or 50
  baseSize = baseSize or 3

  for i = 1, nr_particles do
    local phase = (i / nr_particles) * math.pi * 2
    local delay = math.floor((i - 1) * 2)
    local startColor = (i - 1) % 16
    local a = 3
    local b = 2

    addParticle(centerx, centery, delay, baseSize, startColor, function(p)
      if p.age == nil then
        p.age = 0
        p.cx = centerx
        p.cy = centery
        p.phase = phase
        p.life = lifetime
        p.baseSize = baseSize
      end

      p.age = p.age + 1

      local t = p.age * speed
      p.x = p.cx + math.sin(a * t + p.phase) * amplitudeX
      p.y = p.cy + math.sin(b * t) * amplitudeY

      p.color = (startColor + p.age) % 16

      local remaining = 1 - (p.age / p.life)
      if remaining < 0 then remaining = 0 end
      p.size = math.max(1, math.floor(p.baseSize * remaining + 0.5))

      if p.age >= p.life then
        p.alive = false
      end
    end)
  end
end



function createCircles2(centerx, centery, nr_particles, radius_step, rings, start_color, color_span, lifetime)
  radius_step = radius_step or 12       -- distance between rings
  rings = rings or 5                   -- number of expanding circles
  start_color = start_color or 10      -- starting palette color
  color_span = color_span or 4         -- how many colors to cycle through
  lifetime = lifetime or 50            -- frames each particle lives

  if nr_particles == nil or nr_particles < 1 then
    nr_particles = 12
  end
  if rings < 1 then rings = 1 end
  if radius_step < 1 then radius_step = 1 end
  if color_span < 1 then color_span = 1 end
  if lifetime < 1 then lifetime = 1 end

  for ring = 1, rings do
    local ring_radius = ring * radius_step
    local ring_delay = (ring - 1) * 3

    for i = 1, nr_particles do
      local angle = (i / nr_particles) * math.pi * 2
      local px = centerx
      local py = centery
      local color = (start_color + ((i + ring - 2) % color_span)) % 16
      local max_radius = ring_radius
      local max_life = lifetime

      addParticle(px, py, ring_delay, 3, color, function(p)
        if p.age == nil then
          p.age = 0
        end

        p.age = p.age + 1
        local t = p.age / max_life
        local current_radius = max_radius * t

        p.x = centerx + math.cos(angle) * current_radius
        p.y = centery + math.sin(angle) * current_radius

        -- shrink over time
        p.size = math.max(0, 3 * (1 - t))

        -- cycle colors while alive
        p.color = (color + math.floor(p.age / 4)) % 16

        if p.age >= max_life or p.size <= 0.1 then
          p.alive = false
        end
      end)
    end
  end
end



T = 0

funcs = {
  createSpiral2,
  createExplosion,
  createFlower1,
  createExplo2,
  createCircles2,
  createSquareGridParticles,
  createSpirals3,
  createSmoke1,
}
nextfunc = 1

function TIC()
  T = T + 1
  cls(0)
  -- create new particles
  if T % 10 == 0 then
    nextfunc = (nextfunc + 0.1) % #funcs
    local func = funcs[floor(nextfunc+1)]
    func(W*0.25 + rand(W/2), H*0.25 + rand(H/2),49)
    --createExplosion(rand(W),rand(H),40)
    --createSquareGridParticles(rand(W),rand(H),49,
    --  4,4,2, 50 )
    ---- spacing, delayStep, size, age)
    --createSpiral2(rand(W),rand(H),40)
    --createSpirals3(rand(W),rand(H),40)
    --createExplo2(rand(W),rand(H),40)
    -- spacing, delayStep, size)
    --createSpiralParticles(rand(W),rand(H),40)
    --createParticleGrid3(rand(W),rand(H),40,
    --  2,2,nil,1,30)
    -- spacing, startSize, colors, speed, life)
    --createParticleGrid2(rand(W),rand(H),20,
    --  2,5,1,2,40)
    --spacing, startSize, colorOffset, speed, maxRadius)
    --createParticleGrid(rand(W),rand(H),50,
    --  1,2,1,15,1,20)    
    --  spacing,startSize,colorStart,colorRange,speed,life)
  end
  -- move particles
  for i=0,nrprt do
    local p = prt[i]
    if p.alive then
      if p.delay <= 0 then
        p.move(p)
        circ(p.x,p.y,p.size,p.color)
      else
        p.delay = p.delay - 1
      end
    end
  end
end

