-- Boris - animated fonts

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


-- OLD UNUSED
function createSpriteFont(colfunc)
  local c,y,x,sx,sy,dx,dy,segx,segy,col,baseidx
  local coltile = {}
  for x=0,16 do
    for y=0,16 do
      coltile[x+16*y] = colfunc(x,y,T)
    end
  end
  --for c=32,127 do
  for c=64,95 do
    spridx = c - 64
    if c == 64 then
      c=32
    end
    for y=0,15 do
      for x=0,15 do
        sx = floor(x/2)
        sy = floor(y/2)
        dx = x%8
        dy = y%8
        segx = floor(x/8)
        segy = floor(y/8)
        col = coltile[x+16*y]
        baseidx = 16*16*c + 8*8*(segx+2*segy)
        poke4(SPR_SHEET_ADDR + baseidx + dx + 8*dy,
            col*peek1(FONT1_ADDR + 8*8*c + sx + 8*sy))
      end
    end
  end
end

function createSprite16Font()
  local c,y,x,sx,sy,dx,dy,segx,segy,col,baseidx
  for c=32,127 do
    for y=0,15 do
      for x=0,15 do
        sx = floor(x/2)
        sy = floor(y/2)
        dx = x%8
        dy = y%8
        segx = floor(x/8)
        segy = floor(y/8)
        -- duplicate lines
        if sx > 6 then
          sx = sx-1
        end
        if sx > 3 then
          sx = sx-1
        end
        if sx > 2 then
          sx = sx-1
        end
        if sy > 5 then
          sy = sy-1
        end
        if sy > 4 then
          sy = sy-1
        end
        if sy > 1 then
          sy = sy-1
        end
        peekcol = peek1(FONT1_ADDR + 8*8*c + sx + 8*sy)
        col = 12*peekcol
        --if x>13 then
        --  col = 12
        --end
        baseidx = 16*16*c + 8*8*(segx+2*segy)
        poke4(SPR_SHEET_ADDR + baseidx + dx + 8*dy,
            col)
      end
    end
  end
end


function createSprite16(idx,cols)
  local x,y,sx,sy,dx,dy,segx,segy,col,baseidx
  for y=0,15 do
    for x=0,15 do
      sx = floor(x/2)
      sy = floor(y/2)
      dx = x%8
      dy = y%8
      segx = floor(x/8)
      segy = floor(y/8)
      col = cols[x+16*y]
      baseidx = 16*16*idx + 8*8*(segx+2*segy)
      poke4(SPR_SHEET_ADDR + baseidx + dx + 8*dy, col)
    end
  end
end


string = "THE QUICK BROWN FOX JUMPED OVER THE LAZY DOG  "

function spr16(idx,xpos,ypos,bg,scale)
  idx = 4*idx
  spr(idx,xpos,ypos,bg,scale)
  spr(idx+1,xpos+8,ypos,bg,scale)
  spr(idx+2,xpos,ypos+8,bg,scale)
  spr(idx+3,xpos+8,ypos+8,bg,scale)
end

function stampfont16(idx,xpos,ypos,bg,scale)
  idx = 4*idx
  -- draw color tile
  -- draw letter
  spr(idx,xpos,ypos,bg,scale)
  spr(idx+1,xpos+8,ypos,bg,scale)
  spr(idx+2,xpos,ypos+8,bg,scale)
  spr(idx+3,xpos+8,ypos+8,bg,scale)
end



-- color effect functions

function firecol(x, y, t)
  local nx = x / 15
  local fromBottom = (15 - y) / 15

  local flicker =
    0.18 * math.sin(t * 0.18 + x * 0.9) +
    0.12 * math.sin(t * 0.31 + x * 1.7 + y * 0.6) +
    0.08 * math.sin(t * 0.27 - x * 0.5)

  local heat = fromBottom + flicker - nx * 0.05

  if heat > 0.95 then
    return 10
  elseif heat > 0.75 then
    return 9
  elseif heat > 0.55 then
    return 8
  elseif heat > 0.38 then
    return 4
  elseif heat > 0.22 then
    return 2
  elseif heat > 0.10 then
    return 1
  else
    return 0
  end
end

function smokecol(x,y,t)
  local nx = x / 15
  local ny = y / 15

  local v =
    0.55 * math.sin((x * 0.9) + t * 0.08) +
    0.30 * math.sin((y * 1.7) - t * 0.05) +
    0.25 * math.sin((x * 0.6 + y * 1.3) + t * 0.11) +
    0.20 * math.sin(math.sqrt((x - 7.5)^2 + (y - 12)^2) * 1.4 - t * 0.09)

  local drift = 0.35 * math.sin(x * 0.7 + t * 0.06)
  local smoke = v + drift + (1.0 - ny) * 1.2

  if smoke < 0.55 then
    return 0   -- dark background
  elseif smoke < 0.85 then
    return 2   -- deep red
  elseif smoke < 1.10 then
    return 3   -- orange-red
  elseif smoke < 1.35 then
    return 4   -- yellow
  else
    return 4   -- brightest smoke core
  end
