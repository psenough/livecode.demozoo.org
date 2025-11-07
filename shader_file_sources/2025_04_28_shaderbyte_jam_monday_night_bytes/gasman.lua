-- pos: 7,163
-- hello!
-- I'm going to have another go at
-- doing the raytracing stuff that I
-- couldn't quite pull off a month ago
-- because there was lots of hairy
-- maths involved.
-- there still is lots of hairy maths
-- involved, but hopefully I've worked
-- it out in advance this time...

sin=math.sin
cos=math.cos
fov=math.tan(math.pi/4)

function rotx(v,a)
 return {
  v[1],
  v[2]*cos(a)+v[3]*sin(a),
  v[3]*cos(a)-v[2]*sin(a),
 }
end

function roty(v,a)
 return {
  v[1]*cos(a)+v[3]*sin(a),
  v[2],
  v[3]*cos(a)-v[1]*sin(a),
 }
end

function rotz(v,a)
 return {
  v[1]*cos(a)+v[2]*sin(a),
  v[2]*cos(a)-v[1]*sin(a),
  v[3],
 }
end

maze={
 {1,1,1,1,1,1,1,1,1,1},
 {1,0,0,0,0,0,0,0,0,1},
 {1,0,1,0,0,0,0,1,0,1},
 {1,0,0,0,0,0,0,0,0,1},
 {1,0,1,0,0,0,0,0,0,1},
 {1,0,0,0,0,0,0,1,0,1},
 {1,0,0,0,0,0,0,0,0,1},
 {1,0,1,0,0,0,0,1,0,1},
 {1,0,0,0,0,0,0,0,0,1},
 {1,1,1,1,1,1,1,1,1,1},
}

function TIC()
 tim=time()

 posa=tim/1333
 -- camera position
 campos={sin(posa)+5,-1,cos(posa)+5}
 --campos={5,-1,5}
 -- camera forward vector
 camfwd={0,0,1}
 -- camera right vector
 camrt={fov,0,0}
 -- camera down vector
 camdn={0,fov,0}
 
 rot_x=sin(tim/876)/3
 camfwd=rotx(camfwd,rot_x)
 camrt=rotx(camrt,rot_x)
 camdn=rotx(camdn,rot_x)
 rot_y=tim/1567
 camfwd=roty(camfwd,rot_y)
 camrt=roty(camrt,rot_y)
 camdn=roty(camdn,rot_y)

 for sy0=0,135 do
  sy=(sy0-67.5)/120
  for sx0=0,239 do
   sx=(sx0-119.5)/120
   rayv={
    camfwd[1]+sx*camrt[1]+sy*camdn[1],
    camfwd[2]+sx*camrt[2]+sy*camdn[2],
    camfwd[3]+sx*camrt[3]+sy*camdn[3],
   }
   -- floor: where ray y component=0
   floort=-campos[2]/rayv[2]
   -- right, now for the complicated
   -- mathsy bit...
   if rayv[1]<0 then
    -- we will hit x grid lines from
    -- the right
    nextxgrid=campos[1]//1
    nextxt=(nextxgrid-campos[1])/rayv[1]
    stepxt=-1/rayv[1]
   else
    -- we will hit x grid lines from
    -- the left
    nextxgrid=(campos[1]//1)+1
    nextxt=(nextxgrid-campos[1])/rayv[1]
    stepxt=1/rayv[1]
   end

   if rayv[3]<0 then
    -- we will hit z grid lines from
    -- the right
    nextzgrid=campos[3]//1
    nextzt=(nextzgrid-campos[3])/rayv[3]
    stepzt=-1/rayv[3]
   else
    -- we will hit z grid lines from
    -- the left
    nextzgrid=(campos[3]//1)+1
    nextzt=(nextzgrid-campos[3])/rayv[3]
    stepzt=1/rayv[3]
   end
   
   bail=0
   while true do
    bail=bail+1
    if bail>100 then
     break
    end
    if floort>=0 and floort<nextxt and floort<nextzt then
     -- hit floor
     floorx=campos[1]+floort*rayv[1]
     floorz=campos[3]+floort*rayv[3]
     pix(sx0,sy0,(floorx//1)~(floorz//1))
     break
    elseif nextxgrid<1 or nextxgrid>10 or nextzgrid<1 or nextzgrid>10 then
     -- out of maze
     pix(sx0,sy0,2)
     break
    elseif nextxt<nextzt then
     wallz=campos[3]+nextxt*rayv[3]
     if wallz>=1 and wallz<=10 and maze[wallz//1][nextxgrid]==1 then
      -- hit x wall
      wally=campos[2]+nextxt*rayv[2]
      pix(sx0,sy0,(wallz//1)~(wally//1))
      break
     end
     -- advance x
     if rayv[1]>0 then
      nextxgrid=nextxgrid+1
     else
      nextxgrid=nextxgrid-1
     end
     nextxt=nextxt+stepxt
    else
     wallx=campos[1]+nextzt*rayv[1]
     if wallx>=1 and wallx<=10 and maze[nextzgrid][wallx//1]==1 then
      -- hit z wall
      wally=campos[2]+nextzt*rayv[2]
      pix(sx0,sy0,(wallx//1)~(wally//1))
      break
     end
     -- advance zs
     if rayv[2]>0 then
      nextzgrid=nextzgrid+1
     else
      nextzgrid=nextzgrid-1
     end
     nextzt=nextzt+stepzt
    end
   end

  end
 end
end
