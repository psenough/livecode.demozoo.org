l=45+2
m=80+2

_u={}
_v={}
_div={}
_p={}
_d={}
_dt=.2

function BOOT()
 for y=0,l-1 do
  for x=0,m-1 do
   i=y*m+x
   _u[i]=0
   _v[i]=0
   _p[i]=0
   _d[i]=0
  end
 end
 fixbnd(_u)
 fixbnd(_v)
 fixbnd(_p)
 fixbnd(_d)
end

function fixbnd(g)
 for i=1,m-2 do
  g[i]=g[m*(l-2)+i]
  g[m*(l-1)+i]=g[m+i]
 end
 for i=1,l-2 do
  g[m*i]=g[m*i+m-2]
  g[m*i+m-1]=g[m*i+1]
 end
 g[0]=g[m*(l-2)+m-2]
 g[m-1]=g[m*(l-2)+1]
 g[m*(l-1)]=g[m+m-2]
 g[m*l-1]=g[m+1]
end

function advect(g)
 local u=_u
 local v=_v
 local dt=_dt
 local n={}
 for y=1,l-2 do
  for x=1,m-2 do
   i=y*m+x
   sx=math.min(math.max(x-dt*u[i],0),m-1-.00001)
   sy=math.min(math.max(y-dt*v[i],0),l-1-.00001)
   fx=sx//1
   fy=sy//1
   si=fy*m+fx
   v0=g[si]+(sx-fx)*(g[si+1]-g[si])
   v1=g[si+m]+(sx-fx)*(g[si+m+1]-g[si+m])
   n[i]=v0+(sy-fy)*(v1-v0)
  end
 end
 return n
end


frame=0
pal=0
smooth=0
last=0
phase=0
text_x=0
text_y=0
text_frame=-100
thresh=0.02
function TIC()
 frame=frame+1
 local u=_u
 local v=_v
 local div=_div
 local p=_p
 local d=_d
 cls(0)
 
 x0=30+10*math.sin(frame/30)//1
 smooth=smooth+0.5*(fft(0)-smooth)
 if smooth>thresh and last<thresh  then
  pal=pal+3
  phase=(phase+1)%2
  text_frame=frame
  text_x=x0
  text_y=20
 end
 
 if frame-text_frame<10 then
  print(phase>0 and "byte" or "jam",
        text_x,text_y,1,false,2)
  for y=1,l-2 do
   for x=1,m-2 do
    if peek4(y*240+x)>0 then
     d[y*m+x]=4
    end
   end
  end
 end
 last=smooth
 
 for y=40,41 do
  for x=x0,x0+5 do
   i=y*m+x
   v[i]=-5
   --d[i]=d[i]+1
  end
 end
 fixbnd(u)
 fixbnd(v)
 fixbnd(d)
 
 for y=1,l-2 do
  for x=1,m-2 do
   i=y*m+x
   div[i]=u[i+1]-u[i-1]+v[i+m]-v[i-m]
  end
 end
 fixbnd(div)
 
 for k=1,4 do
  for y=1,l-2 do
   for x=1,m-2 do
    i=y*m+x
    p[i]=(p[i+1]+p[i-1]+p[i-m]+p[i+m]-div[i])*0.25
   end
  end 
  fixbnd(p)
 end
 
 for y=1,l-2 do
  for x=1,m-2 do
   i=y*m+x
   u[i]=u[i]*.998+(p[i-1]-p[i+1])/2
   v[i]=v[i]*.998+(p[i-m]-p[i+m])/2
   d[i]=d[i]*.998
  end
 end
 fixbnd(u)
 fixbnd(v)
 
 nu=advect(u)
 nv=advect(v)
 u=nu
 v=nv
 
 fixbnd(u)
 fixbnd(v)
 
 d=advect(d)
 fixbnd(d)
 
 local diff={}
 for y=1,l-2 do
  for x=1,m-2 do
   local i=y*m+x
   diff[i]=d[i+1]+d[i-1]+d[i+m]+d[i-m]-4*d[i]
  end
 end
 fixbnd(diff)
 
 for y=1,l-2 do
  for x=1,m-2 do
   i=y*m+x
   --line(x*3,y*3,x*3+2*u[i],y*3+2*v[i],8)
   --rect(x*3,y*3,3,3,div[i])
   rect(x*3,y*3,3,3,pal+math.max(math.min(8*diff[i]+d[i],8),0))
  end
 end

 if frame%480<240 then
 for y=-68,67 do
  for x=-120,119 do
   th=math.atan(y,x)
   z=math.sqrt(x*x+y*y+1)
   Y=(frame+2000/z)%45//1+1
   X=th*80//6.29%80+1
   i=m*Y//1+X//1
   pix(
    x+120,
    y+68,
    pal+math.max(math.min(8*diff[i]+d[i],8),0)
   )
  end
 end
 end
 
 _u=u
 _v=v
 _d=d
end
