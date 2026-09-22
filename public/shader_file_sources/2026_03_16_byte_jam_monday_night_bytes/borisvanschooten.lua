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

function recline(x,y,sz,ang1,ang2,ang3,it) 
  local ph1 = 0.5*sin(0.018*T + 0.6*it)
  local ph2 = 0.5*sin(0.023*T + 0.6*it)
  local ph3 = 0.5*sin(0.032*T + 0.6*it)
  if it == 0 then
    circ(x,y,1, 1 + floor(0.02*x+0.03*y + 0.06*T)%11)
    return
  end
  ang1 = ang1 + ph1
  ang2 = ang2 + ph2
  ang3 = ang3 + ph3
  local sz2 = 0.7 + 0.25*sin(0.01*T)
  sz2 = sz2 * sz
  local sz3 = 0.8 + 0.15*sin(0.021*T)
  sz3 = sz3 * sz
  local sz4 = 0.7 + 0.25*sin(0.032*T)
  sz4 = sz4 * sz
  local x2 = x + sz2*sin(ang1)
  local y2 = y + sz2*cos(ang1)
  local x3 = x + sz3*sin(ang2)
  local y3 = y + sz3*cos(ang2)
  local x4 = x + sz4*sin(ang3)
  local y4 = y + sz4*cos(ang3)
  local col = it+12
  if col < 16 then
    line(x,y,x2,y2,col)
    line(x,y,x3,y3,col)
    line(x,y,x4,y4,col)
  end
  local dang = 0.2*pi + 0.2*sin(0.021*T)
  recline(x2,y2,sz2,ang1+dang,ang1,ang1-dang,it-1)
  recline(x3,y3,sz3,ang2+dang,ang2,ang2-dang,it-1)
  recline(x4,y4,sz4,ang3+dang,ang3,ang3-dang,it-1)
end

-- program init

T=0
cls(0)
function TIC()
  for x=0,W do
    for y=0,H do
      col = pix(x,y)
      if rand(100) > 96 then
        col = 0
      end
      if rand(100) > 98 and col > 0 then
        --col = col - 1
      end
      if col > 12 then
        col = 0
      end
      pix(x,y,col)
    end
  end
  --cls(0)
  T = T + 1
  ang = pi*sin(0.003*T)
  recline(W/2, H/2, 25, ang+0,ang+pi*0.666,ang+pi*1.333, 6)
end


