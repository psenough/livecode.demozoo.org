-- BORIS

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


function quad(x1, y1, x2, y2, x3, y3, x4, y4, color)
    tri(x1, y1, x2, y2, x3, y3, color)
    tri(x1, y1, x3, y3, x4, y4, color)
end

colschemes = {
-- top left right
{2,1,8},
{4,3,2},
{5,6,7},
{11,10,9},
{5,6,7},
{4,3,2},
}
cubesz=2
cubes2=cubesz*2
cubes3=cubesz*3
NRT = 48

function cube(x,y,height,colscheme)
  local h = cubesz*height
  local cols = colschemes[colscheme+1]
  quad(x, y-cubesz,
       x-cubes2,y,
       x,y+cubesz,
       x+cubes2,y, cols[1])
  quad(x-cubes2, y,
       x, y+cubesz,
       x, y+cubesz+h,
       x-cubes2, y+h, cols[2])
  quad(x+cubes2, y,
       x, y+cubesz,
       x, y+cubesz+h,
       x+cubes2, y+h, cols[3])

end

tileWidth = cubesz*4
tileHeight = cubesz*4
function gridToIsoOld(x, y)
  local isoX = (x - y) * (tileWidth / 2)
  local isoY = (x + y) * (tileHeight / 2)
  return isoX, isoY
end
function gridToIso(x, y,angle)
  local isoX = (x - y) * 1.4*cos(angle)*(tileWidth / 2)
  local isoY = (x + y) * 1.4*sin(angle)*(tileHeight / 2)
  return isoX, isoY
end

FONT1_ADDR = 0x14604*8  -- bit address
FONT2_ADDR = 0x14A04*8  -- bit address


str = "Monday Night Bytes Jammin'!  "
function getCharAtOfs(str, offset)
    local index = (offset % #str) + 1
    return string.byte(str:sub(index, index))
end

function coordToCol(x,y,w,h)
  local hx = floor(x/6)
  local lx = x%6
  local hy = floor(y/7)
  local ly = y%7
  local char = getCharAtOfs(str,hx + w*hy )
  if peek1(FONT1_ADDR + 64*char + 8*ly + lx) == 1 then
    return y%6
  end
  return -1
end

T=0
function TIC() 
  T = T + 1
  cls(0)

  for x=0,NRT do
    for y=0,NRT do
      local ix,iy = gridToIso(x,y,pi/4+0.15*sin(0.02*T))
      local h = 10*sin(0.01*T)
              + 5*sin(0.021*T + 0.38*x)
              + 10*sin(0.033*T + 0.23*y)
              + 5*sin(0.012*T + 0.24*y + 0.12*x)
              + 5*sin(0.062*T + 0.041*y + 0.033*x)
      local col = coordToCol(floor(0.5*T)+x,y,NRT,NRT)
      if col >= 0 then
        cube(W/2+ix, -130+iy + h, 2, col)
      end
    end
  end
  --for x=0,100 do
  --  pix(x,vqts(x)*100,3)
  --end

end
