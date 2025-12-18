
-- I got the idea for this after
-- seeing two things in succession:
-- (1) jtruk's "wooly willy" demo
-- (2) a steve mould video involving
--     couscous.
--
-- Greetings to: Tobach, Suule, dave84,
-- aldroid & reality404
-- & anyone watching!
silent = true -- set to false to make fft work
              -- but set to true if theres no music


a0 = 5
sx = 240
sy = 136
nparticles = 10000
particles={}
pmax=8
interval_s = 8

sin = math.sin
cos = math.cos
pi = math.pi
tau = 2*pi
max=math.max
min=math.min
phase=0
tprev=0
glitch=false
gymin = 0
gymax = 0
gsize = 64


nsegs = 16
segs = {}
vx = 0.7
vy = 0.7


function clamp(x)
  return max(0,min(1,x))
end

function randint()
  local x=0
  local n=10
  while x==0 do
    x=math.random(n)-n/2
  end
  return x
end


nx = randint()
ny = randint()
nxprev = nx
nyprev = ny

maxhist = {}
nbuckets = 3*60
fftmax = 0
basslevel = 0
myfft = {}
nbass = 8

function do_fft()
  fftmax=0
  for i=0,255 do
    myfft[i] = fft(i)
    if myfft[i]>fftmax then fftmax = myfft[i] end
  end
  table.insert(maxhist,fftmax)
  if (#maxhist)>nbuckets then
    table.remove(maxhist,1)
  end
  for i=1,#maxhist do
    if maxhist[i]>fftmax then
      fftmax = maxhist[i]
    end
  end

  for i=0,255 do
    myfft[i] = myfft[i]/fftmax
  end

  basslevel = 0
  for i=1,nbass do
    basslevel = basslevel + myfft[1]
  end
  basslevel = basslevel/nbass
  if silent then
    basslevel = sin( (time()/1000/0.4)*tau)
  end
end

function hsl2rgb(hsl)
  local h,s,l = table.unpack(hsl)
  function f(n)
    local k = (n+12*h)%12
    local a = s*min(l,1-l)
    return l-a*max(-1,min(k-3,9-k,1))
  end
  return f(0),f(8),f(4)
end

function hslpal(n,h,s,l)
  local r,g,b = hsl2rgb({h,s,l})
  local adr = 0x3fc0 + n*3
  poke(adr,255*clamp(r))
  poke(adr+1,255*clamp(g))
  poke(adr+2,255*clamp(b))
end

function rgbpal(i,r,g,b)
  local adr = 0x3fc0 + 3*i
  poke(adr,255*clamp(r))
  poke(adr+1,255*clamp(g))
  poke(adr+2,255*clamp(b))
end

function vb1pal()
  vbank(1)
  for i=1,pmax do
    local h = (time()/1000/10)%1
    local s = 0.75 + 0.25*(i/pmax)
    local l = 2.5*i/8
    if 1==i then
      s = 1.0
      l = 0.6
    end
    hslpal(i,h,s,l)
  end
  rgbpal(15,0,0,0)
  for i=(pmax+1),14 do
    local x = clamp( (i-pmax-1)/(14-pmax-1) )
    local h = x/5
    local s = 0.9
    local l = 0.5
    hslpal(i,h,s,l)

  end

end

function vb0pal()
  vbank(0)
  for i=0,15 do
    local h = (0.5 + time()/1000/10)%1
    local s = 0.2
    local l = i/15 * 0.5 * (0.25 + 0.75*basslevel)
    hslpal(i,h,s,l)
  end
end

function get_amp(x,y)
  return get_amp_core(nx,ny,x,y)
end

function get_amp_g(x,y)
  if glitch then
    local a = 1
    if (y>=gymin) and (y<=gymax) then
      a=10
    end
    if (y<gymin) then
      return a*get_amp_core(nxprev,nyprev,x,y)
    else
      return a*get_amp_core(nx,ny,x,y)
    end
  else
    return get_amp_core(nx,ny,x,y)
  end
end

function get_amp_core(mm,nn,x,y)
  local xx=x/sx
  local yy=y/sy
  local a = sin(mm*xx*pi)*sin(nn*yy*pi)
          + sin(nn*xx*pi)*sin(mm*yy*pi)
  return a*a
end

function BOOT()
  for i=1,nparticles do
    local p={ math.random()*sx, math.random()*sy }
    table.insert(particles,p)
  end

  for i=1,nsegs do
    local seg = { sx/2,sy/2, 5 }
    table.insert(segs,seg)

  end
end


function draw_particles()

  for i=1,#particles do
    local p = particles[i]
    local n = pmax*clamp( (1+pix(p[1],p[2]))/pmax )
    -- see if bigger particles show up
    -- better on the stream
    pix(p[1],p[2],n)
 --   pix((p[1]+1)%sx,(p[2])%sy,n)
 --   pix((p[1]-1)%sx,(p[2])%sy,n)
 --   pix((p[1])%sx,(p[2]-1)%sy,n)
 --   pix((p[1])%sx,(p[2]+1)%sy,n)
    
  end
end

function move_particles()
  local a1 = a0 * basslevel * 10
  for i=1,#particles do
    local p = particles[i]
    local a = a1 * get_amp(p[1],p[2])
    p[1] = p[1] + a * (math.random()-0.5)
    p[2] = p[2] + a * (math.random()-0.5)
  end
end


function do_phase()
  phase = (time()-tprev)/(1000*interval_s)
  if phase>1 then
    phase = 0
    tprev = time()
    nxprev = nx
    nyprev = ny
    nx = randint()
    ny = nx
    while (math.abs(nx)==math.abs(ny)) do
      ny = randint()
    end
  end

  if phase<0.1 then
    glitch = true
    gphase = phase/0.1
    gymax = gphase*(sy+gsize)
    gymin = gymax - gsize
  else
    glitch = false
  end

end


function BDR(row)
  if glitch then
    if (row>gymin) and (row<gymax) then
      local gp = (row-gymin)/(gymax-gymin)
      local a = 16*sin(gp*tau*2)
      poke(0x3ff9,a)
    else
      poke(0x3ff9,0)
    end
  else
    poke(0x3ff9,0)
  end
end


function draw_pattern()
  vbank(0)
  for y=0,sy do
    for x=0,sx do
      local c = 15*clamp(get_amp(x,y)/4)
      pix(x,y,c)
    end
  end
end

function get_energy(x,y)
  local a = get_amp_g(x,y)
  return math.abs(get_amp(x,y))
end

function draw_cpillar()
  local nc = 14-pmax
  
  for i=1,#segs do
    local xx = clamp((i-1)/#segs)
    local seg = segs[i]
    local x = seg[1]
    local y = seg[2]
    circ(x,y,seg[3],pmax+nc*xx+1)
  end
  
  local head = segs[#segs]
  local hx = head[1]
  local hy = head[2]
  local theta = math.atan2(vy,vx)
  local esep = 0.2*tau
  
  local lx = hx + 2*cos(theta+esep)
  local ly = hy + 2*sin(theta+esep)
  
  local rx = hx + 2*cos(theta-esep)
  local ry = hy + 2*sin(theta-esep)
  
  -- put eyes on the chladnipillar
  circ(lx,ly,2,8)
  circ(rx,ry,2,8)
  
  local rx2 = rx + 2*cos(theta)
  local ry2 = ry + 2*sin(theta)
  local lx2 = lx + 2*cos(theta)
  local ly2 = ly + 2*sin(theta)
  
  circ(lx2,ly2,1.5,0)
  circ(rx2,ry2,1.5,0)
end

function move_cpillar()
  local head = segs[#segs]
  local hx = head[1]
  local hy = head[2]
  
  local E0 = get_energy(hx,hy)
  local dEx = get_energy(hx+1,hy)-E0
  local dEy = get_energy(hx,hy+1)-E0
  
  local m = 0.01
  local vamp = 1.0
  vx = vx-dEx/m
  vy = vy - dEy/m
  
  local vmod = math.sqrt(vx*vx+vy*vy)
  vx = vx/vmod * vamp
  vy = vy/vmod * vamp
  
  hx = (hx+vx)%sx
  hy = (hy+vy)%sy
  
  for i=1,(#segs-1) do
    segs[i][1] = segs[i+1][1]
    segs[i][2] = segs[i+1][2]
  end
  
  segs[#segs][1] = hx
  segs[#segs][2] = hy
end

function TIC()
  do_phase()
  do_fft()
  move_particles()
  move_cpillar()
  vb0pal()
  vb1pal()
  vbank(0)
  draw_pattern()
  vbank(1)
  cls(0)
  draw_particles()
 draw_cpillar()
end
