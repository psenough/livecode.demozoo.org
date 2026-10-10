SCX,SCY=240,136
M,T=math,table
TAU=2.0*3.1415926535

-- Technically a caterpillar only has six legs
-- oh well...

function clamp(x,xmin,xmax)
  if x<xmin then x=xmin end
  if x>xmax then x=xmax end
  return x
end

function remap(a,y0,y1)
  return y0+clamp(a,0.0,1.0)*(y1-y0)
end

function fold(x,x0,x1)
  local dx=x1-x0
  local n=M.floor(x/dx)
  local phi = (x-n*dx)/dx
  return clamp(phi,0.0,1.0)
end


function setpal(n,r,g,b)
  local adr=0x3fc0 + 3*n
  poke(adr,r)
  poke(adr+1,g)
  poke(adr+2,b)
end

function arc(x0,y0,r,t0,t1,c,ax,ay)
  local xprev=x0+r*ax*M.cos(t0)
  local yprev=y0+r*ay*M.sin(t0)
  local n=10
  local dt=(t1-t0)/n
  for i=1,n do
    local t=t0+i*dt
    local x=x0+r*ax*M.cos(t)
    local y=y0+r*ay*M.sin(t)
    line(xprev,yprev,x,y,c)
    xprev=x
    yprev=y
  end
end

function bounce(x)
  return -4.0*x*(x-1)
end

function BOOT()
 -- for i=1,15 do
  --  local phi=i/15.0*255
  --  setpal(i,0,1-phi,phi)
 -- end
 local r=0xef
 local g=0x7d
 local b=0x57
 local fade=0.9
 for i=0,8 do
   setpal(3+i,r,g,b)
   r=fade*r
   g=fade*g
   b=fade*b
 end
end

function SCN(y)
  local phi = y/(SCY-1)
  local pts = {
    { 0x1F, 0x21, 0x4D },
    { 0x50, 0x36, 0x6F },
    { 0xBF, 0x34, 0x75 },
    { 0xEE, 0x6C, 0x45 },
    { 0xFF, 0xCE, 0x61 },
    { 0xFF, 0xE5, 0x8A },
  }
  
  local n=#pts
  local ix=1+M.floor(phi*n)
  local ix1 = 1+ix
  if (ix>n) then ix=n end
  if (ix1>n) then ix1=n end

  local ent = pts[ix]
  local ent1 = pts[ix1]
  local z =phi*n-M.floor(phi*n)
  z=1-z
  z=clamp(z,0.0,1.0)
  --z=0.5
  
  setpal(15,0,0,0)
  setpal(0,z*ent[1]+(1-z)*ent1[1],z*ent[2]+(1-z)*ent1[2],z*ent[3]+(1-z)*ent1[3])
end

function cat(x,y,r,a,ep)
  local ax = remap(a,0.75,1.25)
  local ay = remap(a,1.25,0.75)
  local xr = ax*r
  local yr = ay*r
  
  elli(x,y,xr,yr,3)
  ellib(x,y,xr,yr,1)
  
  local edx=0.4*r
  local edy=0.25*r
  local er=0.3*r
  elli(x-edx,y-edy,er*ax,er*ay,12)
  elli(x+edx,y-edy,er*ax,er*ay,12)
 
  local pr=0.15*r
  local px=x-edx + pr*M.cos(ep)
  local py=y-edy + pr*M.sin(ep)
  
  circ(px,py,pr,15)
  local googly=0.3

  local px=x+edx + pr*M.cos(ep+googly)
  local py=y-edy + pr*M.sin(ep+googly)
  circ(px,py,pr,15)
  
  circ(x,y+0.1*r,0.15*r,1)
  
  local mr=0.3*r
  local my = y+0.2*r
  
  arc(x-mr,my,mr,0.0,0.5*TAU,1,ax,ay)
  arc(x+mr,my,mr,0.0,0.5*TAU,1,ax,ay)
  
  local er=1.3*r
  local eth=0.1*TAU
  local tipx=x+er*ax*M.cos(eth) 
  local tipy=y-er*ay*M.sin(eth)
  esz=0.2
  local bx = x+0.75*er*ax*M.cos(eth-esz)
  local by = y-0.75*er*ay*M.sin(eth-esz)
  local tx = x+0.75*er*ax*M.cos(eth+esz)
  local ty = y-0.75*er*ay*M.sin(eth+esz)
  
  tri(bx,by,tipx,tipy,tx,ty,2)

  local tipx=x-er*ax*M.cos(eth) 
  local tipy=y-er*ay*M.sin(eth)

  local bx = x-0.75*er*ax*M.cos(eth-esz)
  local by = y-0.75*er*ay*M.sin(eth-esz)
  local tx = x-0.75*er*ax*M.cos(eth+esz)
  local ty = y-0.75*er*ay*M.sin(eth+esz)
  
  tri(bx,by,tipx,tipy,tx,ty,2)
  
  
  
end


function seg(x,y,r,a,ep,c)
  local ax = remap(a,0.75,1.25)
  local ay = remap(a,1.25,0.75)
  local xr = ax*r
  local yr = ay*r
  
  
  local lth = 0.1*TAU
  local dth = 0.02*TAU
  local lr = r*1.5

  local tx = x + ax*lr*M.cos(lth-dth)
  local ty = y + ay*lr*M.sin(lth-dth)

  local bx = x + ax*lr*M.cos(lth+dth)
  local by = y + ay*lr*M.sin(lth+dth)


  tri(x,y,tx,ty,bx,by,c)

  line(x,y,tx,ty,1)
  line(tx,ty,bx,by,1)
  line(bx,by,x,y,1)


  local tx = x - ax*lr*M.cos(lth-dth)
  local ty = y + ay*lr*M.sin(lth-dth)

  local bx = x - ax*lr*M.cos(lth+dth)
  local by = y + ay*lr*M.sin(lth+dth)


  tri(x,y,tx,ty,bx,by,c)

  line(x,y,tx,ty,1)
  line(tx,ty,bx,by,1)
  line(bx,by,x,y,1)




  elli(x,y,xr,yr,c)
  ellib(x,y,xr,yr,1)
end

c=1

CATX=0
CATBUF={}
function TIC()
  cls(0)
  local t0=time()/1000.0
  local r=32
  local vx=SCX/(5*60)
  
  local t=t0
  local x=CATX
  local y=SCY/2
  
  
  local nsegs=8
  for i=1,nsegs-1 do
    x=CATX-(nsegs-i)*20
    if (x>0) then
      
       local phi = fold(x,0.0,100.0)
       local dy = 75*bounce(phi)
       local y=SCY-1-dy-r
      c=3+(nsegs-i)
      seg(x,y,r,phi,t*5,c)
  
    end
  end

  x=CATX
  phi = fold(x,0.0,100.0)
  dy = 75*bounce(phi)
  y=SCY-1-dy-r

  cat(CATX,y,r,phi,t*5)
  
  CATX=CATX+vx
  if (CATX>SCX+r) then
    CATX=0
  end
  

end
