-- Monday night bytes - Boris - Snowy Caves

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

function addheight(x,y,radius,amount)
  local xx,yy
  for yy = -radius,radius do
    for xx = -radius,radius do
      local dd = sqrt(xx*xx + yy*yy)
      if dd < radius then
        local col = pix(x+xx,y+yy)
        if amount > 0 and col < 4 then
          pix(x+xx,y+yy,col+amount)
        end
        if amount < 0 and col > 0 then
          pix(x+xx,y+yy,col+amount)
        end
      end
    end
  end
end

nrspr = 2000
spr = {}

T = rand(10)
cls(4)
function TIC()
  T = T + 1
  local phase = floor(T/200)%3
  local timer = T%200
  if phase == 0 then
    if timer == 0 then
      cls(4)
    end
    for i=0, 5 do
      --local x = 0.5*sin(T*0.08) + 0.5*sin(T*0.013) + 0.5*sin(T*0.21)
      --local y = 0.5*sin(T*0.12) + 0.5*sin(T*0.023) + 0.5*sin(T*0.31)
      --local x = 0.5*sin(T*0.08) + 0.5*sin(T*0.013)
      --local y = 0.5*sin(T*0.15) + 0.5*sin(T*0.023)
      --addheight(W/2 + W/2.2*x, H/2 + H/2.2*y,10)
      local x = rand(W)
      local y = rand(H)
      local am = -1
      if phase == 1 then
        am = -1
      end
      addheight(x, y, rand(10), am)
    end
  end
  if phase >= 1 then
    if phase == 1 and timer == 0 then
      for i=0,nrspr do
        for j=0,10 do
          local x = rand(W)
          local y = rand(H)
          spr[i] = {
            x = x,
            y = y,
            dx = -2 + rand(3),
            dy = -2 + rand(3),
            delay = rand(200)
          }
          if pix(x,y) == 0 then break end
        end
      end
    end
    for i=0,nrspr do
      local sp = spr[i]
      sp.delay = sp.delay - 1
      local col = pix(sp.x,sp.y)
      --if col == 12 then
      if sp.delay <= 0 then
        pix(sp.x,sp.y,0)
        --end
        if pix(sp.x+sp.dx, sp.y+sp.dy) == 0 then
          sp.x = sp.x + sp.dx
          sp.y = sp.y + sp.dy
        end
        --else
          sp.dx = -2 + rand(3)
          sp.dy = 0 + rand(2)
        --end
        --if col == 0 then
        pix(sp.x,sp.y,10)
      end
      --end
    end
  end
end

