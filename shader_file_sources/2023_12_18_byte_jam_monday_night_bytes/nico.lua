-- "Spirals" by Nico
-- I have spirals on my mind
-- I have spirals in my mind
-- Be careful not to stare too long
-- you might get spirals too

-- greets to everybody in the demoscene and beyond
-- also to mesmer apparently

function TIC()t=time()/200
cx = 240/2
cy = 138/2
m = math

for y=0,136 do for x=0,240 do
	x2 = x-cx
	y2 = y-cy
	distance = m.sqrt(m.pow(x2,2)+m.pow(y2,2))
	angle = m.atan(x2,y2)
	col = m.sin(0.5 * distance + angle + t) 
 rev = m.sin(-0.5 * distance + angle + t)
 c = 0
 if rev > 0.4  then
	 c = 7
 elseif col > 0.4 then
	 c = 4
 elseif rev*col > 0.8 then
	 c = 12
 end
 
	pix(x,y,c)
end end end