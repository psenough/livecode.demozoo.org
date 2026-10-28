sin=math.sin
cos=math.cos

for i=1,7 do
 poke(16344+i*3,peek(16320+i*3)//3)
 poke(16345+i*3,peek(16321+i*3)//3)
 poke(16346+i*3,peek(16322+i*3)//3)
end

verts={}
for j=0.1,1,0.2 do
 for i=0,1,0.04 do
  t=i*math.pi*2
  x0=16*math.pow(sin(t),3)
  y0=13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t)
  x1=sin(t)
  y1=cos(t)
  x=x0*(1-j)+x1*j
  y=y0*(1-j)+y1*j
  table.insert(verts,{
   x,y,j*3,
   (math.random()*7)//1+1
  })
  table.insert(verts,{
   x,y,-j*3,
   (math.random()*7)//1+1
  })
 end
end

function TIC()
 cls()
 rx=time()/1234
 ry=time()/2345
 rz=time()/1818
 for _,v0 in ipairs(verts) do
  v1={
   v0[1],
   v0[2]*cos(rx)+v0[3]*sin(rx),
   v0[3]*cos(rx)-v0[2]*sin(rx),
  }
  v2={
   v1[1]*cos(ry)+v1[3]*sin(ry),
   v1[2],
   v1[3]*cos(ry)-v1[1]*sin(ry),
  }
  v3={
   v2[1]*cos(rz)+v2[2]*sin(rz),
   v2[2]*cos(rz)-v2[1]*sin(rz),
   v2[3],
  }
  clr=v0[4]
  if v3[3]<0 then
   clr=clr+8
  end
  pix(
   120+4*v3[1],
   68-4*v3[2],
   clr
  )
 end
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>