end

function smoke2col(x, y, t)
  local xf = x - 7.5
  local yf = y - 7.5

  local v =
    math.sin(yf * 0.55 - t * 0.12) +
    math.sin((xf + yf) * 0.35 - t * 0.08) +
    math.sin(math.sqrt(xf * xf + yf * yf) * 0.9 - t * 0.15) +
    math.sin(xf * 0.4 + t * 0.05) * 0.5

  local rise = (15 - y) * 0.08
  local density = v + rise

  if density < -1.2 then
    return 0   -- darkest background
  elseif density < -0.7 then
    return 15  -- dark grey-blue
  elseif density < -0.2 then
    return 8   -- deep blue
  elseif density < 0.3 then
    return 14  -- medium grey
  elseif density < 0.8 then
    return 9   -- smoke blue
  elseif density < 1.2 then
    return 13  -- light grey-blue
  elseif density < 1.6 then
    return 10  -- bright blue highlight
  else
    return 12  -- brightest smoke highlight
  end
end

function fire2col(x, y, t)
  local nx = (x - 7.5) / 7.5
  local yy = 15 - y

  local flicker =
    math.sin(t * 0.18 + x * 0.9) * 0.8 +
    math.sin(t * 0.11 + x * 0.35 + y * 0.7) * 0.6 +
    math.sin(t * 0.27 - x * 1.4) * 0.35

  local body = yy + flicker * 1.2 - math.abs(nx) * 4.5

  local spark =
    math.sin(x * 1.7 + t * 0.45) +
    math.sin(y * 2.3 - t * 0.30) +
    math.sin((x + y) * 1.1 + t * 0.22)

  body = body + spark * 0.35

  if body > 11.0 then
    return 4
  elseif body > 8.5 then
    return 3
  elseif body > 6.0 then
    return 2
  elseif body > 4.0 then
    return 1
  elseif body > 2.8 then
    return 8
  elseif body > 1.8 then
    return 9
  elseif body > 0.8 then
    return 10
  else
    return 0
  end
end

function wavecol(x,y,t)
  local wave = math.sin(y * 0.8 + t * 0.10) * 2.5
             + math.sin(x * 0.25 + y * 0.45 + t * 0.06) * 1.5

  local v = (x + wave + t * 0.18) % 16

  return math.floor(v)
end



function skycol(x,y,t)
  local ny = y / 15
  local tt = t * 0.08

  -- base vertical gradient: green at bottom, blue toward top
  local c
  if ny > 0.82 then
    c = 6
  elseif ny > 0.68 then
    c = 5
  elseif ny > 0.54 then
    c = 7
  elseif ny > 0.40 then
    c = 10
  elseif ny > 0.24 then
    c = 9
  else
    c = 8
  end

  -- subtle animated shimmer in the sky
  local wave = math.sin(x * 0.55 + tt) + math.sin(y * 0.7 + tt * 0.7)
  if y < 10 and wave > 1.1 then
    c = math.min(c + 1, 11)
  end

  -- drifting clouds in upper area
  if y < 8 then
    local cx = x + tt * 1.8
    local cy = y + math.sin(tt * 0.6) * 0.8

    local cloud =
      math.sin(cx * 0.9) +
      math.sin(cx * 0.45 + cy * 1.7) +
      math.sin(cx * 0.2 - tt * 1.3)

    if cloud > 2.0 then
      c = 12
    elseif cloud > 1.6 then
      c = 13
    elseif cloud > 1.35 and c < 11 then
      c = 11
    end
  end

  -- thin bright horizon band
  if y == 12 or (y == 11 and math.sin(x * 0.8 + tt * 1.4) > 0.6) then
    c = 5
  end

  return c
end

function circlescol(x, y, t)
  local bg = 15

  local circles = {
    {4, 4,  0, 10},
    {11, 5, 12,  3},
    {6, 11, 24, 11},
    {12, 12, 36,  5},
    {8, 8,  48,  9},
    {3, 10, 60,  2}
  }

  local color = bg

  for i = 1, #circles do
    local cx = circles[i][1]
    local cy = circles[i][2]
    local start = circles[i][3]
    local basecol = circles[i][4]

    local age = (t - start) % 72
    if age < 24 then
      local r = age / 6
      local dx = x - cx
      local dy = y - cy
      local d = math.sqrt(dx * dx + dy * dy)

      if d < r then
        local band = r - d
        if band < 0.8 then
          color = basecol + math.floor((0.8 - band) * 4)
          if color > 12 then color = 12 end
        else
          color = basecol
        end
      end
    end
  end

  return color
end


