-- gasman is here!
-- greetings to pumpuli, g33kou,
-- boris, canmom, marex, iv
-- and aldroid!

-- was going to try raytracing some
-- spheres, but that gets very mathy
-- so let's see how this goes
sin=math.sin
cos=math.cos

sz=31

img={}
for y=0,sz do
 img[y]={}
 for x=0,sz do
  img[y][x]=0
 end
end

traillen=100
trail={}
for i=0,traillen-1 do
 trail[i]={-1,-1}
end
trailpos=0

snx=0
sny=0
sndx=1
sndy=0


fruitx=-1
fruity=-1
function setfruit()
 if fruity ~= -1 then
  for y=0,3 do
   for x=0,3 do
    img[(fruity+y)&sz][(fruitx+x)&sz]=0
   end
  end
 end
 fruitx=math.random(0,sz)
 fruity=math.random(0,sz)
 for y=0,3 do
  for x=0,3 do
   img[(fruity+y)&sz][(fruitx+x)&sz]=2
  end
 end
end

setfruit()

function TIC()
 cls(0)
 tm=time()
 x0=8*sin(tm/8234)
 y0=0 -- math.sin(tm/2345)-.5
 z0=8*sin(tm/8456)
 ry=tm/1357
 rx=sin(tm/1313)/2+0.4
 
 snx=(snx+sndx)&sz
 sny=(sny+sndy)&sz
 if math.random(0,10)==0 then
  if sndx==0 then
   sndx=math.random(0,1)*2-1
   sndy=0
  else
   sndx=0
   sndy=math.random(0,1)*2-1   
  end
 end
 
 if (
  snx==fruitx
  or snx==(fruitx+1)&sz
  or snx==(fruitx+2)&sz
  or snx==(fruitx+3)&sz
 ) and (
  sny==fruity
  or sny==(fruity+1)&sz
  or sny==(fruity+2)&sz
  or sny==(fruity+3)&sz
 ) then
  setfruit()
 end

 tail=trail[trailpos]
 if tail[2] ~= -1 then
  img[tail[2]][tail[1]]=0
 end
 trail[trailpos]={snx,sny}
 img[sny][snx]=5
 trailpos=(trailpos+1)%traillen
 
 fwdx0=0
 fwdy0=0
 fwdz0=1
 
 dnx0=0
 dny0=1
 dnz0=0
 
 rtx0=1
 rty0=0
 rtz0=0

 fwdx1=fwdx0
 fwdy1=fwdy0*cos(rx)+fwdz0*sin(rx)
 fwdz1=fwdz0*cos(rx)-fwdy0*sin(rx)
 dnx1=dnx0
 dny1=dny0*cos(rx)+dnz0*sin(rx)
 dnz1=dnz0*cos(rx)-dny0*sin(rx)
 rtx1=rtx0
 rty1=rty0*cos(rx)+rtz0*sin(rx)
 rtz1=rtz0*cos(rx)-rty0*sin(rx)

 fwdx=fwdx1*cos(ry)+fwdz1*sin(ry)
 fwdy=fwdy1
 fwdz=fwdz1*cos(ry)-fwdx1*sin(ry)
 dnx=dnx1*cos(ry)+dnz1*sin(ry)
 dny=dny1
 dnz=dnz1*cos(ry)-dnx1*sin(ry)
 rtx=rtx1*cos(ry)+rtz1*sin(ry)
 rty=rty1
 rtz=rtz1*cos(ry)-rtx1*sin(ry)

 for sy=0,135 do
  for sx=0,239 do
   y=sy-67.5
   x=sx-119.5
   
   vx=fwdx+(x/120)*rtx+(y/120)*dnx
   vy=fwdy+(x/120)*rty+(y/120)*dny
   vz=fwdz+(x/120)*rtz+(y/120)*dnz

   t=(1-y0)/vy
   if t<0 then
    t=-t
   end
   if t>10 then
    pix(sx,sy,0)
   else
    tx=(t*vx+x0)
    tz=(t*vz+z0)
    txm=((tx/2)%1)*(sz+1)//1
    tzm=((tz/2)%1)*(sz+1)//1
    clr=img[tzm][txm]
    if clr ~= 0 then
     pix(sx,sy,clr)
    else
     pix(sx,sy,(tx//1%2)~(tz//1%2))
    end
   end
  end
 end
end
