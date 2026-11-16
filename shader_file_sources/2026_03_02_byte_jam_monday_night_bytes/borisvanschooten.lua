-- Boris - monday night bytes -  psychedelia


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


px = {}
nrpx = 4000
nxpx = 1
for i=0,nrpx do
  px[i] = {
    x = -1,
    y = -1,
    c = 0,
    cd = 1,
    c0 = 0
  }
end


sh1 = {
 1,1,1,
 1,2,1,
 2,1,1,
 
 2,2,2,
 3,3,3,
 
 3,4,4,
 4,3,4,
 4,4,4,
 5,4,4,
 4,5,4,
 
 5,5,3,
 6,6,2,

 7,7,1,
 6,7,1,
 7,6,1,
 
 7,1,1,
 6,1,1,
 7,2,1,

 6,2,2,
 5,3,3,
 --4,4,4,
 3,5,3,
 2,6,2,

 1,7,1,
 2,7,1,
 1,6,1,
}

sh2 = {
 1,4,8,
 2,4,9,
 3,4,10,
 4,4,10,
 5,4,11,
 6,4,12,
 7,4,11,
 8,4,10,
 9,4,10,
 10,4,9,
 11,4,8,
}

sh3 = {
  0,3,7,
  6,3,7,
  3,0,7,
  3,6,7,

  3,1,6,
  3,5,6,  
  --1,1,7,
  --1,2,7,
  1,3,6,
  --1,4,7,
  --1,5,7,
  --5,1,7,
  --5,2,7,
  5,3,6,
  --5,4,7,
  --5,5,7,

  2,2,6,
  2,3,5,
  2,4,6,
  
  4,2,6,
  4,3,5,
  4,4,6,
  
  3,2,5,
  3,3,4,
  3,4,5,
}


function drawShape(sh,dcol,col0,x,y,xofs,yofs)
  local i,j
  for i=1,#sh,3 do
    px[nxpx] = {
      x = sh[i  ] + x + xofs,
      y = sh[i+1] + y + yofs,
      c = sh[i+2],
      cd = dcol,
      c0 = col0,
    }
    nxpx = (nxpx + 1) % #px
  end
end

sz = 3
T = 0
timer = 100
phaselen = 20+rand(80)
function TIC()
  cls(0)
  T = T + 1
  timer = timer - 1
  if timer < 0 then
    timer = 300
    phaselen = 20+rand(80)  
  end
  phase = floor((T/phaselen) % 3)
  --phase=2
  if phase==0 then
    x =  28*sin(0.05*T) + 10*sin(0.1*T)
    y =  14*sin(0.028*T) + 8*sin(0.12*T)
    drawShape(sh1,-1,1,W/2/sz + floor(x+0.5),H/2/sz + floor(y+0.5),-4,-4)
    drawShape(sh1,-1,1,W/2/sz - floor(x+0.5),H/2/sz - floor(y+0.5),-4,-4)
  end
  if phase==1 then
    x =  20*sin(0.018*T)  + 10*sin(0.022*T)
    y =  12*sin(0.0348*T) + 8*sin(0.078*T)
    drawShape(sh2,-1,8,W/2/sz + floor(x+0.5),H/2/sz + floor(y+0.5),-5,-3)
    drawShape(sh2,-1,8,W/2/sz - floor(x+0.5),H/2/sz + floor(y+0.5),-5,-3)
    drawShape(sh2,-1,8,W/2/sz + floor(x+0.5),H/2/sz - floor(y+0.5),-5,-3)
    drawShape(sh2,-1,8,W/2/sz - floor(x+0.5),H/2/sz - floor(y+0.5),-5,-3)
  end
  if phase==2 then
    x =  12*sin(0.078*T) + 8*sin(0.022*T)
    y =  12*sin(0.0448*T) + 8*sin(0.018*T)
    drawShape(sh3,1,8,W/2/sz + floor(x+0.5),H/2/sz + floor(y+0.5),-3,-3)
    drawShape(sh3,1,8,W/2/sz + floor(y+0.5),H/2/sz - floor(x+0.5),-3,-3)
    drawShape(sh3,1,8,W/2/sz - floor(x+0.5),H/2/sz - floor(y+0.5),-3,-3)
    drawShape(sh3,1,8,W/2/sz - floor(y+0.5),H/2/sz + floor(x+0.5),-3,-3)
  end
  for i=0,#px do
    p = px[i]
    if p.x > -1 then
      --rect(sz*p.x,sz*p.y,sz,sz,p.c)
      for dx=0,sz-1 do
        for dy=0,sz-1 do
          xx = sz*p.x+dx
          yy = sz*p.y+dy
          pix(xx,yy,p.c + 0.5*((xx+yy)%2))
        end
      end
    end
    p.c = p.c + p.cd*0.05
    if p.cd < 0 then
      if p.c < p.c0 then
        p.x = -1
        p.y = -1
      end
    end
    if p.cd > 0 then
      if p.c > p.c0 then
        p.x = -1
        p.y = -1
      end
    end
  end
end


