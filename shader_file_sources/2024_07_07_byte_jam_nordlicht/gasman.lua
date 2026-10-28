-- hello from gasman!!!

lifegrid={}

function newlife()
 for y=0,15 do
  lifegrid[y]={}
  for x=0,15 do
   lifegrid[y][x]=math.random(0,1)
  end
 end
end

newlife()

function lifegen()
 lifegrid2={}
 for y=0,15 do
  lifegrid2[y]={}
  for x=0,15 do
   nbrs=(
    lifegrid[(y+15)%16][(x+15)%16]
    +lifegrid[(y+15)%16][x]
    +lifegrid[(y+15)%16][(x+1)%16]
    +lifegrid[y][(x+15)%16]
    +lifegrid[y][(x+1)%16]
    +lifegrid[(y+1)%16][(x+15)%16]
    +lifegrid[(y+1)%16][x]
    +lifegrid[(y+1)%16][(x+1)%16]
   )
   if nbrs<2 or nbrs>3 then
    lifegrid2[y][x]=0
   elseif nbrs==2 then
    lifegrid2[y][x]=lifegrid[y][x]
   else
    lifegrid2[y][x]=1
   end
  end
 end
 lifegrid=lifegrid2
end

function circl(x,y)
 if (x%1-0.5)^2+(y%1-0.5)^2>0.2 then
  return 0
 else
  return ((x//1)~(y//1))%16
 end
end

function oh(x,y)
 local r=(x%1-0.5)^2+(y%1-0.5)^2
 if r>0.2 or r<0.1 then
  return 0
 else
  return ((x//1)~(y//1))%16
 end
end

function ex(x,y)
 local x1=x%1
 local y1=y%1
 if x1<0.05 or y1<0.05 or x1>0.95 or y1>0.95 then
  return 0
 end
 local rx=2*math.abs(x1-0.5)
 local ry=2*math.abs(y1-0.5)
 if rx>0.25 and ry>0.25 then
  return 0
 else
  return ((x//1)~(y//1))%16
 end
end

function wave(x,y)
 local x1=x%1
 local y1=y%1
 local sx=0.5+vol*1.5*math.sin(x1*16)
 if x1<0.1 or y1>sx+0.1 or y1<sx-0.1 then
  return 0
 else
  return ((x//1)~(y//1))%16
 end
end

function waveflip(x,y)
 local x1=y%1
 local y1=x%1
 local sx=0.5+vol*1.5*math.sin(x1*16)
 if x1<0.1 or y1>sx+0.1 or y1<sx-0.1 then
  return 0
 else
  return ((x//1)~(y//1))%16
 end
end

function life(x,y)
 local x1=y%1
 local y1=x%1
 if x1<0.2 or y1<0.2 then
  return 0
 else
  return lifegrid[y//1%16][x//1%16]*16
 end
end

invgrid={
{
 {0,0,1,0,0,0,0,0,1,0,0,0,0,0},
 {0,0,0,1,0,0,0,1,0,0,0,0,0,0},
 {0,0,1,1,1,1,1,1,1,0,0,0,0,0},
 {0,1,1,0,1,1,1,0,1,1,0,0,0,0},
 {1,1,1,1,1,1,1,1,1,1,1,0,0,0},
 {1,0,1,1,1,1,1,1,1,0,1,0,0,0},
 {1,0,1,0,0,0,0,0,1,0,1,0,0,0},
 {0,0,0,1,1,0,1,1,0,0,0,0,0,0},
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0},
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0},
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0},
},
{
 {0,0,1,0,0,0,0,0,1,0,0,0,0,0},
 {1,0,0,1,0,0,0,1,0,0,1,0,0,0},
 {1,0,1,1,1,1,1,1,1,0,1,0,0,0},
 {1,1,1,0,1,1,1,0,1,1,1,0,0,0},
 {0,1,1,1,1,1,1,1,1,1,0,0,0,0},
 {0,0,1,1,1,1,1,1,1,0,0,0,0,0},
 {0,0,1,0,0,0,0,0,1,0,0,0,0,0},
 {0,1,0,0,0,0,0,0,0,1,0,0,0,0},
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0},
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0},
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0},
}}

function invader(x,y)
 invy=(y*2//11)
 invx=(x*2//14)
 return invgrid[invframe][y*2//1%11+1][x*2//1%14+1]*((invx+invy)%8+4)
end

shaders={}
shaders[0]=ex
shaders[1]=invader
shaders[2]=wave
shaders[3]=oh
shaders[4]=waveflip
shaders[5]=life
shadercount=6

maxvol=0
vol=1

lastgen=0

invframe=1

verts={
 {-1,-1,-1},
 {1,-1,-1},
 {1,-1,1},
 {-1,-1,1},
 {-1,1,-1},
 {1,1,-1},
 {1,1,1},
 {-1,1,1},
}

function edge(v1,v2,edgecol)
 sc=12--+200*fft(0)
 line(
  v1[1]*sc+25,v1[2]*sc+110,
  v2[1]*sc+25,v2[2]*sc+110,
  edgecol
 )
end

function koob(t,edgecol)
 ry=t/878
 rx=t/979
 vs3={}
 for i=1,8 do
  v1=verts[i]
  v2={
   v1[1]*math.cos(ry)+v1[3]*math.sin(ry),
   v1[2],
   v1[3]*math.cos(ry)-v1[1]*math.sin(ry)
  }
  vs3[i]={
   v2[1],
   v2[2]*math.cos(rx)-v2[3]*math.sin(rx),
   v2[3]*math.cos(rx)+v2[2]*math.sin(rx),
  }
 end
 edge(vs3[1],vs3[2],edgecol)
 edge(vs3[2],vs3[3],edgecol)
 edge(vs3[3],vs3[4],edgecol)
 edge(vs3[4],vs3[1],edgecol)
 edge(vs3[5],vs3[6],edgecol)
 edge(vs3[6],vs3[7],edgecol)
 edge(vs3[7],vs3[8],edgecol)
 edge(vs3[8],vs3[5],edgecol)
 edge(vs3[1],vs3[5],edgecol)
 edge(vs3[2],vs3[6],edgecol)
 edge(vs3[3],vs3[7],edgecol)
 edge(vs3[4],vs3[8],edgecol)
end

function TIC()
 t=time()
 vol1=fft(0)
 if vol1>maxvol then
  maxvol=vol1
 end
 vol=vol1/maxvol
 
 invframe=(t//400)%2+1

 gen=t//200
 if gen>lastgen then
  lastgen=gen
  lifegen()
 end
 if gen%50==0 then
  newlife()
 end

 h=(t/1567)%(2*math.pi)
 hr=0.8+0.5*math.sin(h)
 hg=0.8+0.5*math.sin(h+2*math.pi/3)
 hb=0.8+0.5*math.sin(h+4*math.pi/3)
 for i=0,15 do
  poke(16320+i*3,math.min(255,i*16*hr))
  poke(16321+i*3,math.min(255,i*16*hg))
  poke(16322+i*3,math.min(255,i*16*hb))
 end

 r=(t/2345)
 k=1-(t/1000%1)
 p=t//1000

 z=2^k
 dx=30*math.sin(t/1343)
 dy=30*math.sin(t/1545)

 for sy=0,135 do
  for sx=0,239 do
    x0=(sx-120+dx)
    y0=(sy-68+dy)
    x1=x0*z/(1+y0/800)
    y1=y0*z/(1+x0/800)
    x=x1*math.cos(r)+y1*math.sin(r)
    y=y1*math.cos(r)-x1*math.sin(r)
    v1=shaders[p%shadercount](x/16,y/16)*k
    v2=shaders[(p+1)%shadercount](x/64,y/64)
    v3=shaders[(p+2)%shadercount](x/256,y/256)*(1-k)
    v=(v1+v2+v3)%16*0.9

    vigr=(sx-120)^2+(sy-68)^2
    vigv=math.cos(vigr/12000)

    
    if sx%2==0 and sy%2==0 then
     pix(sx,sy,(v+0)*vigv)
    elseif sx%2==0 then
     pix(sx,sy,(v+0.5)*vigv)
    elseif sy%2==0 then
     pix(sx,sy,(v+0.25)*vigv)
    else
     pix(sx,sy,(v+0.75)*vigv)
    end
  end
 end

 koob(t-450,2)
 koob(t-300,4)
 koob(t-150,6)
 koob(t,8)
 
 for iy=1,11 do
  for ix=1,14 do
   if invgrid[invframe][iy][ix]>0 then
    rect(195+ix*3,10+iy*3,2,2,6+math.random(6))
   end
  end
 end

end
