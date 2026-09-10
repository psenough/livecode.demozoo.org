-- Let's do something from scratch
-- this time :)
-- Greetz to Aldroid, jtruk & HeNeArXe
-- as well as people in the chat

--whoops
sin=math.sin
cos=math.cos
pi=math.pi
abs=math.abs

function BOOT()
 t=0
 rotor=0
 rotor2=0
 
end

function clamp(val,vald,valu)
 if val > vald then 
  if val > valu then return valu else return val end
 else
  return vald
 end  
end

function petal(ox,oy,rot)
 tri(ox+0*cos(rot)-0*sin(rot),oy+0*sin(rot)+0*cos(rot),
     ox+-8*cos(rot)-40*sin(rot),oy+-8*sin(rot)+-40*cos(rot),
     ox+0*cos(rot)-60*sin(rot),oy+0*sin(rot)+-60*cos(rot), 3)
 tri(ox+0*cos(rot)-0*sin(rot),oy+0*sin(rot)+0*cos(rot),
     ox+8*cos(rot)-40*sin(rot),oy+8*sin(rot)+-40*cos(rot),
     ox+0*cos(rot)-60*sin(rot),oy+0*sin(rot)+-60*cos(rot), 3)     
end

function petal2(ox,oy,rot,grth)
 tri(ox+0*cos(rot)-0*sin(rot),oy+0*sin(rot)+0*cos(rot),
     ox+-8*cos(rot)+(-40-grth)*sin(rot),oy+-8*sin(rot)+(-40-grth)*cos(rot),
     ox+0*cos(rot)+(-60-grth)*sin(rot),oy+0*sin(rot)+(-60-grth)*cos(rot), 2)
 tri(ox+0*cos(rot)-0*sin(rot),oy+0*sin(rot)+0*cos(rot),
     ox+8*cos(rot)+(-40-grth)*sin(rot),oy+8*sin(rot)+(-40-grth)*cos(rot),
     ox+0*cos(rot)+(-60-grth)*sin(rot),oy+0*sin(rot)+(-60-grth)*cos(rot), 2)     
end

function circfft(x,y,r,tim,cshft)
 for i=0,360 do
  circ(x+(90*fft(i%90)+r)*sin((i+tim)/180*pi),y+(90*fft(i%90)+r)*cos((i+tim)/180*pi),1,cshft+i%4) 
 end 
end

function deg2rad(deg)
 return deg*pi/180
end

function TIC()
 cls(0)
 t=time()/60
 rotor=rotor+clamp(3*fft(1),0,9)
 rotor2=rotor2+clamp(3*fft(1),0,3)
 for xi=0,52 do
  for yi=0,48 do
   circ(2+xi*5,2+yi*5,1,t+xi+yi-rotor)
  end 
 end 
 circfft(120,68,30,t,5) 
 for i=0,11 do
  petal2(120,68,deg2rad(30*i+360*sin(t/30)),50*fft(8))
 end
 for i=0,11 do
  petal(120,68,deg2rad(30*i+rotor))
 end
 circ(120,68,12,4)
end
