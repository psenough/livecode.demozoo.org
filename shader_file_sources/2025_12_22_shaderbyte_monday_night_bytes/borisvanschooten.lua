-- BORIS monday night bytes

sin = math.sin
cos = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
pi = math.pi

h = 136
w = 240

NIBBLES_IN_SPR=8*8
SPR_SHEET_ADDR=0x4000*2



deer1
= "00303000"
.."0c330000"
.."33330003"
.."00033333"
.."00033333"
.."00300030"
.."03030303"
.."03030303"

deer2
= "00000000"
.."00303000"
.."0c330000"
.."33300003"
.."00033333"
.."00033333"
.."00300030"
.."00300030"

box1
= "00666600"
.."00066000"
.."22266222"
.."22266222"
.."66666666"
.."66666666"
.."22266222"
.."22266222"

ball1
= "00944900"
.."09aaa990"
.."9aaaaa98"
.."9aaaaa98"
.."9aaaaa98"
.."9aaaa998"
.."09999980"
.."00888800"

hat1
= "00cc0000"
.."00ccc000"
.."00222200"
.."00022200"
.."00222220"
.."02222220"
.."22222222"
.."cccccccc"



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


sprite(0,deer1,0x0,0x0)
sprite(1,deer2,0x0,0x0)
sprite(2,box1,0x2,0x2)
sprite(3,ball1,0xa,0xa)
sprite(4,hat1,0xa,0xa)


dr={}
NRD=10
for i=0,NRD do
  dr[i] = {
    y=h*0.0 + i / NRD * (h*0.8),
    x = rand(-16,w),
    t = rand(0,10)
  }
end

bx={}
NRB=100
for i=0,NRB do
  bx[i] = {
    x = -1,
    y = -1,
    vx = 0,
    vy = 0
  }
end


NRP = 1000
pr = {}
for i=0,NRP do
  pr[i] = {
    x=-1,
    y=-1,
  }
end




nextbx = 0
nextp = 0

function TIC()
  cls(0)
  for i=0,NRD do
    d = dr[i]
    spd = (10+i)*0.05
    d.x = d.x + spd
    if (d.x > w) then d.x = -16 end
    d.y = d.y + 0.1*sin(0.08*(t+i))
    spr((0.2*t*spd)%2, d.x, d.y, 0, 2,1)
    spr(4, d.x+6, d.y-8 + 2*math.floor((0.2*t*spd)%2), 0, 1,0)
    d.t = d.t - 1
    if d.t < 0 then
      b = bx[nextbx]
      b.x = d.x + 4
      b.y = d.y + 12
      b.vx = 1.4*spd
      b.vy = 0
      nextbx = (nextbx + 1)%NRB
      d.t = rand(30,50)
    end
  end

  for i=0,NRB do
    b = bx[i]
    if b.y ~= -1 then
      spr(2+i%2, b.x, b.y, 0, 1,0)
      b.y = b.y + b.vy
      b.x = b.x + b.vx
      b.vy = b.vy + 0.05
      b.vx = b.vx * 0.98
    end
  end

  for i=0,NRP do
    p = pr[i]
    if p.y ~= -1 then
      size = i%2
      circ(p.x,p.y,size,12)
      p.y = p.y + 1+ 0.3*size
      p.x = p.x + 0.5*rand(-1,1)
    end
  end
  pr[nextp] = {
    x = rand(0,w),
    y = 0
  }
  nextp = (nextp+1)%NRP  
  t = t + 1
end

