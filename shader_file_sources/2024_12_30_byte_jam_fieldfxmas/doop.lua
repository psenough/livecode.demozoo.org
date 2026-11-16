-- greetings to: jtruk, gasman, pumpuli, Suule,
-- superogue, polynomial, & you!
SCX=240
SCY=136
M=math
T=table
Ti=T.insert
Tu=T.unpack
TAU=2*M.pi
VSD=4
debug_stash={}
COMETS={}



function c01(x)
  if x<0 then return 0 end
  if x>1 then return 1 end
  return x
end

function icoeff(x,arr)
  local n=#arr
  local z=1+x*(n-1)
  local i0=M.floor(z)
  if i0>=n then i0=n-1 end
  i1=1+i0
  local y=c01(z-i0)
  return {1-y,i0,y,i1}
end

function vadd(a,b)
  return {a[1]+b[1],a[2]+b[2],a[3]+b[3]}
end
function vsc(s,v)
  return {s*v[1],s*v[2],s*v[3]}
end
function vmix(x,arr)
  local a0,i0,a1,i1=Tu(icoeff(x,arr))
  local v0=vsc(a1,arr[i1])
  return vadd(vsc(a0,arr[i0]),vsc(a1,arr[i1]))
end

function project(v3)
  local x,y,z=Tu(v3)
  local sx=x*VSD/z
  local sy=y*VSD/z
  sx=0.5*SCX+0.5*SCY*sx
  sy=0.5*SCY+0.5*SCY*sy
  return {sx,sy}
end

function roty(t,v3)
  local c=M.cos(t)
  local s=M.sin(t)
  local x,y,z=Tu(v3)
  local xx=x*c-z*s
  local zz=x*s+z*c
  return {xx,y,zz}
end
function rotz(t,v3)
  local x,y,z=Tu(v3)
  local xx,zz,yy=Tu(roty(t,{x,z,y}))
  return {xx,yy,zz}
end

function dither(x,arr)
  local a0,i0,a1,i1=Tu(icoeff(x,arr))
  if M.random() < a0 then
    return arr[i0]
  else
    return arr[i1]
    
  end
end

TEX = {
{0,0,{4,5,6,7,8,9}},
{64,0,{10,11,12,13,14,15}},
}

function mkcomet(begin)
  local s={r=0,th=TAU*M.random()}
  if begin then s.r=140*M.random() end
  return s
end

function mktex()
  for i,cfg in pairs(TEX) do
    local x0,y0,cols=Tu(cfg)
    for x=0,63 do
      for y=0,63 do
        pix(x0+x,y0+y,dither(x/63,cols))
      end
    end
  end
end

CUBE={
{-1,-1,-1},
{-1,-1, 1},
{-1, 1,-1},
{-1, 1, 1},
{1,-1,-1},
{ 1,-1, 1},
{ 1, 1,-1},
{ 1, 1, 1},
}

function sgn(x)
  if x<0 then return -1 end
  if x>0 then return 1 end
  return 0
end

function pow(x,y)
  return sgn(x)*( M.abs(x)^y )
end


function mkgeom()
  local verts={}
  local tris={}
  local cols={}
  
  local nlevels=16
  local nsectors=16
  
  local e1=3.1+3*M.cos(THETIME*TAU/3.7)
  local e2=3.1+3*M.cos(THETIME*TAU/4.1+TAU/3)
  
  
  for i=0,nlevels-1 do
    for j=0,nsectors-1 do
      local ii=i/nlevels
      local jj=j/nsectors
      local n=2*(ii-0.5)*M.pi/2 -- eta
      local w=TAU*jj-M.pi -- omega

      local Cn=M.cos(n)
      local Sn=M.sin(n)
      local Cw=M.cos(w)
      local Sw=M.sin(w)

      local a0=0.5+0.3*M.cos(THETIME*TAU/2.1)

      local x=(a0+pow(Cn,e1))*pow(Cw,e2)
      local y=(a0+pow(Cn,e1))*pow(Sw,e2)
      local z=(a0+pow(Sn,e1))
      
    
      Ti(verts,{x,y,z})
    end
  end
  
  for i=1,nlevels-1 do
    for j=0,nsectors-1 do
      local icc = 1+nsectors*i + j
      local icn = 1+nsectors*i + (j+1)%nsectors
      local ipc = 1+nsectors*(i-1) + j
      local ipn = 1+nsectors*(i-1) + (j+1)%nsectors
      
      Ti(tris,{ipc,icn,icc})
      Ti(tris,{ipc,icn,ipn})
      Ti(cols,(i+j)%2)
      Ti(cols,(i+j)%2)
      
    end
  end
  
  VERTS=verts
  COLS=cols
  TRIS=tris
