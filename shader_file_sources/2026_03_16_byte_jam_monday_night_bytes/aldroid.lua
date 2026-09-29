

tfm=function(x,y,z)
 X,Z = rot(x,z,0.3)
 return X,y,Z
end

function PX(x,y,z)
if y==nil then
y=x[2]
z=x[3]
x=x[1]
end
x,y,z=tfm(x,y,z)
cz=50
lm=40
X=x*lm/(z+cz)
Y=y*lm/(z+cz)
return X+120,Y+68
end


function rot(x,y,a)
 return x*math.cos(a)-y*math.sin(a),y*math.cos(a)+x*math.sin(a)
end
 cs= 20
 cp = 1
 zd=0

function gridrect(x,y,c)

 p1x,p1y=PX(x*cs,y*cs,zd)
 p2x,p2y=PX((x+1)*cs-cp,y*cs,zd)
 p3x,p3y=PX((x+1)*cs-cp,(y+1)*cs-cp,zd)
 p4x,p4y=PX(x*cs,(y+1)*cs-cp,zd)
 tri(p1x,p1y,p2x,p2y,p4x,p4y,c)
 tri(p2x,p2y,p3x,p3y,p4x,p4y,c)
end

ggr={}
ggs=40
rwx=0
rwy=0
function ngg()
ggr={}
for y=0,ggs do 
ggr[y]={}
for x=0,ggs do
ggr[y][x]=nil
end end
rwx=math.floor(ggs/2)
rwy=math.floor(ggs/2)
end

ngg()

function dgr()
 for y=0,ggs do for x=0,ggs do
  vl=ggr[y][x]
  if vl ~= nil then
   gridrect(x-ggs/2,y-ggs/2,vl)
  end
 end end
end

function dwst()
 nrwx=rwx + math.random(-1,1)
 nrwy=rwy + math.random(-1,1)
 if nrwx < 0 then nrwx = 0 end
 if nrwx > ggs then nrwx = ggs end
 if nrwy < 0 then nrwy = 0 end
 if nrwy > ggs then nrwy =ggs end
 for y = 0, ggs do for x=0,ggs do
  if ggr[y][x] ~= nil then ggr[y][x] = ggr[y][x]-1 end
 end end
 ggr[nrwy][nrwx] = 15
 rwx=nrwx
 rwy=nrwy
end

ccd=200
cd=0
nrs=0

function hln()
end

function TIC()
 t=time()
 cls(0)
 dgr()
 if t-cd >ccd then
  cd = t
  dwst()
  nrs = nrs + 1
  if nrs > 100 then
   ngg()
   nrs=0
  end
 end
 tfm=function(x,y,z)
	 X,Z = rot(x,z,math.sin(t/1200)*.3)
	 return X+math.sin(t/1653)*100,y,Z
	end
end