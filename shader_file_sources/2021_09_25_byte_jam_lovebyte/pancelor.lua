-- pos: 0,0
m=math
mc=m.cos
ms=m.sin
r=m.random
t=0
add=table.insert
deli=table.remove
dir={0,0,-1,1,0,0}
trace"start"
function TIC()
 if t==0 then
  cls()
  L={}
  pq(1,2,3)
 end
 if t%60==0 then
  add(L,{
   u=-1,
   v=r()*1.8-.9,
   r=r(4)+2,
   t0=t+r(10),
   d=r()/2-.25,
   c=r(15),
  })
 end
 
    for _=0,99 do
        dist=remap(r(),0,1,.45,1.414)^2.8
        ang=r()*6.28
        u=dist*mc(ang)
        v=dist*ms(ang)
  base=remap(m.atan2(v,u)+t/240,-3.14,3.14,-8,8)
  circ(u2x(u),v2y(v),1,cool(base))
    end
 
 i=1
 while i<=#L do
  b=L[i]
  tt=t-b.t0
  b.u=b.u+remap(mc(tt/60),-1,1,-.002,.010)
  b.v=b.v+remap(mc(tt/10),-1,1,-.01*(1-b.d),.01*(1+b.d))
  b.r=b.r+remap(ms(tt/20),-1,1,-.04,.03)
  b.c=b.c+tt/10000
  a=remap(ms(tt/20),-1,1,.3,3)
  elli(u2x(b.u),v2y(b.v),b.r,b.r*a,warm(b.c))
  elli(u2x(b.u),v2y(b.v),b.r/2,b.r*a/2,warm(b.c)-1)
  if b.r<0 then
   deli(L,i)
  else
   i=i+1
  end
 end
    
    t=t+1
end

function warm(c)
 return c%7+1
end
function cool(c)
 return c%8+8
end

function u2x(u)
    return remap(u,-1,1,0,239)
end
function v2y(v)
    return remap(v,-1,1,0,135)
end
function x2u(x)
 return remap(x,0,239,-1,1)
end
function y2v(y)
 return remap(y,0,135,-1,1)
end

function remap(x,a,b,u,v)
 return u+(v-u)*(x-a)/(b-a)
end

function qq(...)
 s=""
 args=table.pack(...)
 for i=1,args.n do
  s=s..args[i].." "
 end
 return s
end
function pq(...)
 trace(qq(...))
end
function pqr(...)
 if r()<0.01 then pq(...) end
end