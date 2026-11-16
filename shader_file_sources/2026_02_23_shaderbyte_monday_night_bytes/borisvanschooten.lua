-- BORIS mondaynightbytes 23 feb 2026


sin = math.sin
cos = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
floor = math.floor
pi = math.pi

H = 136
W = 240


-- Z buffering

Z = {}

function clearz()
 local x
 local y
 for y=0,H-1 do
  Z[y] = {}
  for x=0,W-1 do
    Z[y][x] = 1000
  end
 end
end

function xyztox(px,py,pz)
  return floor(W/2 + px / (0.02*pz))
end
function xyztoy(px,py,pz)
  return floor(H/2 + py / (0.02*pz))
end

function drawz(px,py,pz,c)
  --local xy = {xyztoxy(px,py,pz)}
  local x3 = xyztox(px,py,pz)
  local y3 = xyztoy(px,py,pz)
  --x3 = floor(W/2 + px / (0.02*pz))
  --y3 = floor(H/2 + py / (0.02*pz))
  --if x3 == nil then return end
  if x3 < 0 then return end
  if y3 < 0 then return end
  if x3 >= W then return end
  if y3 >= H then return end
  if Z[y3][x3] > pz then
    pix(x3,y3,c)
    Z[y3][x3] = pz
  end
end



-- sprites

NIBBLES_IN_SPR=8*8
SPR_SHEET_ADDR=0x4000*2


sprite1
= "00303000"
.."0c330000"
.."33330003"
.."00033333"
.."00033333"
.."00300030"
.."03030303"
.."03030303"


function sprite(sprIx,sprDataHex,srccol,dstcol)
  for i=1,NIBBLES_IN_SPR do
    nibble=tonumber(sprDataHex:sub(i,i),16)
    if nibble == srccol then
      nibble = dstcol
    end
    poke4(SPR_SHEET_ADDR+(NIBBLES_IN_SPR*sprIx)+i-1,nibble)
  end
end


-- dithering


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

-- 4x4 Bayer threshold matrix, values 0..15
BAYER4 = {
  {  0,  8,  2, 10},
  { 12,  4, 14,  6},
  {  3, 11,  1,  9},
  { 15,  7, 13,  5},
}

function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

-- Find nearest palette color in RGB space (returns index 0..15 and squared error)
function nearestPalIndex(r, g, b)
  bestI, bestE = 0, 1e18
  for i=0,11 do
    p = TICPAL[i+1]
    dr = r - p[1]
    dg = g - p[2]
    db = b - p[3]
    e = dr*dr + dg*dg + db*db
    if e < bestE then
      bestE = e
      bestI = i
    end
  end
  return bestI, bestE
end

-- Main: (x,y, r,g,b in 0..15) -> palette index 0..15
function dither(x, y, r4, g4, b4)
  -- Convert 0..15 -> 0..255
  r = clamp(r4,0,15) * 17
  g = clamp(g4,0,15) * 17
  b = clamp(b4,0,15) * 17

  -- Base nearest color
  i1 = nearestPalIndex(r,g,b)
  p1 = TICPAL[i1+1]

  -- Candidate second color by nudging toward/away from base using threshold
  -- (simple but effective: generate a nearby target and re-quantize)
  t = BAYER4[(y % 4) + 1][(x % 4) + 1] -- 0..15
  bias = (t - 7.5) / 7.5              -- approx -1..+1

  -- Strength controls dither contrast; 32 is a reasonable default
  strength = 32
  r2 = clamp(r + bias * strength, 0, 255)
  g2 = clamp(g + bias * strength, 0, 255)
  b2 = clamp(b + bias * strength, 0, 255)

  i2 = nearestPalIndex(r2,g2,b2)

  -- Pick between i1 and i2 based on threshold (ordered dither)
  -- If both indices are same, result is stable.
  if t < 8 then
    return i1
  else
    return i2
  end
end


-- program init

cls(0)
T=0

su = {}
susz=20
i=0
for y=0,susz do
  for x=0,susz do
    su[i] = {
      x = 0.5*x,
      y = 20+10*sin(x),
      z = 1.5*y,
      c = rand(15)
    }
    i = i + 1
  end
end


function TIC()
  T = T + 1
  clearz()
  cls(0)
  --for y=0,H do
  --  for x=0,W do
  --    pix(x,y, (T+x+y)%15)--dither(x,y,0.15*(x+tt)%15,y%15,(0.25*x+0.5*y)%15))
  --  end
  --end
  i = 0
  for y=0,susz do
    for x=0,susz do
      s = su[i]
      s.x = -8+0.8*x-- + sin(x + 0.003*T)
      s.z = 5 + 0.3*sin(0.8*y + 0.4*x + 0.08*T)
              + 0.2*cos(0.6*x + 0.5*y + 0.11*T)
      s.y = -8+0.5*y + 0.5*s.z-- + sin(y + 0.04*T)
      s.c = 1+(x+y)%11
      r = 12+4*sin(0.1*T+0.8*x)
      g = 12+4*sin(0.082*T+0.9*y)
      b = 12+4*sin(0.0067*T+0.3*x+0.5*y)
      zz = s.z - 5
      r = r / (1.5+zz)
      g = g / (1.5+zz)
      b = b / (1.5+zz)
      realx = xyztox(s.x,s.y,s.z)
      realy = xyztoy(s.x,s.y,s.z)
      s.c = dither(T,T,r,g,b)
      for dx=-5,5 do
        for dy=-3,3 do
          virtx = 0.08*dx+s.x
          virty = 0.08*dy+s.y
          drawz(virtx,virty,s.z,s.c)
        end
      end
      i = i + 1
    end
  end
  
end

