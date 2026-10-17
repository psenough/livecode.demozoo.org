-- Bytejam 2025-06-02
-- Thanks for the jam everyone! Hope you all have a great time at Nova!

XRANGE = 240
YRANGE = 136
NLINES = 100
PI = 3.14159265359
TETRA_STRIDE = 50
FFT_ACCUMULATION_RATE = 0.3

fft_integrals = {}

for tet=1,18 do
 bin = TETRA_STRIDE * tet
 fft_integrals[bin] = 0
end

function build_tetra()
 tetra_x = {}
 tetra_y = {}
 tetra_z = {}
 
 tetra_x[0] = math.sqrt(8/9)
 tetra_y[0] = 0
 tetra_z[0] = -1/3
 
 
 tetra_x[1] = -math.sqrt(2/9)
 tetra_y[1] = math.sqrt(2/3)
 tetra_z[1] = -1/3
 
 tetra_x[2] = -math.sqrt(2/9)
 tetra_y[2] = -math.sqrt(2/3)
 tetra_z[2] = -1/3
 
 tetra_x[3] = 0
 tetra_y[3] = 0
 tetra_z[3] = 1
end

function cube(origin_x, origin_y, origin_z, scale)
 local cube_x = {}
 local cube_y = {}
 local cube_z = {}
 
 for i=0,8 do
  cube_x[i] = 0.1*(2*(i & 4)/4 - 1) + origin_x
  cube_y[i] = scale*(2*(i & 2)/2 - 1) + origin_y
  cube_z[i] = scale*(2*(i & 1) - 1) + origin_z
 end
 
 local out = {}
 out.x = cube_x
 out.y = cube_y
 out.z = cube_z
 
 return out
end

function BOOT()
 build_tetra()
 cam = {}
 cam[0] = PI/4
 cam[1] = PI/4
 cam[2] = 0
 cls()
end

function camera(yaw, pitch, roll, px, py, pz)
 --world to camera transform
 --camera depth in z
 local ca = math.cos(yaw)
 local sa = math.sin(yaw)
 local cb = math.cos(pitch)
 local sb = math.sin(pitch)
 local cc = math.cos(roll)
 local sc = math.sin(roll)
 
 local cxx = ca * cb
 local cxy = sa * cb
 local cxz = -sb
 
 local cyx = ca*sb*sc - sa*cc
 local cyy = sa*sb*sc + ca*cc
 local cyz = cb*sc
 
 local czx = ca*sb*cc + sa*sc
 local czy = sa*sb*cc - cc*sc
 local czz = cb*cc
 
 local trans_x = cxx * px + cxy * py + cxz * pz
 local trans_y = cyx * px + cyy * py + cyz * pz
 local trans_z = czx * px + czy * py + czz * pz
 
 local ret = {}
 ret[0] = trans_x
 ret[1] = trans_y
 ret[2] = trans_z + 5
 return ret
end

function perspective(x, y, z)
 --camera to clip space
 --keep camera depth in z
 local ret = {}
 ret[0] = x/z
 ret[1] = y/z
 ret[2] = z
 return ret
end

function draw_face(verts, index0, index1, index2, col, scale, filled)
 --no z sort for now
 local vert0 = verts[index0]
 local vert1 = verts[index1]
 local vert2 = verts[index2]
 local centx = XRANGE/2
 local centy = YRANGE/2
 
 if filled then
 tri(centx+scale*vert0[0],centy+scale*vert0[1],
     centx+scale*vert1[0],centy+scale*vert1[1],
     centx+scale*vert2[0],centy+scale*vert2[1],
     col)
 else
 trib(centx+scale*vert0[0],centy+scale*vert0[1],
      centx+scale*vert1[0],centy+scale*vert1[1],
      centx+scale*vert2[0],centy+scale*vert2[1],
      col)
 end
end


