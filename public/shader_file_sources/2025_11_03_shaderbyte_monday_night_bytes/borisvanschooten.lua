-- BORIS

s = math.sin
c = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
pi = math.pi

h = 136
w = 240


t=0

SPRADR=0x8000



sprx = {}
spry = {}


NS = 20

perx = {}
pery = {}
for l=0,NS do
  perx[l] = -10 + rand(20)
  pery[l] = -10 + rand(20)
end

parx = {}
pary = {}
NP = 200
for p=0,NP do
  parx[p] = -1
  pary[p] = -1
end

function TIC()
  cls(0)
  for p=0,NP do
    if parx[p] > -1 then
       circ(parx[p],pary[p], 1, 2)
       circ(parx[p],pary[p], 0, 4)
       pary[p] = pary[p] - 1
       parx[p] = parx[p] + -1 + rand(2)
    end
  end
  for sx=0,7 do
    for sy=0,7 do
      dx = sx - 4
      dy = sy - 4
      lum = 3 - sqrt(dx*dx + dy*dy)
      col = 1 + lum+rand(2)
      if (lum < 0) then col = 0 end
      poke4(SPRADR+sx+8*sy,col)
    end
  end
  for i=0,40 do 
    sprx[i] = w/2 + 90*s(0.88*i + 0.15*t)
                  + 20*s(0.33*i + 0.55*t)
    spry[i] = h/2 + 60*c(0.85*i + 0.22*t)
                  + 20*c(0.35*i + 0.65*t)
    if i>0 then
      x1 = sprx[i-1]
      y1 = spry[i-1]
      x2 = sprx[i]
      y2 = spry[i]
      for l=0,NS do
        perx[l] = 0.95*perx[l]+ 0.5*s(0.2*l+0.3*t)
        pery[l] = 0.95*pery[l]+ 0.5*c(0.3*l+0.4*t)
      end
      perx[0] = 0
      pery[0] = 0
      perx[NS] = 0
      pery[NS] = 0
      for l=0,NS-1 do
        m = l+1
        w1 = l / NS
        w2 = (NS-l) / NS
        w3 = m / NS
        w4 = (NS-m) / NS
        line(
          x1*w1+x2*w2 + perx[l],
          y1*w1+y2*w2 + pery[l],
          x1*w3+x2*w4 + perx[l+1],
          y1*w3+y2*w4 + pery[l+1],
          4-l%4)
      end
    end
    spr(0,sprx[i]-4,spry[i]-4, 0,1)
    newpi = rand(NP)
    parx[newpi] = sprx[i]
    pary[newpi] = spry[i]
  end
  t=t+0.1
end

