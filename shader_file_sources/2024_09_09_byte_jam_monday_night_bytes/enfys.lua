--beep boop enfys

--yippee palette
for i=0,15 do
 a=0x3FC0+i*3
 v=i*255/15
 poke(a,  (v/255)^0.5*255)
 poke(a+1,(v/255)^2.5*255)
 poke(a+2,(v/255)^2.5*255)
end

sin=math.sin
cos=math.cos
pi=math.pi

--hoho yes we doing 3d tonight
function rotx(p,a)
 xt = p.x
 yt = p.y*cos(a)-p.z*sin(a)
 zt = p.y*sin(a)+p.z*cos(a)
 return {x=xt,y=yt,z=zt}
end

function roty(p,a)
 xt = p.x*cos(a)-p.z*sin(a)
 yt = p.y
 zt = p.x*sin(a)+p.z*cos(a)
 return {x=xt,y=yt,z=zt}
end

function rotz(p,a)
 xt = p.x*cos(a)-p.y*sin(a)
 yt = p.x*sin(a)+p.y*cos(a)
 zt = p.z
 return {x=xt,y=yt,z=zt}
end

--i hope this works lol
cls()
function TIC()
 cls()
 
 --for i=0,5000 do
  --pix(math.random()*240,math.random()*136,0)
 --end
 
 t=time()/100
 
 points={}
 txttab={}
 for i=1,48 do
  txttab[i]={}
 end
 print("HELLO MUM",sin(t/6)*48-12,21+cos(t/4)*8,12,true,3)

 for y=1,41 do
  for x=1,41 do
   txttab[y][x]=peek4((y*240)+x)
   --pix(x,y+20,txttab[x][y])
  end
 end

 rect(0,0,240,136,0)

 for x=-20,20 do
  for y=-20,20 do
   for z=0,0 do
    pt={x=x,y=y,z=z}
    pt.z=pt.z+(sin(pt.x/4+t/3)*sin(pt.y/8+t/6)*sin(pt.x/13+t/3)*2)
    tx=x+21
    ty=y+21
    
    --ahh well i cant get this
    --shit to work
    
    --was worth a try innit
    if pt.z>=2 and pt.z<=10 then
    cv=7
    else
    cv=(pt.z*4)
    pt.z=txttab[tx][ty]/2
    end
    pt=rotz(pt,-1.6+sin(t/8))
    pt=rotx(pt,pi/2+sin(t/32)/4+0.4)
    pt.z=pt.z+200
    pt.y=pt.y/pt.z
    pt.x=pt.x/pt.z
    --lets try and remember how this
    --one works ough    
    table.insert(points,{x=pt.x,y=pt.y,z=pt.z+400,col=cv})
   end
  end
 end
 --bloody projection !!!!1
 mult=2^18
 for i=1,#points do
  pix(120+mult*points[i].x/points[i].z*2,68+mult*points[i].y/points[i].z*2,points[i].col+8)
 end
 
end
