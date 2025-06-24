-- LIVE CODED triangle pattern thing
-- by Lex Bailey
-- 25/09/2023 - FieldFX Byte Jam

-- oh my! we're live! :)
-- This is my first ever live code
-- thing, super excited!

sin=math.sin
cos=math.cos
tau=6.283

-- Taken from stack overflow :D
-- https://stackoverflow.com/questions/68317097/how-to-properly-convert-hsl-colors-to-rgb-colors-in-lua
function hslToRgb(h, s, l)
    h = h / 360
    s = s / 100
    l = l / 100

    local r, g, b;

    if s == 0 then
        r, g, b = l, l, l; -- achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1 / 6 then return p + (q - p) * 6 * t end
            if t < 1 / 2 then return q end
            if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
            return p;
        end

        local q = l < 0.5 and l * (1 + s) or l + s - l * s;
        local p = 2 * l - q;
        r = hue2rgb(p, q, h + 1 / 3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1 / 3);
    end

    if not a then a = 1 end
    return r * 255, g * 255, b * 255, a * 255
end


function cp_tri(x,y,a,r,c)
  local x1=x+r*(sin(a))
  local y1=y+r*(cos(a))
  local x2=x+r*(sin(a+(tau/3)))
  local y2=y+r*(cos(a+(tau/3)))
  local x3=x+r*(sin(a+((tau/3)*2)))
  local y3=y+r*(cos(a+((tau/3)*2)))
  tri(x1,y1,x2,y2,x3,y3,c)
end

function avg_fft()
 local tot = 0
	for i=0,20 do
		tot=tot+fft(i)
	end
	return tot
end

function palette(n)
	local addr=0x3fc0
	for i=0,15 do
	 local o=i*3
		local l=(i*100)/15
		if l > 100 then
		 l=100
		end
		local r,g,b = hslToRgb(n,100,l)
 	poke(addr+o+0, r)
 	poke(addr+o+1, g)
 	poke(addr+o+2, b)
	end
	local r,g,b = hslToRgb((n+180)%360,100,50)
	poke(addr+(15*3)+0, r)
	poke(addr+(15*3)+1, g)
	poke(addr+(15*3)+2, b)
end

function next(c)
 local c2=(c+1)%15
 if c2 == 0 then
 	c2=1
 end
 return c2
end

function prev(c)
 local c2=(c-1)
 if c2 == 0 then
 	c2=14
 end
 return c2
end

function TIC()
 cls(0)
 local t=time()/60
 cp_tri(180,67,t/50,50,12) 
 cp_tri(60,67,t/50,50,12) 
 cp_tri(120,67,t/50,80,6) 
 palette(t%360)
 local t2 = time()/1000
 local af=avg_fft()*2
 local col=0
 for x=0,11 do
  for y=-3,10 do
   col=next(col)
   angle=0
   local t6=t2%6
   if t6 < 1 then
     angle=angle+((tau/3)*t6)
   end
   local off_x=0
   local off_y=0
   if t6 > 1.5 and t6 < 2.5 then
     off_x = (t6-1.5)*25
   end
   if t6 > 4.5 and t6 < 5.5 then
     off_y = (t6-4.5)*50
   end
   y2=0
   if y%2==1 then
    angle=angle+(tau/2)
    y2=10
   end
   local sz=10
   cp_tri(x*25+off_x,(y*25)+y2,angle,sz+af,col)
   col=next(col)
   cp_tri((x*25)+12,(y*25)+y2+25+off_y,angle,sz-af,col)
  end
  col=next(col)
 end
 
 local t3=(time()/10)
 for i=1,4 do
   cp_tri(((t3+(i*70))%300)-50, -10+(i*30), (-t3/30)+((tau/4)*i), 20+(af*5), 15)
   cp_tri(((t3+(i*70))%300)-50, -10+(i*30), (-t3/30)+((tau/4)*i), 20-(af*5), 14)
 end
 
  for x=0,11 do
  for y=-3,10 do
   col=prev(col)
   angle=0
   local t6=t2%6
   if t6 < 1 then
     angle=angle-((tau/3)*t6)
   end
   local off_x=0
   local off_y=0
   if t6 > 1.5 and t6 < 2.5 then
     off_x = (t6-1.5)*25
   end
   if t6 > 4.5 and t6 < 5.5 then
     off_y = (t6-4.5)*50
   end
   y2=0
   if y%2==1 then
    angle=angle+(tau/2)
    y2=10
   end
   local sz=4
   cp_tri(x*25+off_x,(y*25)+y2,angle,sz+af,col)
   col=prev(col)
   cp_tri((x*25)+12,(y*25)+y2+25+off_y,angle,sz-af,col)
  end
  col=prev(col)
 end
 
end

