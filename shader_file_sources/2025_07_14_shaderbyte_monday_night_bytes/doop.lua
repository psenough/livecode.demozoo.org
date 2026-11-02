
-- greetz to: alkama canmom, reality404,
-- muffintrap, littletheremin g33kou, aldroid,
--  totetmatt, and you!
 

-- This effect is based on a simplified version
-- of Jeff Jones' simulation of the growth
-- of the slime mould Physarum polycephalum
-- at https://bleuje.com/physarum-explanation/
--
-- Appropriately for nonbinary awareness week,
-- P. Polycephalum has about 700 different sexes..


SCX,SCY=240,136
M,T=math,table
TAU=2*M.pi
TRESET=0
CYCTIME=20
FADETIME=2
FADELEVEL=1


AGENTS={}
ANGLE=TAU/8
NAGENTS=128
SDIST=12
MDIST=1
PROGRESS=0

XOFF=0
YOFF=0

MSG="byte jam!!"
MSGS = { "greetz to: alkama","canmom, reality404,",
  "muffintrap, littletheremin","g33kou, aldroid","totetmatt, and you!","......" }
  
function zpix(x,y,c)
  x=wrapx(x+XOFF)
  y=wrapy(y+YOFF)
  pix(x,y,c)
end

function wrapx(x)
  while (x<0) do x=x+SCX end
  while (x>=SCX) do x=x-SCX end
  return x
end

function wrapy(y)
  while (y<0) do y=y+SCY end
  while (y>=SCY) do y=y-SCY end
  return y
end
function fwrapx(x)
  return M.floor(wrapx(x))
end
function fwrapy(y)
  return M.floor(wrapy(y))
end

function to8(x)
  x=x*255
  if x<0 then x=0 end
  if x>255 then x=255 end
  return x
end
function hsv2rgb(h,s,v)
  function f(n)
    k=(n+6*h)%6
    return v-v*s*M.max(0,M.min(k,4-k,1))
  end
  return {to8(f(5)),to8(f(3)),to8(f(1))}
end

function pal(n,r,g,b)
  local adr = 0x3fc0 + 3*n
  poke(adr,r)
  poke(adr+1,g)
  poke(adr+2,b)
end


function bass()
  local n=12*5
  local s=0
  for i=0,n-1 do
    s=s+vqt(i)
  end
  s=s/n
  return s
end

function rand11()
  return 2*M.random()-1
end

function reset()
  PROGRESS=0
  local agents={}
  for i=1,NAGENTS do
    T.insert(agents,{
      x=M.random(SCX-1),
      y=M.random(SCY-1),
      th=TAU*M.random(),
    })
  end
  AGENTS=agents
  
  local field={}
  for x=0,SCX-1 do
    local col={}
    for y=0,SCY-1 do
      col[y]=0.0
    end
    field[x] = col
  end
  FIELD=field
  ANGLE = TAU/8 + TAU/16*rand11()
  SDIST=5+M.random(10)
  MDIST=1+M.random(2)
  
  TRESET=time()/1000
end

function iter()
  for i,ag in pairs(AGENTS) do
    local sv = {}
    for am=-1,1 do
      local angle = ag.th + am*ANGLE
      local sx= fwrapx(ag.x + SDIST*M.cos(angle))
      local sy= fwrapy(ag.y + SDIST*M.sin(angle))
      local v = FIELD[sx][sy]
      T.insert(sv,{v,angle})
    end
    
    if sv[1][1]==sv[2][1] and sv[2][1]==sv[3][1] then
      angle=ag.th
    else
      angle=sv[1][2]
      v=sv[1][1]
      for i=2,3 do
        if sv[i][1]>v then
          v=sv[i][1]
          angle=sv[i][2]
        end
      end
    end
    
    local newx = ag.x + MDIST * M.cos(angle)
    local newy = ag.y + MDIST * M.sin(angle)
   
    ag.x = wrapx(newx)
    ag.y = wrapy(newy)
    sx = fwrapx(ag.x)
    sy = fwrapy(ag.y)
    
    FIELD[sx][sy] = FIELD[sx][sy]+1
  end
end

function dopal()
  local t=time()/1000
  
  for i=0,14 do
    local ii=i/14
    local ph=ii*TAU/3
    local h = (0.5+t/9)%1
    local s=0.75+0.25*bass()
    if s>1 then s=1 end
    local v=ii
    if v>1 then v=1 end
    
    local rgb=hsv2rgb(h,s,v)
    local xpand=1.0
    if i>3 then
      xpand = bass()*10
    end
    
    local r=rgb[1]*FADELEVEL*xpand
    local g=rgb[2]*FADELEVEL*xpand
    local b=rgb[3]*FADELEVEL*xpand
    
    pal(i,r,g,b)
  end
  
  local ph=1.1*TAU/3
  local h = (0.5+t/9+TAU/2)%1
  local s=0.75+0.25*bass()
  if s>1 then s=1 end
  local v=1.0
  if v>1 then v=1 end
    
  local rgb=hsv2rgb(h,s,v)
    
    local r=rgb[1]
    local g=rgb[2]
    local b=rgb[3]
    
   pal(15,r,g,b) 
    
end

-- this didn't look great in the end so I took it out..
function drawstr(s)
  local t=time()/1000
  local nmsgs = #MSGS
  local mtime = 3
  local mn = 1+M.floor(t/mtime)%(nmsgs)
  while (mn>nmsgs) do mn=mn-nmsgs end
  local s = MSGS[mn]


  local w = 10
  local slen=#s
  local sw = slen*w
  local pad = SCX-sw

  local x0=pad/2


  
  for i=1,#s do
    local c=string.sub(s,i,i)
    local y = SCY/2 + 16*M.cos(t/2*TAU+i*TAU/12)
    print(c,x0,y,15,false,2)
    x0=x0+w
  end
  
end

function BOOT()
  reset()
end


function BDR(y)
  local t=time()/1000
  
  local ph = t/10*TAU + y/(5*SCY)*TAU*4
  local dx = 20*M.sin(ph)
  
  poke(0x3ff9,M.floor(dx))
end

function TIC()

  vbank(0)
  cls()
  --(MSG)
  dopal()
  vbank(1)
  
  local t=time()/1000
  local timeleft = CYCTIME-(t-TRESET)
  if (timeleft < FADETIME) then
    FADELEVEL = timeleft/FADETIME
  else
    FADELEVEL=1.0
  end
  if timeleft < 0 then
    reset()
  end

  PROGRESS = PROGRESS + bass()*0.25
  XOFF = SCX + SCX*M.cos(PROGRESS/17*TAU)
  YOFF = SCY + SCY*M.sin(PROGRESS/19*TAU)
  dopal()
  iter()
  cls(0)
  
  
  

  
  
  for x=0,SCX-1 do
    for y=0,SCY-1 do
      local v=FIELD[x][y]
      if v>14 then v=14 end
      zpix(x,y,v)
    end
  end
  for i,ag in pairs(AGENTS) do
    zpix(ag.x,ag.y,15)
  end

  
end





