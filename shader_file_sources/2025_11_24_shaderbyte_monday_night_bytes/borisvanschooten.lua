-- BORIS monday night bytes

sin = math.sin
cos = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
pi = math.pi

h = 136
w = 240


cls(2)
t=0


NRP = 1000
p = {}
for i=0,NRP do
  p[i] = {
    t=-1,
    ty=-1,
    x=rand(0,w),
    y=rand(0,h),
    c=rand(1,11),
    dc = 1,
    vx = 0.01*rand(-10,10),
    vy = 0.01*rand(-10,10),
  }
end


pidx = 0

phase=0
delay=1
number=0
color = 1
rrand = 0

cls(0)

function TIC()
  for y=0,h-1 do
    for x=0,w-1 do
      col = pix(x,y)
      if col > 0 and col <= 4 then
        if rand(0,10) < 1 then
          pix(x,y,col-1)
        end
      end
      if col >=5 and col <= 11 then
        if rand(0,3) < 1 then
          pix(x,y,0)
        end
      end
      if col==12 then
        if rand(0,3) < 1 then
          pix(x,y,0)
        end
      end
    end
  end
  t = t + 1
  if t % 15 == 1 then
    if delay > 0 then
      delay = delay-1
      if delay <= 0 then
        number = 3 + 2*rand(0,1)
        type = rand(0,3)
        if type == 0 then
          color = 1
          dcolor = 1
        end
        if type == 1 then
          color = 8
          dcolor = 1
        end
        if type == 2 then
          color = 8
          dcolor = -1
        end
        blink = rand(0,1)
        --color=1 + 2*rand(0,4)
        --dcolor = -1 + 2*rand(0,1)
        rrand = rand(1,10)
        phased = -1 + 2*rand(0,1)
        phase = -0.2 + 0.1*rand(0,2) + phased*0.5*3.1416
        phased = phased/number
        phased = 0.5*phased*rand(1,10)
      end
    else
      number = number - 1
      if number <= 0 then
        delay = rand(3,5)
      end
      x=w/2 + w/4*sin(phase)
      y=h/2 + h/4*cos(phase)
      phase = phase+phased
      --c=1 + 8*rand(0,1)
      --r = rand(1,10)
      for i=0,200 do
        ang = i/10
        dist = 0.1+i/400
        p[pidx] = {
          t=rand(50,120),
          ty=-1,
          x=x+rand(-rrand,rrand),
          y=y+rand(-rrand,rrand),
          c=color,
          dc=dcolor,
          vx = dist*sin(ang),
          vy = -0.8+dist*cos(ang),
          bl = blink
        }
        pidx = (pidx+1)%NRP
      end
    end
  end
  for i=0,NRP do
    pa = p[i]
    if pa.t >= 0 then
      pa.x = pa.x+pa.vx
      pa.y = pa.y+pa.vy
      pa.vy = pa.vy + 0.02
      c = pa.c + pa.dc*pa.t/30
      if pa.dc*pa.t/30 < 1 and pa.bl==1 then
        if rand(0,10) < 1 then
          c = 12
        end
      end 
      pix(pa.x,pa.y,c)
      pa.t = pa.t - 1
    end
  end
end

