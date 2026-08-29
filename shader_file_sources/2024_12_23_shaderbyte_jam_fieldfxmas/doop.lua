-- greetings to: enfys, HeNeArXn,
-- jtruk, muffintrap, pumpuli, aldroid,
-- raccoonviolet, catnip, lsquared, 
-- & everyone watching on stream!

SCX=240
SCY=136
ASP=SCX/SCY
M=math
T=table
TAU=2*M.pi
Ti=T.insert
Tu=T.unpack
VSD=4
FFTL=0
TEX={
{0,0,{15,14,13,12}},
{64,0,{15,1,2,3}},
{0,64,{15,7,6,5}},
{64,64,{15,8,9,10}},
}


function c01(x)
  if x>=1 then return 1 end
  if x<=0 then return 0 end
  return x
end

function icoeff(x,arr)
  x=c01(x)
  local n=#arr
  local z=1+x*(n-1)
  local i0=M.floor(z)
  if i0>=n then i0=n-1 end
  local i1 = i0+1
  local y=c01(z-i0)
  return {1-y,i0,y,i1}
end

function vadd(a,b)
  return {a[1]+b[1],a[2]+b[2],a[3]+b[3]}
end
function vsc(s,v)
  return {s*v[1],s*v[2],s*v[3]}
end

function vsc2(s,v)
  return {s*v[1],s*v[2],v[3]}
end


function vmix(x,arr)
  local a0,i0,a1,i1 = Tu(icoeff(x,arr))
  return vadd(vsc(a0,arr[i0]),vsc(a1,arr[i1]))
end

function project(v3)
  local x,y,z=Tu(v3)
  local sx = x*VSD/z
  local sy = y*VSD/z
  sx = 0.5*SCX + 0.5*SCY*sx
  sy = 0.5*SCY + 0.5*SCY*sy
  return {sx,sy}
end

function mkgeom()
  local verts={}
  local tris={}
  
  local n=7
  local w=TAU/n
  
  Ti(verts,{0,0,1})
  Ti(verts,{0,0,-1})
  
  for i=0,n-1 do
    Ti(verts,{2*M.cos(i*w),2*M.sin(i*w),0})

  end
  for i=0,n-1 do
    Ti(verts,{M.cos((i+0.5)*w),M.sin((i+0.5)*w),0})
  end
  
  for i=1,n do
    local ixt = 2+i
    local ixp = 2+n+((i-2)%n)+1
    local ixn = 2+n+((i-1)%n)+1
    Ti(tris,{1,ixp,ixt})
    Ti(tris,{2,ixp,ixt})
    Ti(tris,{1,ixn,ixt})
    Ti(tris,{2,ixn,ixt})
    
  end
  
  STARV=verts
  START=tris
end

function roty(t,v3)
  local x,y,z=Tu(v3)
  local c=M.cos(t)
  local s=M.sin(t)
  local xx=x*c-z*s
  local zz=x*s+z*c
  return {xx,y,zz}
end
function rotz(t,v3)
  local x,y,z=Tu(v3)
  local xx,zz,yy = Tu(roty(t,{z,x,y}))
  return {xx,yy,zz}
end


function dither(x,cols)
  local a0,i0,a1,i1 = Tu(icoeff(x,cols))
  if M.random()<a0 then return cols[i0] else return cols[i1] end
end

function mktex()
  for i,cfg in pairs(TEX) do
    local x0,y0,cols=Tu(cfg)
    for x=0,63 do
      for y=0,63 do
        pix(x+x0,y+y0,dither(x/63,cols))
      end
    end
  end
  pix(128,128,12)
end

function light(lz,y,c)
  local x0,y0,cols = Tu(TEX[c+1])
  local zmin=-2
  local zmax=2
  local z=(lz-zmin)/(zmax-zmin)
  z=1-c01(z)
  return {x0+z*63,y0+y}
end


