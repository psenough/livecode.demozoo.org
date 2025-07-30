-- gasman here!!!!!
-- good to be back...
-- greetinxes to alia, gigabates + nico
-- and aldroid and synaesthesia of coz

-- so tonight I figured I'd play with
-- some lighting and shading
-- it's a bit mathsy, so this could
-- backfire horribly.
-- but yolo and all that

function dot(u1,u2,u3,v1,v2,v3)
 return u1*v1+u2*v2+u3*v3
end

for i=0,15 do
 if i%2==1 then
  poke(16320+i*3,255)
 else
  poke(16320+i*3,0)
 end

	if i%4>=2 then
  poke(16321+i*3,255)
 else
  poke(16321+i*3,0)
 end

 if i%8>=4 then
  poke(16322+i*3,255)
 else
  poke(16322+i*3,0)
 end
end

function light(rx,ry,rz,lx,ly,lz)
 ca=dot(rx,ry,rz,lx,ly,lz)/5
 if ca<0 then
  ca=0
 elseif ca>1 then
  ca=1
 end
 return ca
end

function TIC()
 t=time()
 rtr=time()/8000
 srtr=math.sin(rtr)
 crtr=math.cos(rtr)
 rtg=time()/9000
 srtg=math.sin(rtg)
 crtg=math.cos(rtg)
 rtb=time()/7000
 srtb=math.sin(rtb)
 crtb=math.cos(rtb)

 lxr=2*math.sin(t/200)
 lyr=-5
 lzr=2*math.sin(t/220)

 lxg=5
 lyg=2*math.sin(t/300)
 lzg=2*math.sin(t/320)

 lxb=2*math.sin(t/420)
 lyb=2*math.sin(t/400)
 lzb=5

 rad=0.7+0.6*fft(1)
 bgr=math.sin(t/1567)/2

 for sy=0,135 do
  y=(sy-68)/60
  for sx=0,239 do
   x=(sx-120)/60
   a=rad*rad-x*x-y*y
   if a<0 then
    vr=0.1
    vg=y*math.cos(bgr)+x*math.sin(bgr)
    vb=0.5+math.sin(math.sqrt(x*x+y*y)*8-t/200)/2
   else
    z=-math.sqrt(a)
    -- x,y,z is the point where we
    -- hit the sphere
    -- and also the normal vector
    -- because it's a unit circle
    -- on the origin
    -- incoming ray = 0,0,1
    
    -- if I'm making the radius
    -- variable, I need to normalise
    -- the normal.
    nm=math.sqrt(x*x+y*y+z*z)
    nx=x/nm
    ny=y/nm
    nz=z/nm

    -- reflect around normal
    b=2*dot(0,0,1,nx,ny,nz)
    rx=0-b*nx
    ry=0-b*ny
    rz=1-b*nz
    -- ok, now dot product between
    -- the reflection vector and
    -- the light source I think
    vr=light(rx,ry,rz,lxr,lyr,lzr)
    -- not sure if that's exactly
    -- the lighting equation I wanted,
    -- but it'l do

    vg=light(rx,ry,rz,lxg,lyg,lzg)
    vb=light(rx,ry,rz,lxb,lyb,lzb)

   end
   k=0

   hx=sx*crtr+sy*srtr
   hy=sy*crtr-sx*srtr
   h=(math.sin(hx)+math.sin(hy)+2)/4
   if h<vr then k=k+1 end

   hx=sx*crtg+sy*srtg
   hy=sy*crtg-sx*srtg
   h=(math.sin(hx)+math.sin(hy)+2)/4
   if h<vg then k=k+2 end

   hx=sx*crtb+sy*srtb
   hy=sy*crtb-sx*srtb
   h=(math.sin(hx)+math.sin(hy)+2)/4
   if h<vb then k=k+4 end

   pix(sx,sy,k)
  end
 end
end