end


function light(z,y,c)
  local zmin=-2
  local zmax=2
  z=1-c01( (z-zmin)/(zmax-zmin) )
  local x0,y0,cols=Tu(TEX[c+1])
  return {x0+z*63,y0+y}
end

function render()
  local verts=VERTS
  local tris=TRIS
  local tv={}
  local sv={}
  local lz={}
  local th1=THETIME*TAU/7.5
  local th2=THETIME*TAU/5.7
  local pos={0,0,10}
  local cols=COLS
  local sc = 1+(fft(0)+fft(1)+fft(2))/3
  for i,v3 in pairs(verts) do
    local v=rotz(th2,roty(th1,vsc(sc,v3)))
    
    lz[i]=v[3]
    v = vadd(pos,v)
    Ti(tv,v)
    local v2=project(v)
    Ti(sv,v2)
  end
  	if false then
  for i,v2 in pairs(sv) do
    circ(v2[1],v2[2],2,15)
  end
 end
 
 -- this would be way easier as a shader. Oh well!
  for i,poly in pairs(tris) do
    local i0,i1,i2=Tu(poly)
    local s0=sv[i0]
    local s1=sv[i1]
    local s2=sv[i2]
    local u0=light(lz[i0],0,cols[i])
    local u1=light(lz[i1],32,cols[i])
    local u2=light(lz[i2],63,cols[i])
    --was gonna colour this red/white like the amiga ball
    -- but I quite like this
    ttri(
      s0[1],s0[2], s1[1],s1[2], s2[1],s2[2],  
      u0[1],u0[2], u1[1],u1[2], u2[1],u2[2],
      2,-1,
      tv[i0][3],tv[i1][3],tv[i2][3]
      )  
    
  end
  
  
end

function dotime()
  local t=time()/1000
  if THETIME==nil then
    THETIME=t
    TLAST=t
  else
    TLAST=THETIME
    THETIME=t
  end
  DT=THETIME-TLAST
end

function BDR(y)
  local pal={ {255,0,0},{0,255,0},{0,0,255} }
  local r,g,b=Tu(vmix(y/(SCY-1),pal))
  poke(0x3fc0+3,r)
  poke(0x3fc1+3,g)
  poke(0x3fc2+3,b)
end


function drawcomets()
  local dr=30
  local dth=TAU/209
  
  for i,com in pairs(COMETS) do
    local r=com.r
    local th=com.th
    local x0=SCX/2
    local y0=SCY/2
    
    local c=M.cos(th)
    local s=M.sin(th)
    local c2=M.cos(th+dth)
    local s2=M.sin(th+dth)
    
    local x1=x0+r*c
    local y1=y0+r*s
    local x2=x0+(r-dr)*c
    local y2=y0+(r-dr)*s
    local x3=x0+(r-dr)*c2
    local y3=y0+(r-dr)*s2
    local x4=x0+r*c2
    local y4=y0+r*s2
    
    tri(x1,y1,x3,y3,x2,y2,1)
    tri(x1,y1,x3,y3,x4,y4,1)
  end
end

    
function BOOT()
  for i=1,100 do
    Ti(COMETS,mkcomet(true))
  end
end

function udcomets()
  local alive={}
  local tom=0
  local v=100
  
  for i,com in pairs(COMETS) do
    com.r=com.r+v*DT
    if com.r<180 then
      Ti(alive,com)
    else
      tom=tom+1
    end
  end
  
  for i=1,tom do
    Ti(alive,mkcomet(false))
  end
  
  COMETS=alive
end

function TIC()
  dotime()
  udcomets()
  vbank(0)
  mkgeom()
  mktex()
  vbank(1)
  cls(0)
  poke(0x3ff8,3)
  drawcomets()
  render()
end