function render(obj)
  local th1 = THETIME*TAU/3.5+obj.p1
  local th2 = THETIME*TAU/5.3+obj.p2
  local verts=STARV
  
  local tv={}
  local sv={}
  local lz={}
  local sc = 1+2*FFTL
  for i,v3 in pairs(verts) do
    local v=rotz(th2,roty(th1,vsc2(sc,v3)))
    Ti(lz,v[3])
    v = vadd(obj.pos,v)
    local v2=project(v)
    Ti(tv,v)
    Ti(sv,v2)
  end
 
  
  local c=obj.c
  for i,poly in pairs(START) do
    local i0,i1,i2 = Tu(poly)
    local v0=sv[i0]
    local v1=sv[i1]
    local v2=sv[i2]
    local u0=light(lz[i0],0,c)
    local u1=light(lz[i1],32,c)
    local u2=light(lz[i2],64,c)
    -- tesco value goraud shading :)
    ttri(
      v0[1],v0[2],v1[1],v1[2],v2[1],v2[2],
      u0[1],u0[2],u1[1],u1[2],u2[1],u2[2],
      2,-1,
      tv[i0][3],tv[i1][3],tv[i2][3]
    )

  end
  
  for i,v3 in pairs(SNOW) do
    local v2=project(v3)
    local x,y=Tu(v2)
    -- this is a flagrant abuse
    -- of the Z-buffer..
    ttri(x,y,x+1,y,x,y+1,
         128,128,128,128,128,128,
         2,-1,
         v3[3],v3[3],v3[3])
    ttri(x+1,y+1,x+1,y,x,y+1,
         128,128,128,128,128,128,
         2,-1,
         v3[3],v3[3],v3[3])

  end
  
end


function mkstar(begin)
  local z=10+20*M.random()
  local D=VSD
  local x=-1.2*ASP*z/D
  if begin then x=x+2*ASP*z/D*M.random() end
  local y=-z/D + 2*z/D*M.random()
  local s = {
    pos={x,y,z},
    c=M.random(4)-1,
    v=5+5*M.random(),
    p1=TAU*M.random(),
    p2=TAU*M.random(),
 }
 return s
end


function mkflake(begin)
  local z=10+15*M.random()
  local D=VSD
  local x=-1.2*ASP*z/D + 2*ASP*z/D*M.random()
  local y=-z/D
  if begin then y= y+ 2*z/D*M.random() end

  local s = {
    x,y,z

 }
 return s
end


function BOOT()
  THETIME=time()/1000
  TLAST=THETIME
  mkgeom()
  STARS={}
  SNOW={}
  for i=1,15 do
    Ti(STARS,mkstar(true))
  end
  
  for i=1,70 do
    Ti(SNOW,mkflake(true))
  end
end

function update()
  local alive={}
  local tomake=0
  local dt=THETIME-TLAST
  
  for i,star in pairs(STARS) do
    local z=star.pos[3]
    local xmax = 1.2*ASP*z/VSD
    star.pos[1]=star.pos[1] + star.v*dt
    if star.pos[1]<xmax then
      Ti(alive,star)
    else
      tomake=tomake+1
    end
  end
  
  for i=1,tomake do
    Ti(alive,mkstar(false))
  end
  STARS=alive
  
  alive={}
  tomake=0
  snowspeed=5
  for i,v3 in pairs(SNOW) do
    local x,y,z=Tu(v3)
    local ymax = 1.2*z/VSD
    v3[2]=v3[2]+snowspeed*dt
    if v3[2]<ymax then
      Ti(alive,v3)
    else
      tomake=tomake+1
    end
  end
  
  for i=1,tomake do
    Ti(alive,mkflake(false))
  end
  SNOW=alive
end

function BDR(y)
  local pal={{16,0,64},{8,8,8},{64,64,64}}
  local r,g,b=Tu(vmix(y/(SCY-1),pal))
  poke(0x3fc0,r)
  poke(0x3fc1,g)
  poke(0x3fc2,b)
end
  
  

function TIC()
  TLAST=THETIME
  THETIME=time()/1000
  FFTL=(fft(0)+fft(1)+fft(2)+fft(3))/4
  update()  
  vbank(0)
  mktex()
  vbank(1)
  poke(0x3ff8,11)
  cls(0)
  
  for i,star in pairs(STARS) do
    render(star)
  end
end
