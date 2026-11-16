-- BORIS monday night bytes 26 jan 2026

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

snake = {}
nrsna = 1210

pcmn = nrsna

t=0

function TIC()
  cls()
  px = -1
  py = -1
  for i=0,pcmn do
    ii = 0.008*i
    x = -0.4*w*sin(0.88*t+ii)
      + 0.07*w*sin(0.13*t + 4.5*ii)
      --- 0.04*w*sin(0.20*t + 0.5*ii)
    y = -0.4*h*cos(1.12*t +0.9*ii) 
      + 0.07*h*cos(0.12*t + 4.5*ii)
      --- 0.04*h*cos(0.20*t + 0.5*ii)
    if px ~= -1 then
      ang = pi*0.5+atan(x-px,y-py)
      thick = sqrt(0.95+sin(4.0+0.1*i))
      thick = 5*sqrt(thick)
      if thick ~= thick then
        thick = 0
      end
      x0 = x + thick*sin(ang)
      y0 = y + thick*cos(ang)
      x1 = x - thick*sin(ang)
      y1 = y - thick*cos(ang)
      x2 = x + 0.6*thick*sin(ang)
      y2 = y + 0.6*thick*cos(ang)
      x3 = x - 0.6*thick*sin(ang)
      y3 = y - 0.6*thick*cos(ang)
      for dx = -0.5,0.5 do
        for dy = -0.5,0.5 do
          line(dx+0.5*w+x0,dy+0.5*h+y0,dx+0.5*w+x2,dy+0.5*h+y2,2)
          line(dx+0.5*w+x2,dy+0.5*h+y2,dx+0.5*w+x3,dy+0.5*h+y3,3)
          line(dx+0.5*w+x3,dy+0.5*h+y3,dx+0.5*w+x1,dy+0.5*h+y1,2)
        end
      end
      if i == pcmn then
        circ (0.5*w+x,0.5*h+y,10,4)
        xx = x + 5*sin(ang)
        yy = y + 5*cos(ang)
        circ (0.5*w+xx,0.5*h+yy,2,0)
        width = 0.3*(1.0+sin(35.0*t))
        for angd = 0.5*pi+ang-width,0.5*pi+ang+width,0.03 do
          xx = x + 10*sin(angd)
          yy = y + 10*cos(angd)
          line(0.5*w+x,0.5*h+y,0.5*w+xx,0.5*h+yy,2)
        end
      end
    end
    px = x
    py = y
  end
  pcmn = pcmn - 1
  if pcmn <= 1 then
    pcmn = nrsna
  end
  t = t + 0.01
end


