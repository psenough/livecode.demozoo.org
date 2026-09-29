-- Boris Monday night bytes 12 jan 2026

sin = math.sin
cos = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
floor = math.floor
pi = math.pi

h = 136
w = 240

NIBBLES_IN_SPR=8*8
SPR_SHEET_ADDR=0x4000*2

z = {}

function clearz()
 for y=0,h-1 do
  z[y] = {}
  for x=0,w-1 do
    z[y][x] = 1000
  end
 end
end

sprite1
= "00303000"
.."0c330000"
.."33330003"
.."00033333"
.."00033333"
.."00300030"
.."03030303"
.."03030303"



cls(0)
t=0

function sprite(sprIx,sprDataHex,srccol,dstcol)
  for i=1,NIBBLES_IN_SPR do
    nibble=tonumber(sprDataHex:sub(i,i),16)
    if nibble == srccol then
      nibble = dstcol
    end
    poke4(SPR_SHEET_ADDR+(NIBBLES_IN_SPR*sprIx)+i-1,nibble)
  end
end

bal = {}
nrbal = 100
for i=0,nrbal do
  bal[i] = {
    x = -1,
    y = -1,
    z = -1,
    c = 4,
  }
end

function drawz(z,px,py,pz,c)
  x3 = floor(w/2 + px / (0.02*pz))
  y3 = floor(h/2 + py / (0.02*pz))
  --if x3 == nil then return end
  if x3 < 0 then return end
  if y3 < 0 then return end
  if x3 >= w then return end
  if y3 >= h then return end
  if z[y3][x3] > pz then
    pix(x3,y3,c)
    z[y3][x3] = pz
  end
end

t=0
xi = 0.25
yi = 0.22
function TIC()
  clearz()
  --cls(0)

  for y=0,h do
    for x=0,w do
      col = pix(x,y)
      if col > 0 then
        if rand(0,3) < 1 then
          pix(x,y,0)
        end
      end
    end
  end


  xi = 0.3 + 0.05*sin(0.01*t)
  yi = 0.3 + 0.05*sin(0.008*t)
  for i=0,nrbal do
    j = i + 10
    b = bal[i]
    b.x = 10*sin(0.013*t + xi*j)
    b.y = 5*sin(0.018*t - yi*j)
    b.z = 30+25*sin(0.01*t + 0.10*i)
    b.c = 1 + 7*(floor(i*0.125)%2)
    --if b.x >= 0 then
    --x = w/2 + b.x / (0.2*b.z)
    --y = h/2 + b.y / (0.2*b.z)
    --pix(x,y,b.c)
    for dx = -1,1,0.1 do
      for dy = -1,1,0.1 do
        dist = sqrt(dx*dx+dy*dy)
        if dist < 1.0 then
          drawz(z, b.x+dx, b.y+dy, b.z,
             b.c + 4- 4*dist)
        end
      end
    end
    --end
  end
  t = t + 1  
end

