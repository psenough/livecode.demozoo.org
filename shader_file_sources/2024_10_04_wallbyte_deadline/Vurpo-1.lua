-- Welcome to the Deadline ByteWall!
-- Please delete this code and play.
--
-- Any issues? Find Violet =)
--
-- Have fun!
-- /jtruk + /RaccoonViolet

local S,MAX=math.sin,math.max
m=math
t=0

function BDR(x)
	for i=0,15 do
		poke(0x3fc0+i*3  ,m.floor(m.sin(i+0.05*x+0.3*t)*127+127))
		poke(0x3fc0+i*3+1,m.floor(m.cos(i+0.05*x+0.2*t)*127+127))
		poke(0x3fc0+i*3+2,m.floor(-m.sin(i+0.05*x+0.1*t)*127+127))
	end 
end

function length(p)
 return m.sqrt((p[1]*p[1])+(p[2]*p[2]))
end

function sdCircle(p,c,r)
 return length({p[1]-c[1],p[2]-c[2]})-r
end

function smin(a,b,k)
 local k = k*2.0
 local x = b-a
 return 0.5*(a+b-m.sqrt(x*x+k*k))
end

function TIC()
	t=time()/200
	cls(0)
	for y=0,136 do for x=0,240 do
		if smin(
			sdCircle({x,y},{120+50*m.sin(t*0.8),68+23*m.sin(t*1.123)}, 10*m.sin(t)+25),
			sdCircle({x,y},{120+40*m.cos(t*1.2),68+14*m.cos(t*1.002)}, 10*m.sin(t)+25),
			15) < 0 then
		 pix(x,y,15)
		end
	end end
end