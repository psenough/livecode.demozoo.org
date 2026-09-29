-- BORIS Monday night bytes 9 mar 2026 - Circling texts

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



-- Z buffering

Z = {}

function clearz()
 local x,y
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
SPR_SHEET_ADDR=0x4000*2 -- nibble address
FONT1_ADDR = 0x14604*8  -- bit address
FONT2_ADDR = 0x14A04*8  -- bit address


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
  local i,nibble
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
  local bestI, bestE = 0, 1e18
  local i,p,dr,dg,db,e
  for i=0,12 do
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
  local r,g,b,i1,p1,t,bias,strength,r2,g2,b2,i2
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

T=0

string = 
"Monday Night Bytes"
.." Monday Night Bytes"
.." Monday Night Bytes"
.." Monday Night Bytes"
.." Monday Night Bytes"



-- color font
for c=32,127 do
  for y=0,7 do
    for x=0,7 do
      col = 1+(y + floor(T/10))%6
      poke4(SPR_SHEET_ADDR+x+8*y+64*c,
          col*peek1(FONT1_ADDR+64*c+x+8*y))
    end
  end
end

function TIC()
  cls(0)
  T = T + 1
  for it=-4,4 do
    txpos = W/2 + 200*sin(T*0.006 + it*0.42)
    typos = 30*it + H/2 + 40*sin(T*0.013 + it*0.33)
    txsize = 20 + 10*sin(T*0.025 - it*0.2)
    lsize = txsize/6 --+ 0.5*sin(T*0.08)
    for i=1,#string do
      xpos = txpos+(i-#string/2)*txsize
      ypos = typos
      --spr(string.byte(string,i,i+1),12*i,H/2,0,2)
      ch = string.byte(string,i,i+1)
      for y=0,7 do
        for x=0,4 do
          if peek1(FONT1_ADDR+64*ch+x+8*y) == 1 then
            col = (y + floor(T/5))%8
            if col > 3 then col = 7-col end
            col = col + 1
            --rect(xpos+lsize*x,ypos+lsize*y,lsize,lsize,col)
            vx = xpos+lsize*x - W/2
            vy = ypos+lsize*y - H/2
            ph = i*6+x + 0.5*T + 33*it
            sc = 0.01
            rx = vx*sin(sc*ph) + vy*cos(sc*ph)
            ry = vx*cos(sc*ph) - vy*sin(sc*ph)
            --rx = vx
            --ry = vy
            circ(W/2+rx,H/2-ry,0.5*lsize,col)
            --circ(W/2+rx,H/2-ry,1,col)
          end
        end
      end
    end
  end
end

