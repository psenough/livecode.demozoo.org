-- hello there \o/

min=math.min
max=math.max
cos=math.cos
sin=math.sin

function BOOT()
   v={}
   for z=-3,3 do
      for y=-3,3 do
         for x=-3,3 do
            v[#v+1]={x,y,z,x*y*z}
         end
      end
   end
   a=0
end

function rot(x,y,z,ax,ay,az)
   local rx,ry,rz,rx2
   ry=y*cos(ax)-z*sin(ax)
   rz=y*sin(ax)+z*cos(ax)
   rx=x*cos(ay)+rz*sin(ay)
   rz=-x*sin(ay)+rz*cos(ay)
   rx2=rx*cos(az)-ry*sin(az)
   ry=rx*sin(az)+ry*cos(az)
   return rx2,ry,rz
end

function TIC()
   local x,y,z,c,ff
   cls()
   ff=min(max(fft(0,50)*2,8),15)
   for i=1,#v do
      x=v[i][1]
      y=v[i][2]
      z=v[i][3]
      c=v[i][4]
      x,y,z=rot(x,y,z,a,a,a)
      circ(120+x*ff,68-y*ff,1,c)
   end
   a=a+.01
end
