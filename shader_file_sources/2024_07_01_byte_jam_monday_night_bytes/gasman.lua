-- hello from gasman!
-- greetings to my fellow jammers,
-- aldroid in the control room,
-- lynn on the decks
-- AND YOU!!!!!

-- screw it, I'm starting again...

vertices={}
vertices2={}

for i=0,100 do
 vertices[i]={
  math.random()*2-1,
  math.random()*2-1,
  math.random()*2-1,
  math.random(16)
 }
end

function maketree(rx,dy,iter,bx,by,bz,rz)
 local x0=0
 local y0=0
 local z0=0
 local x1=0
 local y1=0
 local z1=0
 local x2=0
 local y2=0
 local z2=0
 for i=0,10 do
  x0=bx
  y0=by+i/20
  z0=bz
  x1=x0
  y1=y0*math.cos(rx)+z0*math.sin(rx)
  z1=z0*math.cos(rx)-y0*math.sin(rx)
  x2=x1*math.cos(rz)+y1*math.sin(rz)
  y2=y1*math.cos(rz)-x1*math.sin(rz)
  z2=z1
  table.insert(vertices2,{
   x2,y2+dy,z2,i
  })
 end
 if iter>0 then
  maketree(rx+0.3,dy*0.5,iter-1,x2,y2+dy,z2,rz+0.2)
  maketree(rx-0.3,dy*0.5,iter-1,x2,y2+dy,z2,rz-0.2)
 end
end

maketree(0,-0.5,6,0,0,0,0)

function TIC()
 t=time()
 cls()
 r=t/1000
 for i=0,100 do
  v=vertices[i]
  x0=v[1]
  y0=v[2]+fft(i)
  z0=v[3]
  x1=x0*math.cos(r)+z0*math.sin(r)
  y1=y0
  z1=z0*math.cos(r)-x0*math.sin(r)
  circ(120+100*x1,68-100*y1,z1+1,v[4])
 end
 lastx=0
 lasty=0
 for i=1,#vertices2 do
  v=vertices2[i]
  x0=v[1]
  y0=v[2]
  z0=v[3]
  x1=x0*math.cos(r+y0)+z0*math.sin(r+y0)
  y1=y0
  z1=z0*math.cos(r+y0)-x0*math.sin(r+y0)
  sx=120+100*x1
  sy=68-100*y1
  if lastx~=0 or lasty~=0 then
   line(sx,sy,lastx,lasty,15)
  end
  lastx=sx
  lasty=sy
 end

 for i=1,#vertices2 do
  v=vertices2[i]
  x0=v[1]
  y0=v[2]
  z0=v[3]
  x1=x0*math.cos(r+y0)+z0*math.sin(r+y0)
  y1=y0
  z1=z0*math.cos(r+y0)-x0*math.sin(r+y0)
  sx=120+100*x1
  sy=68-100*y1
  circ(sx,sy,z1+1,v[4]-t/100)
 end

end
