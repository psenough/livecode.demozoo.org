-- BORIS Monday Night Bytes
-- Fish tank demo

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

fishspr
= "00000000"
.."01110001"
.."1c111011"
.."11111111"
.."11111111"
.."11111011"
.."01110001"
.."00000000"



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

sprite(0,fishspr,0,0)

fishtypes=10

for i=0,fishtypes do
  basecol = i
  rndfish = ""
  for y=0,7 do
    for x=0,7 do
      idx = 1+x+8*y
      col = basecol+rand(2)
      if fishspr:byte(idx) == string.byte("1") then
        rndfish = rndfish .. string.format("%x",col)
      elseif fishspr:byte(idx) == string.byte("c") then
        rndfish = rndfish .. "c"
      else
        rndfish = rndfish .. "0"
      end
    end
  end
  sprite(i,rndfish,0,0)
end


nrfsh = 20
fsh = {}
for i=0,nrfsh do
  fsh[i] = {
    x=rand(w),
    y=rand(h),
    sp = rand(fishtypes),
    xs = 0.5*(-3 + 2*(rand(4)-1)),
    ys = -1 + 0.01*rand(200),
  }
end

nextbbl = 0
nrbbl = 100
bbl = {}
for i=0,nrbbl do
  bbl[i] = {
    x = -1,
    y = -1,
    xs = 0,
    ys = -3 + rand(2)
  }
end


H = 136
W = 240



seed=1337
function rnd()
 seed=(seed*1664525+1013904223)%4294967296
 return (seed%16777216)/16777216
end


nrplants = 6
plants={}

function resetplants()
 plants={}
 seed=1337
 n=nrplants
 for i=1,n do
  x=8+(i-1)/(n-1)*(W-16)+(rnd()-0.5)*6
  h=42+rnd()*70
  basePhase=rnd()*6.28318
  sway=0.8+rnd()*1.6
  thick=2
  --if rnd()<0.25 then thick=2 end
  forks=2+math.floor(rnd()*3)
  plants[i]={x=x,y=H-2,h=h,ph=basePhase,sw=sway,th=thick,fk=forks}
 end
end

function seg(x0,y0,x1,y1,c,th)
 if th==1 then
  line(x0,y0,x1,y1,c)
 else
  line(x0-1,y0,x1-1,y1,5)
  line(x0,y0,x1,y1,c)
  line(x0+1,y0,x1+1,y1,7)
 end
end

function branch(x,y,dir,len,t,a,ph,th)
 curl=math.sin(t*1.1+ph*2.1+(y)*0.17)*3.2
 bx2=x+dir*(len*0.55+curl)+math.sin(t*0.7+dir)*1.5
 by2=y-len
 bc=11
 if a<=0.6 then bc=10 end
 seg(x,y,bx2,by2,bc,th)
 -- little tuft at the tip
 seg(bx2,by2,bx2+dir*2,by2-5,5,1)
 seg(bx2,by2,bx2-dir*2,by2-4,6,1)
end

function drawPlant(p,t)
 steps=math.floor(p.h)
 px=p.x
 py=p.y
 for s=1,steps do
  yy=p.y-s
  a=s/steps
  w=math.sin(t*0.9+p.ph+yy*0.08)*(0.6+1.6*a)*p.sw
  w=w+math.sin(t*0.33+p.ph*1.7+yy*0.19)*(0.25+0.8*a)
  xx=p.x+w

  c=10
  --if a>0.35 then c=10 end
  --if a>0.65 then c=11 end
  --if a>0.85 then c=12 end

  seg(px,py,xx,yy,c,p.th)

  if s==math.floor(steps*0.35) or s==math.floor(steps*0.55) or s==math.floor(steps*0.75) then
   for k=1,p.fk do
    dir=1
    if k%2==1 then dir=-1 end
    len=8+(k-1)*3+(p.fk-2)*2
    branch(xx,yy,dir,len,t,a,p.ph,p.th)
   end
  end

  px=xx
  py=yy
 end
end

resetplants()

--function TIC()
-- t=time()/1000
-- cls(15)
-- for i=1,#plants do
--  -drawPlant(plants[i],t)
-- end
--end

function TIC()
  cls(9)
  t = t + 0.05
  for i=1,#plants do
    drawPlant(plants[i],t)
  end
  for i=0,nrfsh do
    f = fsh[i]
    flip = 0
    if f.xs > 0 then flip=1 end
    spr(f.sp,f.x,f.y,0,2,flip)
    f.x = f.x + 0.8*f.xs
    f.y = f.y + f.ys
    if f.x < -16 then f.x = W end
    if f.x > W then f.x = -16 end
    f.ys = f.ys + -0.048 + 0.005*(rand(20)-1)
    f.ys = f.ys * 0.98
    if f.y < 16 then f.ys = f.ys + 0.02 end
    if f.y > H-24 then f.ys = f.ys - 0.02 end
    if (rand(50) == 1) then
      bbl[nextbbl].x = f.x+8
      bbl[nextbbl].y = f.y
      nextbbl = (nextbbl+1)%nrbbl
    end
  end 
  for i=0,nrbbl do
    b = bbl[i]
    if b.x >= 0 then
      b.x = b.x + -1 + 0.1*rand(20)
      b.y = b.y + 0.5*b.ys
      circb(b.x,b.y,1,12)
    end
  end
  if (rand(5) == 1) then
    bbl[nextbbl].x = rand(W)
    bbl[nextbbl].y = H
    nextbbl = (nextbbl+1)%nrbbl
  end 
end