function explocol(x,y,t)
  local bg = 8
  t = t % 40
  local function burst(cx,cy,start,dur)
    local dt = t - start
    if dt < 0 or dt > dur then
      return 0
    end

    local p = dt / dur
    local dx = x - cx
    local dy = y - cy
    local d = math.sqrt(dx*dx + dy*dy)

    local r = p * 5.5
    local thickness = 1.2 - p * 0.5
    local v = math.max(0, 1 - math.abs(d - r) / thickness)

    local core = math.max(0, 1 - d / (r * 0.7 + 0.8)) * (1 - p)
    return math.max(v, core)
  end

  local e = 0
  e = math.max(e, burst(4.5, 5.5,  0, 16))
  e = math.max(e, burst(11.0, 4.0,  6, 15))
  e = math.max(e, burst(7.5, 10.5, 12, 18))
  e = math.max(e, burst(12.0, 11.5, 20, 14))
  e = math.max(e, burst(5.0, 12.0, 24, 16))

  local n = math.sin(x*12.9898 + y*78.233 + t*0.35) * 43758.5453
  n = n - math.floor(n)
  e = e + n * 0.15 * e

  if e > 0.85 then
    return 4
  elseif e > 0.6 then
    return 3
  elseif e > 0.35 then
    return 2
  elseif e > 0.18 then
    return 1
  else
    return bg
  end
end


function flamecol(x,y,t)
  local nx = (x - 7.5) / 7.5
  local yy = 15 - y

  local flicker =
    math.sin(t * 0.18 + x * 0.9) * 0.6 +
    math.sin(t * 0.11 + x * 0.35) * 0.4 +
    math.sin(t * 0.27 - y * 0.8) * 0.25

  local sway = math.sin(t * 0.08 + y * 0.45) * 1.2
  local core = 1.0 - math.abs(nx + sway * 0.08) * 1.8

  local heat =
    core * (yy / 15) * 1.4 +
    flicker * 0.18 -
    (y / 15) * 0.35

  if y > 11 then
    heat = heat + 0.35 + 0.15 * math.sin(t * 0.22 + x * 1.7)
  end

  if heat < 0.08 then
    local smoke = 0.5 + 0.5 * math.sin(x * 0.7 + y * 1.1 + t * 0.05)
    if smoke < 0.33 then
      return 8
    elseif smoke < 0.66 then
      return 9
    else
      return 10
    end
  elseif heat < 0.22 then
    return 2
  elseif heat < 0.38 then
    return 3
  elseif heat < 0.58 then
    return 4
  else
    return 4
  end
end


function flame2col(x,y,t)
  local nx = (x - 7.5) / 7.5
  local ny = y / 15
  local flicker =
    math.sin(t * 0.18 + x * 0.9) * 0.12 +
    math.sin(t * 0.11 + x * 0.35 + y * 0.7) * 0.08 +
    math.sin(t * 0.27 - y * 1.6) * 0.05

  local sway = math.sin(t * 0.09 + y * 0.45) * 1.2
  local dx = x - 7.5 + sway

  local core = 1.0 - math.abs(dx) / (2.0 + (15 - y) * 0.18)
  local body = 1.0 - math.abs(dx) / (4.5 + (15 - y) * 0.35)
  local height = (15 - y) / 15

  local heat =
    math.max(0, core) * 0.9 +
    math.max(0, body) * 0.6 +
    height * 0.8 +
    flicker

  heat = heat - ny * ny * 0.35

  if heat < 0.18 then
    if y < 3 then
      return 10 -- bright blue near top
    elseif y < 7 then
      return 9  -- medium blue
    elseif y < 11 then
      return 8  -- dark blue
    else
      return 15 -- darkest blue background
    end
  elseif heat < 0.38 then
    return 2   -- dark red edge
  elseif heat < 0.58 then
    return 3   -- orange-red
  elseif heat < 0.78 then
    return 4   -- yellow
  else
    return 12  -- white-hot center
  end
end

function rainbowcol(x, y, t)
  local speed = 0.08
  local wave = math.sin((x * 0.9) + (t * speed)) + math.sin((y * 0.4) - (t * speed * 0.7))
  local v = (x + wave * 2 + t * 0.25) % 16
  return math.floor(v)
end

funcs = {
  rainbowcol,
  flamecol,
  explocol,
  flame2col,
  circlescol,
  skycol,
  wavecol,
  firecol,
  fire2col,
  smokecol,
  smoke2col,
}


function createColEffects()
  for f=1,#funcs do
    coltile = {}
    for x=0,16 do
      for y=0,16 do
        coltile[x+16*y] = funcs[f](x,y,T)
      end
    end
    createSprite16(f,coltile)
  end
end

createSprite16Font(funcs[f])


function TIC()
  T = T + 1
  cls(0)
  createColEffects()
  for f=1,#funcs do
    txsize = 18
    tysize = 20
    for i=1,#string do
      xpos = W/2+(i-#string/2)*txsize - 0.15*T*(f+2) + 180*f
      xpos = xpos % (txsize*#string) - txsize
      ypos = -40 + tysize*(f-1)
           + 50*sin(T*0.02)
           + 5*sin( (T+3*i)*0.1)
      ch = string.byte(string,i,i+1)
      if ch > 32 then
        spr16(f,xpos,ypos,0,1)
        spr16(ch,xpos,ypos,12,1)
      end
    end
  end
end

