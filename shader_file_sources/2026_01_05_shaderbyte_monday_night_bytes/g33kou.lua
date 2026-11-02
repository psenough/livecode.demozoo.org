-- hello there, happy new year \o/
-- this is my first 3D cube, I'm so happy !!!

sin=math.sin
cos=math.cos
max=math.max
min=math.min
rnd=math.random
t=0
function BOOT()
   v={
      {-1,-1,-1}, {-1,1,-1}, {1,1,-1}, {1,-1,-1},
      {-1,-1,1}, {-1,1,1}, {1,1,1}, {1,-1,1},
   }
   s={
      {1,2,1}, {2,3,2}, {3,4,3}, {4,1,4},
      {5,6,5}, {6,7,6}, {7,8,7}, {8,5,8},
      {1,5,9}, {2,6,10}, {3,7,11}, {4,8,12},
   }
   a=0
   scl=30
   ox=120
   oy=136-68
   cls()
end

function rotx(m,a)
   local rx=m[1]
   local ry=m[2]*cos(a) - m[3]*sin(a)
   local rz=m[2]*sin(a) + m[3]*cos(a)
   return {rx,ry,rz}
end

function roty(m,a)
   local rx=m[1]*cos(a) + m[3]*sin(a)
   local ry=m[2]
   local rz=-m[1]*sin(a) + m[3]*cos(a)
   return {rx,ry,rz}
end

function rotz(m,a)
   local rx=m[1]*cos(a) - m[2]*sin(a)
   local ry=m[1]*sin(a) + m[2]*cos(a)
   local rz=m[3]
   return {rx,ry,rz}
end

function TIC()
   t=t+1
   for i=1,2000 do
      pix(rnd(20,220),rnd(137)-1,0)
   end
   a=a+.01
   local fscl=min(max(scl*fft(0,25)/5,20),40)
   for i=1,#s do
      local m1=rotx(roty(rotz(v[s[i][1]],a),a),a)
      local m2=rotx(roty(rotz(v[s[i][2]],a),a),a)
      local x1=ox+m1[1]*fscl
      local y1=oy+m1[2]*fscl
      local x2=ox+m2[1]*fscl
      local y2=oy+m2[2]*fscl
      line(x1,y1,x2,y2,s[i][3])
      if t%100==0 then
         s[i][3]=(s[i][3]+1)%10+1
      end
   end
   print("Praise the cube !!!",1,5,3)
end
