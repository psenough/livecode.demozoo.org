
-- HELLO BORIS IS HERE


s = math.sin
c = math.cos
atan = math.atan2
sqrt = math.sqrt
rand = math.random
pi = math.pi

h = 136
w = 240


cls(1)
t=0

function TIC()
  cls(0)
  for l=0, 19 do
    invl = 21 - l
    spd = 0.5*l+5
    col = 1 + (l + 1 + 0.2*t)%11
    for x=0, w-1 do
      dist = (invl+4)
      -- yy = 20*(l-6.8) + h/2
      yy = -h/6 + 800 / dist
      amp = 100/dist
          + 3*s(0.01*(10+1*l)*t)
          - (10-l)*0.5
      thick = 20/dist
      --amp = 30 / dist
      stretch = 1.0 + 0.5*s(.1*t)
      phase = 20 + 2*s(0.02*t)
      sfunc = s(0.012*spd*t+0.007*x*(phase-l))
            + 0.3*s(0.034*spd*t+0.028*x*(phase-l))
      sfunc2 = s(0.012*spd*t+0.007*(x+1)*(phase-l))
            + 0.3*s(0.034*spd*t+0.028*(x+1)*(phase-l))
      rect(x,
      	 yy + amp*sfunc,
        1,thick+1, col)
      rect(x,
      	 yy + thick + amp*sfunc,
        1,h, 0)
      if sfunc2 > 0.09+sfunc then 
        rect(x,
        	 yy
          + amp*sfunc,
          1,thick, 12)
        rect(x,
        	 yy + thick + amp*sfunc,
          1,thick, col)
      end
    end
  end
  t=t+1
end

