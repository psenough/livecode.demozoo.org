-- hello from gasman! Good to be back...
-- greetings to my fellow jammers
--                    ^
-- luchak, jtruk and tobach

-- alrighty!
-- the big idea for tonight is:
-- gouraud shading.
-- because it's the one thing that
-- tic80 doesn't give you for free,
-- so I have to write my own triangle
-- rasteriser.

-- "we do these things, not because
-- they are easy, but because they
-- look really cool" - J.F.Kennedy

for i=0,15 do
 poke(16320+i*3,i*15)
 poke(16321+i*3,i*15)
 poke(16322+i*3,i*15)
end

vertices = {
 {-1, -1, -1},
 {-1, -1, 1},
 {-1, 1, 1},
 {-1, 1, -1},
 {1, 1, -1},
 {1, 1, 1},
 {1, -1, 1},
 {1, -1, -1},
}
faces={
 {1,2,3},
 {1,3,4},
 {2,7,6},
 {2,6,3},
 {7,8,5},
 {7,5,6},
 {8,1,4},
 {8,4,5},
 {4,3,5},
 {3,6,5},
 {1,8,2},
 {8,7,2},
}
m=math

-- ok, time to actually do the thing
-- and write a triangle rasteriser

function mytri(x1,y1,z1,x2,y2,z2,x3,y3,z3,c)
 x1=x1//1;y1=y1//1
 x2=x2//1;y2=y2//1
 x3=x3//1;y3=y3//1
 ymin=m.min(y1,y2,y3)
 ymax=m.max(y1,y2,y3)
 xmin={}
 zmin={}
 xmax={}
 zmax={}
 for y=ymin,ymax do
  xmin[y]=999
  zmin[y]=0
  xmax[y]=0
  zmax[y]=0
 end

 if y1<=y2 then
  xa=x1;ya=y1;za=z1;xb=x2;yb=y2;zb=z2
 else
  xa=x2;ya=y2;za=z2;xb=x1;yb=y1;zb=z1
 end
 dy=yb-ya
 dx=(xb-xa)/dy
 dz=(zb-za)/dy
 x=xa
 z=za
 for y=ya,yb do
  if x<xmin[y] then
   xmin[y]=x
   zmin[y]=z
  end
  if x>xmax[y] then
   xmax[y]=x
   zmax[y]=z
  end
  x=x+dx
  z=z+dz
 end

 if y1<=y3 then
  xa=x1;ya=y1;za=z1;xb=x3;yb=y3;zb=z3
 else
  xa=x3;ya=y3;za=z3;xb=x1;yb=y1;zb=z1
 end
 dy=yb-ya
 dx=(xb-xa)/dy
 dz=(zb-za)/dy
 x=xa
 z=za
 for y=ya,yb do
  if x<xmin[y] then
   xmin[y]=x
   zmin[y]=z
  end
  if x>xmax[y] then
   xmax[y]=x
   zmax[y]=z
  end
  x=x+dx
  z=z+dz
 end

 if y2<=y3 then
  xa=x2;ya=y2;za=z2;xb=x3;yb=y3;zb=z3
 else
  xa=x3;ya=y3;za=z3;xb=x2;yb=y2;zb=z2
 end
 dy=yb-ya
 dx=(xb-xa)/dy
 dz=(zb-za)/dy
 x=xa
 z=za
 for y=ya,yb do
  if x<xmin[y] then
   xmin[y]=x
   zmin[y]=z
  end
  if x>xmax[y] then
   xmax[y]=x
   zmax[y]=z
  end
  x=x+dx
  z=z+dz
 end
 
 for y=ymin,ymax do
  z=zmin[y]
  dz=(zmax[y]-z)/(xmax[y]-xmin[y])
  for x=xmin[y],xmax[y] do
   pix(x,y,z)
   z=(z+dz)
  end
 end

end

function TIC()
 cls()
 t=time()
 ra=t/1000
 rb=t/1234
 rc=t/1345
 vt1={}
 vt2={}
 vt={}
 vs={}
 for i=1,8 do
  v=vertices[i]
  vt1={
   v[1]*m.cos(ra)+v[3]*m.sin(ra),
   v[2],
   v[3]*m.cos(ra)-v[1]*m.sin(ra),
  }
  vt2={
   vt1[1]*m.cos(rb)+vt1[2]*m.sin(rb),
   vt1[2]*m.cos(rb)-vt1[1]*m.sin(rb),
   vt1[3]
  }
  vt[i]={
   vt2[1],
   vt2[2]*m.cos(rc)+vt2[3]*m.sin(rc),
   vt2[3]*m.cos(rc)-vt2[2]*m.sin(rc),
  }
  vs[i]={
   120+vt[i][1]*32,
   68+vt[i][2]*32,
   (vt[i][3]+1)*5
  }
 end
 for i=1,12 do
  f=faces[i]
  v1=vs[f[1]]
  v2=vs[f[2]]
  v3=vs[f[3]]
  -- z component of cross product
  xpz=(v2[1]-v1[1])*(v3[2]-v1[2])-(v2[2]-v1[2])*(v3[1]-v1[1])
  if xpz>0 then
   mytri(v1[1],v1[2],v1[3],v2[1],v2[2],v2[3],v3[1],v3[2],v3[3],i+1)
  end
 end
end
