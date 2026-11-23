sin=math.sin
cos=math.cos
random=math.random
pi=math.pi
min=math.min
max=math.max

t=0
dir=0
vbank(1)
cls()
circ(20,20,20,2)
circ(18,18,15,3)
circ(16,16,9,4)
circ(11,11,2,12)

memcpy(0x4000,0,16320)
cls()

function copy(x,y,s,z,t)
 --local z2=(1/(z))+1 
 --local x=(x-120)*z2+120
 --local y=(y-68)*z2+68
 local o=0
 ttri(
 	x,y,
  x+s,y,
  x,y+s,
  0+o,0,
  0+o,40,
  40+o,0,
  2,0,
  z,z,z)
 ttri(
  x+s,y,
  x,y+s,
  x+s,y+s,
  0+o,40,
  40+o,0,
  40+o,40,
  2,0,
  z,z,z)
end

function rot2d(p,a)
 local c=cos(a)
 local s=sin(a)
 return {
 	x=(c*p.x)+(s*(-p.y)),
  y=(c*p.y)+(s*p.x)
 }
end

function pos()
 local p={
  x=pi*2*random(),
  y=2*random()-1
 }
 local s=math.sqrt(1.001-p.y*p.y)
 return {
 	x=s*cos(p.x),
  y=s*sin(p.x),
  z=p.y
 }
end

pts={}
idx=1
x=.6
z=3

for z=-3,3 do
	for x=-.5,.5 do
		for i=1,30 do
 		local pt=pos()
 		pts[idx]={
 			x=x,
  		y=pt.y*.25,
  		z=pt.z*.25+z,
    t=0
 		}
 		idx=idx+1
  end
 end
end

-- body
for i=1,300 do
 local pt=pos()
 pts[idx]={
  x=pt.x/2,
  y=pt.y/2-.5,
  z=pt.z*4,
    t=1
 }
 idx=idx+1
end

function TIC()
 vbank(1)
 for i=0,40 do
  memcpy(i*120,0x4000+i*120,21)
 end
 
 vbank(0)
 cls()
 for i=1,#pts do
  local pt=pts[i]
  local xz=rot2d({x=pt.x*(1+sin(pt.z+t))+sin(pt.z+t*1.3),y=pt.z},t)
  local xy=rot2d({x=xz.x,y=pt.y*(1+sin(pt.z+t))+cos(pt.z+t*1.3)},sin(t+pt.z))
  --pt.x=xz.x
  --pt.z=xz.y
  --xz=rot2d({x=pt.x,y=pt.y},sin(t/20)/8)
  --pt.x=xz.x pt.y=xz.y
  local z=xz.y/6+.5
  copy(xy.x*30+120,
   xy.y*30+68,
   10-z*3,z,pt.t)
 	--copy(sin(i+t)*80+120,
   --sin(i*2+t*3.3)*80+68,20,1)
 end
 
 vbank(1)
 cls()
 --local x=dir%3-1
 --local y=dir//3%3-1
 --for i=0,min(t*7//1%24,12) do
 	--print("=^^=",
   --5+x*i,
   --40+y*i,i,0,10)
 --end
 if t*7//1%24==23 then dir=dir+1 end
 t=t+.03
end