function draw_tetra(theta1, theta2, theta3, scale, col)
 local trans_verts = {}
 for i=0,3 do
  --transform the vertices
  local px = tetra_x[i]
  local py = tetra_y[i]
  local pz = tetra_z[i]
  
  local cam = camera(theta1,theta2,theta3, px, py, pz)
  trans_verts[i] = perspective(cam[0], cam[1], cam[2])
 end
 --don't care about winding order
 --all faces double sided
 draw_face(trans_verts, 0, 1, 2, 0, scale, true)
 draw_face(trans_verts, 0, 1, 3, 0, scale, true)
 draw_face(trans_verts, 0, 2, 3, 0, scale, true)
 draw_face(trans_verts, 1, 2, 3, 0, scale, true)
 draw_face(trans_verts, 0, 1, 2, col, scale, false)
 draw_face(trans_verts, 0, 1, 3, col, scale, false)
 draw_face(trans_verts, 0, 2, 3, col, scale, false)
 draw_face(trans_verts, 1, 2, 3, col, scale, false)
end

function draw_cube(origin, cube_scale, scale, col, cam)
 local trans_verts = {}
 local cube = cube(origin.x, origin.y, origin.z, cube_scale)
 for i = 0,8 do
  local px = cube.x[i]
  local py = cube.y[i]
  local pz = cube.z[i]
  
  local cam = camera(cam[0],cam[1],cam[2], px, py, pz)
  trans_verts[i] = perspective(cam[0], cam[1], cam[2])
 end
 
 --can we remember our cube indices
 draw_face(trans_verts,0,1,2, col, scale, false)
 draw_face(trans_verts,1,2,3, col, scale, false)
 
 draw_face(trans_verts,0,1,4, col, scale, false)
 draw_face(trans_verts,4,5,1, col, scale, false)
 
 draw_face(trans_verts,2,3,6, col, scale, false)
 draw_face(trans_verts,3,6,7, col, scale, false)
 
 draw_face(trans_verts,4,6,7, col, scale, false)
 draw_face(trans_verts,4,5,7, col, scale, false)

 draw_face(trans_verts,2,4,6, col, scale, false)
 draw_face(trans_verts,0,2,4, col, scale, false)
     
 draw_face(trans_verts,1,3,5, col, scale, false)
 draw_face(trans_verts,3,5,7, col, scale, false)
     
 --let's just work it out
 --
 -- 0  1
 --  4  5
 -- 2  3
 --  6  7
 --
 
end 

function oldTIC()
 for x=0,XRANGE do
  for y=0,YRANGE do
   if math.random()>0.9 then
   pix(x,y,0)
   end
  end
 end
 --cls()
 --draw radial FFT
 for ray=0,NLINES do
  theta = 2 * ray * PI/NLINES
  power = 1000*fft(ray*1023/NLINES)
  line(XRANGE/2,
       YRANGE/2,
       XRANGE/2+power*math.cos(theta),
       YRANGE/2+power*math.sin(theta),
       ray*16/NLINES)
 end
 --draw tetrahedron stack
 for tet=1,18 do
  bin = TETRA_STRIDE*tet
  fft_integrals[bin] = fft_integrals[bin] + FFT_ACCUMULATION_RATE*ffts(bin)
  if tet < 17 then
   draw_tetra(fft_integrals[bin],fft_integrals[bin+TETRA_STRIDE], fft_integrals[bin+2*TETRA_STRIDE], (ffts(bin))*1800,tet)
  end
 end

end

function TIC()
 local spacing = 0.2
 
 for x=0,XRANGE do
  for y=0,YRANGE do
   if math.random()>0.9 then
   pix(x,y,0)
   end
  end
 end
 
 local origin = {}
 origin.x = -9*spacing
 origin.y = 0
 origin.z = 0
 
 --draw_cube(origin, 150, 1, camera)
 
 circb(XRANGE/2,YRANGE/2,cam[0]*100%150,15)
 
 for tet=1,18 do
  bin = TETRA_STRIDE * tet
  local scale = math.tanh(5*ffts(bin))
  origin.x = origin.x + spacing
  draw_cube(origin, scale, 300, tet % 16, cam)
 end
 
 cam[0] = cam[0]+0.01
 cam[1] = cam[1]+0.02

end