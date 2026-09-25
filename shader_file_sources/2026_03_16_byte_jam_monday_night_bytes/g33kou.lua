-- Hello jammers \o/
-- It's monday night, and soon is Revision !

sin=math.sin
cos=math.cos
pi=math.pi
append=table.insert

function rot(p,a)
   ry=p[2]*cos(a[1])-p[3]*sin(a[1])
   rz=p[2]*sin(a[1])+p[3]*cos(a[1])
   rx=p[1]*cos(a[2])+rz*sin(a[2])
   rz=-p[1]*sin(a[2])+rz*cos(a[2])
   rx2=rx*cos(a[3])-ry*sin(a[3])
   ry=rx*sin(a[3])+ry*cos(a[3])
   return {rx2,ry,rz}
end

function disp(p,c)
   pix(120+p[1], 68-p[2], c)
end

v={}
T=0
function TIC()
   T=T+1
   cls()
   for i=1,99 do
      v[i]=vqts(i)*40
   end
   
   t={}
   for i=1,#v do
      p={i, v[i], 0}
      append(t,p)
      a={0, pi/2, 0}
      append(t,rot(p,a))
      a={-pi/2, 0, 0}
      append(t,rot(p,a))
      a={pi/2, pi/2, 0}
      append(t,rot(p,a))
      a={-pi/2, 0, pi/2}
      p1=rot(p,a)
      append(t,p1)
      a={0, -pi/2, 0}
      p1=rot(p1,a)
      append(t,p1)
   end
   
   ar={T/100, T/100, 0}
   for i=1,#t do
      t[i]={t[i][1]-50, t[i][2]-50, t[i][3]+50}
      p=rot(t[i],ar)
      disp(p,i%7+1)
      
      a={-pi/2, pi, 0}
      p=rot(t[i],a)
      p=rot(p,ar)
      disp(p,i%7+1)
   end

end
