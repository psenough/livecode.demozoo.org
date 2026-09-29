-- author: echo~parallax
-- desc: livecode shader for NFC 2026
-- site: https://parallax.fyi
-- license: demozoo gets to repro this, otherwise ask
-- version: 0.1
-- script: lua

-- devious sprite import code :3
sprite_data={1342178816,1432356352,1432684032,1432704527,1347769861,5592405,1342526720,0,20495,5592325,1347769685,1347749120,1432684032,1432682496,1432682496,84279296,24576,26112,6313487,5657861,1347769685,1431655680,1426391040,1426063360,61680,4026544176,251670579,50344140,808661772,3355404,196620,983055,61680,251670576,251670579,50344140,808661772,1060320012,251658495,0,251719920,251670576,50343987,808661196,1060320012,251671308,12300,61680,251719920,251670576,50343987,808661196,808661772,4278203148,15778560,3840,251719920,251670576,50343987,808661196,808661772,4026741516,986880,0,61680,251670576,251670579,50344140,808661772,808661772,4026789888,983040,61680,12336,251670579,251670732,53490444,808661772,808710144,986880,61680,12336,12339,251670732,254817036,858993612,808710384,4027514880,61680,12336,251670579,251670732,53490444,808661964,808648959,252641280}

S_START = 0x6000 -- normal, don't worry about it
for i=0,(#sprite_data)-1 do
  packed = sprite_data[i+1]
  for j=0,3 do
    poke(S_START+i*4+3-j,(packed >> (8*j))&255)
  end
end

-- Main code
SX=240 -- display size
SY=136
XVEL=1.15*SX -- scroll speed, in pixels/second
BPM=130
S_PER_BEAT = 60 / BPM

frame=0

bt0=0 -- beat trackers
bt1=1

-- ring buffer of particles
particles = {}

-- ring buffer of meows. self-explanatory
meows = {}

function saw(x)
  return 2.0 * math.abs(x - math.floor(x+.5))
end

function csaw(x)
  return saw(x-.5)
end

function hash(n)
  -- thank you PCG
  n = math.floor(n)
  local word = ((n >> ((n >> 28) + 4)) ~ n) * 277803737
  word = (word >> 22) ~ word
  word = word & 4294967295
  return word / 4294967295.0
end

function TIC()
  -- cls(0)
  -- funky delay
  for p=0,SX*SY-1 do
    v = peek4(p)
    if v < 8 then
      v = 0
    elseif math.random() < 0.5 then
	    if v < 12 then
	      v = v - 1
	    else
	      v = v + 1
	    end
    end
    poke4(p, v)
  end
  
  -- for b=0,120 do
  --   v = fft(b)
  --   t = 6.28 * b/120
  --   line(SX/2,SY/2,SX/2+v*SY*math.sin(t),SY/2+v*SY*math.cos(t),12)
  -- end
  
  t = frame/60
  beat = t / S_PER_BEAT
  beat_frac = beat % 1.0
  
  -- spectrogram
  for x=0,SX do
    v = fft(x)
    line(x, 0, x, v*SY, 11)
  end
  
  -- barlines
  for i=0,3 do
    x = SX-((beat_frac + i) * S_PER_BEAT * XVEL)
    line(x, 0-2, x, SY-2, 12+i)
  end
  
  -- attractor
  a_x = -.671
  a_y = 0.813
  
  bt0 = bt0 + 0.7*fft(5)^2
  bt1 = bt1 + 1.0*fft(100)^2
  a_a = 3.0*math.sin(bt0)
  a_b = 3.0*math.sin(1.618*bt0)
  a_c = 3.0*math.sin(0.618*bt1)
  a_d = 3.0*math.sin((0.618^2)*bt1)
  
  for i=0,10000 do
    new_x = math.sin(a_a*a_y) + a_c*math.cos(a_a*a_x)
    a_y   = saw(a_b*a_x) + a_d*math.cos(a_b*a_y)
    a_x   = new_x
    
    scale = .2
    x = math.floor(SX/2 + scale*SY*a_x)
    y = math.floor(SY/2 + scale*SY*a_y) - 15
    if x>=0 and y>=0 and x<SX and y<SY then
      addr = y*SX + x
      old = peek4(addr)
      poke4(addr, old+1)
    end
  end
  
  -- particles
  p_idx = frame%256
  particles[p_idx] = {x=SX, y=math.random(0,SY),
                      vy=math.random()*2.-1,
                      sz=(math.random()^4)*8}
  for i=0,(#particles)-1 do
    p = particles[i]
    scale = (p.sz/8)^.05
    p.x = p.x - scale * XVEL/60
    p.y = p.y + scale * p.vy
    particles[i] = p
    
    col = math.floor(8 + 4*(p.x / SX))
    trib(p.x, p.y, p.x+p.sz, p.y, p.x, p.y+p.sz, col)
  end
  
    -- meows are particles
  p_idx = frame%9
  if beat_frac < 1/(55.0*S_PER_BEAT)  then
    meows[p_idx] = {x=SX-S_PER_BEAT*XVEL-30, y=math.random(.5*SY, math.floor(.9*SY))}
  end
  for i=0,(#meows)-1 do
    m = meows[i]
    if m ~= nil then
    m.x = m.x - .1*XVEL/60
    meows[i] = m
    
    print("meow!", m.x, m.y, 12)
    end
  end
  
  -- fox
  sf = ((math.floor(beat*8)+2)&7)
  y_offset = 0
  if sf >= 1 and sf <= 4 then
    y_offset = 1
  elseif sf >= 5 then
    y_offset = -1
  end
  spr(256+4+sf, SX-16-S_PER_BEAT*XVEL, SY-16-1+y_offset, 0, 2)
  
  -- print("Hi NordicFuzzCon!", 0, SY*.9, 12)

	frame = frame + 1
end

-- glitches
function BDR(row)
  yp = (row + frame)/12
  yi = math.floor(yp)
  yf = yp - yi
  h1 = hash(yi)
  h2 = hash(yi+1)
  n = h1 + (h2-h1) * yf
  if n > 0.5 then
    poke(0x3FF9, 256*h1)
  else
    poke(0x3FF9, 0)
  end
  
  -- bonus gradient
  uvy = row / SY
  poke(0x3FC0, 0x1A*uvy)
  poke(0x3FC1, 0x1C*uvy)
  poke(0x3FC2, 0x2C*uvy)
end

--[[

   '     '
   |\___/|   .|
   | '^' '__.||
   |        |/
.   ||----||   .
 "____________" 
   o        o

hi!

]]--