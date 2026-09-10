-- pos: 0,0
-- ^
--tobach here...
--hello revision!!!!
--not as scary as i thought being on
--the front stage... ;-)
m=math
sin=m.sin
cos=m.cos
p2={}
points={
{x=0,y=0,z=0},
{x=4,y=0,z=0},
{x=5,y=1,z=0},
{x=5,y=6,z=0},
{x=0,y=6,z=0},
}

function rx(p,ang)
 xt=p.x
 yt=p.y*cos(ang)-p.z*sin(ang)
 zt=p.y*sin(ang)+p.z*cos(ang)
 return {x=xt,y=yt,z=zt}
end


function ry(p,ang)
 xt=p.x*cos(ang)-p.z*sin(ang)
 yt=p.y
 zt=p.x*sin(ang)+p.z*cos(ang)
 return {x=xt,y=yt,z=zt}
end


function rz(p,ang)
 xt=p.x*cos(ang)-p.y*sin(ang)
 yt=p.x*sin(ang)+p.y*cos(ang)
 zt=p.z
 return {x=xt,y=yt,z=zt}
end

function TIC()
 cls()
 t=time()/64
 for y=0,136,2 do
  for x=0,240,2 do
   sv=sin(x/32+t/4+sin(y/16+t/7)+t/4)*sin(t/8)*8
   pix(x,y,sv)
  end
 end
  logocrap(30,-20)
 
end

function logocrap(x,y)
 rect(10,24,220,120,3)
 for i=0,4 do
  sv2=-sin(i/1.1)*4
  rect(36+i*32,50+sv2,30,80,14)
  rectb(36+i*32,50+sv2,30,80,15)
 end

 rect(x+50,y+50,50,50,2)
 rect(x+50,y+60,65,40,2)
 rect(x+54,y+54,40,8,12)
 rect(x+54,y+88,40,8,12)
 rect(x+54,y+72,20,8,12)
 rect(x+54,y+60,8,36,12)
 
 print("WERK",x+60,y+102,12,true,2)
 
 tri(0,26,120,-5,240,26,13)
 for i=0,3 do
  print("WE ARE BACK TO BACK IN THE E-WERK",240-t*16%1200-i,110-i+sin(t)*8,15-i,true,4)
 end
end