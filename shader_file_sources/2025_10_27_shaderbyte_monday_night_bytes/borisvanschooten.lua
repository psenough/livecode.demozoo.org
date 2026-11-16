s = math.sin
c = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
pi = math.pi

h = 136
w = 240


cls(2)
t=0

NIBBLES_IN_SPR=8*8
SPR_SHEET_ADDR=0x4000*2
sprIx=0
sprDataHex
= "ff8ff8ff"
.."88f88f88"
.."ff8888ff"
.."88888888"
.."ff8888ff"
.."f8c88c8f"
.."8f8ff8f8"
.."ff8ff8ff"
for i=1,NIBBLES_IN_SPR do
 nibble=tonumber(sprDataHex:sub(i,i),16)
 poke4(SPR_SHEET_ADDR+(NIBBLES_IN_SPR*sprIx)+i-1,nibble)
end

sprIx=1
sprDataHex
= "fff66fff"
.."f336633f"
.."33333333"
.."34433443"
.."33333333"
.."34344343"
.."f344443f"
.."ff3333ff"
for i=1,NIBBLES_IN_SPR do
 nibble=tonumber(sprDataHex:sub(i,i),16)
 poke4(SPR_SHEET_ADDR+(NIBBLES_IN_SPR*sprIx)+i-1,nibble)
end



len = 20
seg = h / len
lgt = {}

nrspd = 10
spdx0 = {}
spdx = {}
spdy = {}

for i=0, nrspd do		
  spdx0[i] = rand(w)
  spdx[i] = spdx0[i]
  spdy[i] = rand(h)
end


nrpum = 10
pumx = {}
pumy = {}

for i=0, nrpum do  
  pumx[i] = rand(w)
  pumy[i] = h/3 + rand(h/2)
end


nextl = 0
phase = 0
function TIC()
  cls(0)
  nextl = nextl - 1
  if (nextl <= 0) then
    nextl = 3 + rand(10)
    phase = 1
    lgt[0] = rand(w)
    for i=1,len do
      lgt[i] = lgt[i-1]+-6 + rand(12)
    end
  end
  if phase > 0 then
    phase = phase + 1
    bgcol = 15
    fgcol = 0
    if phase <= 3 then
      bgcol = 0
      fgcol = 12
    else
      if phase <= 8 then
        bgcol = 0
        fgcol = 13
      else
        if phase <= 10 then
          bgcol = 0
          fgcol = 14
        end
      end
    end
    cls(bgcol)
    for i=0,len-1 do
      line(lgt[i], h*i/len,
           lgt[i+1], h*(i+1)/len, fgcol)
    end
  end
  for i=0, nrpum do
    spr(1,pumx[i],pumy[i],15,2,0,0,1,1)
    circ(pumx[i]+6,pumy[i]+12,-1+rand(2),12)
    circ(pumx[i]+7,pumy[i]+11,-1+rand(2),12)
    circ(pumx[i]+8,pumy[i]+11,-1+rand(2),12)
    circ(pumx[i]+9,pumy[i]+12,-1+rand(2),12)
    pumx[i] = pumx[i] + 0.003*pumy[i]
    if (pumx[i] > w) then
      pumy[i] = h/3 + rand(h/2)
      pumx[i] = -16
    end
  end
  for i=0, nrspd do
    atten = spdy[i] / h
    sxofs = spdx[i] + atten*10*s(0.05*t + 3.3*i)
    line(spdx[i]+4,0, sxofs+4,spdy[i], 15)
    spr(0,sxofs,spdy[i],15,1,0,0,1,1)
    spdy[i] = spdy[i] + 0.5*rand(2)
    if (spdy[i] > h) then
      spdy[i] = -8
      spdx0[i] = rand(w)
      spdx[i] = spdx0[i]
    end
  end
  --for i=0,128 do
  --  print(peek(0x4000+i),84,8*i)
  --  poke2(0x4080+i*4,0x37)
  ---end
  t=t+1
end

