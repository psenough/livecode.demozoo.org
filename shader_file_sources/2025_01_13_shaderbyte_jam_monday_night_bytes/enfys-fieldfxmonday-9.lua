--beep boop enfys

sin=math.sin
cos=math.cos

function rx(p,a)
 xt = p.x
 yt = p.y*cos(a) - p.z*sin(a)
 zt = p.y*sin(a) + p.z*cos(a)
 return {x=xt,y=yt,z=zt}
end

function ry(p,a)
 xt = p.x*cos(a) - p.z*sin(a)
 yt = p.y
 zt = p.x*sin(a) + p.z*cos(a)
 return {x=xt,y=yt,z=zt}
end

function rz(p,a)
 xt = p.x*cos(a) - p.y*sin(a)
 yt = p.x*sin(a) + p.y*cos(a)
 zt = p.z
 return {x=xt,y=yt,z=zt}
end

cube={
{x=-1,y=-1,z=1},
{x=1,y=-1,z=1},
{x=1,y=1,z=1},
{x=-1,y=1,z=1},
{x=-1,y=-1,z=-1},
{x=1,y=-1,z=-1},
{x=1,y=1,z=-1},
{x=-1,y=1,z=-1},
}
cuberot={}
a=0

function docube(c,o)
 scl=4
 for i=1,#cube do
  cuberot[i]=cube[i]
  
  cuberot[i]=rx(cuberot[i],a/8)
  cuberot[i]=ry(cuberot[i],sin(a)+o)
  cuberot[i]=rz(cuberot[i],sin(a/3)+o)
  
  cuberot[i].x=cuberot[i].x*scl
  cuberot[i].y=cuberot[i].y*scl
  cuberot[i].z=cuberot[i].z*scl
  
  cuberot[i].z=cuberot[i].z-15

  --el cheapo perspective
  cuberot[i].x=120+((cuberot[i].x/cuberot[i].z)*128)
  cuberot[i].y=68+((cuberot[i].y/cuberot[i].z)*128)
  
  pix(cuberot[i].x,cuberot[i].y,12)
  
 end
 
 line(cuberot[1].x,cuberot[1].y,cuberot[2].x,cuberot[2].y,c+math.random()*8)
 line(cuberot[2].x,cuberot[2].y,cuberot[3].x,cuberot[3].y,c+math.random()*8)
 line(cuberot[3].x,cuberot[3].y,cuberot[4].x,cuberot[4].y,c+math.random()*8)
 line(cuberot[4].x,cuberot[4].y,cuberot[1].x,cuberot[1].y,c+math.random()*8)

 line(cuberot[5].x,cuberot[5].y,cuberot[6].x,cuberot[6].y,c+math.random()*8)
 line(cuberot[6].x,cuberot[6].y,cuberot[7].x,cuberot[7].y,c+math.random()*8)
 line(cuberot[7].x,cuberot[7].y,cuberot[8].x,cuberot[8].y,c+math.random()*8)
 line(cuberot[8].x,cuberot[8].y,cuberot[5].x,cuberot[5].y,c+math.random()*8)

 line(cuberot[1].x,cuberot[1].y,cuberot[5].x,cuberot[5].y,c+math.random()*8)
 line(cuberot[2].x,cuberot[2].y,cuberot[6].x,cuberot[6].y,c+math.random()*8)
 line(cuberot[3].x,cuberot[3].y,cuberot[7].x,cuberot[7].y,c+math.random()*8)
 line(cuberot[4].x,cuberot[4].y,cuberot[8].x,cuberot[8].y,c+math.random()*8)
 
end

vbank(0)
for i=0,15 do
 poke(0x3fc0+i*3,i*16)
 poke(0x3fc0+i*3+1,i*16)
 poke(0x3fc0+i*3+2,i*16)
end
vbank(1)
for i=0,15 do
 poke(0x3fc0+i*3,i*16)
 poke(0x3fc0+i*3+1,i*16)
 poke(0x3fc0+i*3+2,i*16)
end
vbank(0)


function SCN(scnln)
 vbank(0)
 poke(0x3ff9,math.sin(scnln/24+t/32)*4+math.random()*4)
 poke(0x3ffa,math.random()*8)

 vbank(1)
 cls()
 poke(0x3ff9,math.random()*4)
 a=t/32+scnln/256
 docube(2,sin(a)*4)
end

sqtab1={}
sqtab2={}
sqtab3={}
sqtab4={}
for i=1,32 do
 sqtab1[i]={math.random()*260-20,math.random()*180}
 sqtab2[i]={math.random()*260-20,math.random()*180}
 sqtab3[i]={math.random()*260-20,math.random()*180}
 sqtab4[i]={math.random()*260-20,math.random()*180}
end

cls()
function TIC()
 t=time()/100
 --rect(0,0,240,136,0)
 --for i=0,32639 do poke4(i,peek4(i)-.9) end
 vbank(0)
 for i=t%2,32640,1.9 do poke4(i,i/4e8+t%1) end

 for i=1,#sqtab1-sin(t/4)*16-16 do
  rect(sqtab1[i][1],(sqtab1[i][2]-t*4)%200-40,40,40,1)
 end
 for i=1,#sqtab2-sin(t/4+3.141/2)*16-16 do
  rect(sqtab2[i][1],(sqtab1[i][2]-t*8)%200-60,30,30,2)
 end
 for i=1,#sqtab3-sin(t/4+3.141)*16-16 do
  rect(sqtab3[i][1],(sqtab1[i][2]-t*12)%180-40,20,20,3)
 end
 for i=1,#sqtab4-sin(t/4+3.141*1.5)*16-16 do
  rect(sqtab4[i][1],(sqtab1[i][2]-t*16)%160-20,10,10,4)
 end

 vbank(1)
 for i=t%2,32640,1.9 do poke4(i,i/4e8+t%1) end


end