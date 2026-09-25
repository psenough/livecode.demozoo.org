-- BORIS  Amiga Balls

sin = math.sin
cos = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
floor = math.floor
pi = math.pi

h = 136
w = 240

NIBBLES_IN_SPR=8*8
SPR_SHEET_ADDR=0x4000*2

z = {}

function clearz()
 for y=0,h-1 do
  z[y] = {}
  for x=0,w-1 do
    z[y][x] = 1000
  end
 end
end

sprite1
= "00303000"
.."0c330000"
.."33330003"
.."00033333"
.."00033333"
.."00300030"
.."03030303"
.."03030303"



cls(0)
t=0

function sprite(sprIx,sprDataHex,srccol,dstcol)
  for i=1,NIBBLES_IN_SPR do
    nibble=tonumber(sprDataHex:sub(i,i),16)
    if nibble == srccol then
      nibble = dstcol
    end
    poke4(SPR_SHEET_ADDR+(NIBBLES_IN_SPR*sprIx)+i-1,nibble)
  end
end

local TICPAL = {
  {  0,   0,   0}, --  0
  { 29,  43,  83}, --  1
  {126,  37,  83}, --  2
  {  0, 135,  81}, --  3
  {171,  82,  54}, --  4
  { 95,  87,  79}, --  5
  {194, 195, 199}, --  6
  {255, 241, 232}, --  7
  {255,   0,  77}, --  8
  {255, 163,   0}, --  9
  {255, 236,  39}, -- 10
  {  0, 228,  54}, -- 11
  { 41, 173, 255}, -- 12
  {131, 118, 156}, -- 13
  {255, 119, 168}, -- 14
  {255, 204, 170}, -- 15
}

-- 4x4 Bayer threshold matrix, values 0..15
local BAYER4 = {
  {  0,  8,  2, 10},
  { 12,  4, 14,  6},
  {  3, 11,  1,  9},
  { 15,  7, 13,  5},
}

local function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

-- Find nearest palette color in RGB space (returns index 0..15 and squared error)
local function nearestPalIndex(r, g, b)
  local bestI, bestE = 0, 1e18
  for i=0,15 do
    local p = TICPAL[i+1]
    local dr = r - p[1]
    local dg = g - p[2]
    local db = b - p[3]
    local e = dr*dr + dg*dg + db*db
    if e < bestE then
      bestE = e
      bestI = i
    end
  end
  return bestI, bestE
end

-- Main: (x,y, r,g,b in 0..15) -> palette index 0..15
function ditherPal(x, y, r4, g4, b4)
  -- Convert 0..15 -> 0..255
  local r = clamp(r4,0,15) * 17
  local g = clamp(g4,0,15) * 17
  local b = clamp(b4,0,15) * 17

  -- Base nearest color
  local i1 = nearestPalIndex(r,g,b)
  local p1 = TICPAL[i1+1]

  -- Candidate second color by nudging toward/away from base using threshold
  -- (simple but effective: generate a nearby target and re-quantize)
  local t = BAYER4[(y % 4) + 1][(x % 4) + 1] -- 0..15
  local bias = (t - 7.5) / 7.5              -- approx -1..+1

  -- Strength controls dither contrast; 32 is a reasonable default
  local strength = 32
  local r2 = clamp(r + bias * strength, 0, 255)
  local g2 = clamp(g + bias * strength, 0, 255)
  local b2 = clamp(b + bias * strength, 0, 255)

  local i2 = nearestPalIndex(r2,g2,b2)

  -- Pick between i1 and i2 based on threshold (ordered dither)
  -- If both indices are same, result is stable.
  if t < 8 then
    return i1
  else
    return i2
  end
end



function drawAmigaBall(cx, cy, r, phase, c0, c1, light)
  c0 = c0 or 12
  c1 = c1 or 2
  light = light or 0.35

  if r <= 0 then return end

  -- Checker density controls:
  -- meridians: vertical slices around the sphere
  -- parallels: horizontal bands
  local meridians = math.max(6, math.floor(r * 0.5))
  local parallels = math.max(6, math.floor(r * 0.4))

  -- Helpful constants
  local invR = 1 / r
  local twoPi = math.pi * 2

  -- Simple directional light (fixed in screen space)
  local lx, ly, lz = -0.55, -0.45, 0.70
  local lLen = math.sqrt(lx*lx + ly*ly + lz*lz)
  lx, ly, lz = lx/lLen, ly/lLen, lz/lLen

  -- Pixel fill inside circle
  for dy = -r, r do
    local yy = cy + dy

    -- compute horizontal span for this scanline (circle equation)
    local ny = dy * invR
    local span = math.sqrt(math.max(0, 1 - ny*ny))
    local dxMax = math.floor(span * r)

    for dx = -dxMax, dxMax do
      local xx = cx + dx
      local nx = dx * invR

      -- surface normal on unit sphere: (nx, ny, nz)
      nz2 = 1 - nx*nx - ny*ny
      if nz2 > 0 then
        nz = math.sqrt(nz2)

        -- Convert normal -> spherical coords:
        -- u = longitude around y-axis, v = latitude
        -- Add rotation by phase to longitude for spinning.
        u = math.atan2(nx, nz) + phase
        -- Wrap u into [0, 2pi)
        if u < 0 then u = u + twoPi end
        if u >= twoPi then u = u - twoPi end

        v = math.asin(ny) + math.pi/2  -- [0, pi]

        -- Checker index
        iu = math.floor(u / twoPi * meridians)
        iv = math.floor(v / math.pi * parallels)

        base = ((iu + iv) % 2 == 0) and c0 or c1

        -- Lighting (Lambert) with a small ambient term
        ndotl = nx*lx + ny*ly + nz*lz
        if ndotl < 0 then ndotl = 0 end
        shade = 0.20 + ndotl * light  -- 0.2..(0.2+light)

        -- Dither-like edge darkening to fake curvature depth
        -- (slightly darken near silhouette)
        edge = 1 - nz
        shade = shade * (1 - edge * 0.55)

        --col = (shade < 0.33) and darker or base
        col = base * (0.15+ndotl)
        --if darker then
        --  shade = shade * 0.5
        --end
        
        shade = math.floor(col)
        col = ditherPal(math.floor(xx),math.floor(yy),shade,shade,shade)
        pix(xx, yy, col)
      end
    end
  end

  -- Optional outline for crispness
  circb(cx, cy, r, 0)
end


bl = {}
nrbl = 4

for i=0,nrbl do
  bl[i] = {
    x = (70*i)%w,
    y = h/2,
    vx = 1,
    vy = i
  }
end

function TIC()
  cls(0)
  t = t + 1
  -- floor
  chsz = 26
  idx = 0
  for x=0,w+chsz,chsz do
    for y=0,h+chsz,chsz do
      idx = idx + 1
      rect(x,y,chsz,chsz,1+1*(idx%2))
    end
  end
  -- balls
  for i=0,nrbl do
    radius = 3*(4+i)
    b = bl[i]
    b.x = b.x + b.vx
    b.y = b.y + b.vy
    b.vy = b.vy + 0.1
    if b.y > h-radius then
      b.vy = -b.vy
    end
    if b.x > w-radius then
      b.vx = -1
    end
    if b.x < radius then
      b.vx = 1
    end
    if b.y < 15+radius then
      b.vy = b.vy * 0.95
    end
    drawAmigaBall(b.x,b.y,radius,0.03*t,0,15,0.65)
  end
end

