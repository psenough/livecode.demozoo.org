-- hello from gasman!
-- shoutouts to aldroid, alia,
-- mantratronic, jtruk and ferris!

-- sooo... in the absence of any ideas
-- I'm going to have another go at
-- doughnuts like last time and see
-- if I come up with anything different
-- (plus I have a whole hour this time)

vertices={}
vcount=0
faces={}
fcount=0
bigr=1
smallr=0.4
jcount=40
icount=10

for j=0,jcount-1 do
 b=j*math.pi*2/jcount
 for i=0,icount-1 do
  a=i*math.pi*2/icount
  vcount=vcount+1
  x0=(bigr+smallr*math.cos(a))
  vertices[vcount]={
   math.cos(b)*x0,
   smallr*math.sin(a),
   math.sin(b)*x0,
  }
  fcount=fcount+1
  faces[fcount]={
   i+j*icount+1,
   (i+1)%icount+j*icount+1,
   i+((j+1)%jcount)*icount+1,
  }
  fcount=fcount+1
  faces[fcount]={
   (i+1)%icount+j*icount+1,
   (i+1)%icount+((j+1)%jcount)*icount+1,
   i+((j+1)%jcount)*icount+1,
  }
 end
end

edges={}
for i=1,20 do
 edges[i]=math.random(10,30)
end

function TIC()
 cls()
 t=time()

 for i=0,15 do
  h=(t/4000+i/16)%3
  if h<1 then
   r=1-(h%1)
   g=h%1
   b=0
  elseif h<2 then
   r=0
   g=1-(h%1)
   b=h%1
  else
   r=h%1
   g=0
   b=1-(h%1)
  end
  poke(16320+i*3,i*16*math.sqrt(r))
  poke(16321+i*3,i*16*math.sqrt(g))
  poke(16322+i*3,i*16*math.sqrt(b))
 end

 ra=t/534
 rb=t/645
 rc=t/756
 
 cra=math.cos(ra)
 sra=math.sin(ra)
 crb=math.cos(rb)
 srb=math.sin(rb)
 crc=math.cos(rc)
 src=math.sin(rc)

 vt={}
 for i=1,vcount do
  v0=vertices[i]
  v1={
   v0[1]*cra+v0[3]*sra,
   v0[2],
   v0[3]*cra-v0[1]*sra,
  }
  v2={
   v1[1],
   v1[2]*crb+v1[3]*srb,
   v1[3]*crb-v1[2]*srb,
  }
  v3={
   v2[1]*crc+v2[2]*src,
   v2[2]*crc-v2[1]*src,
   v2[3],
  }
  v4={
   -- will it all screw up
   -- if I try to add some perspective?
   -- not what I was going for
   -- but I kinda like it :-)
   v3[1]*60/(1+v3[3])+120,
   v3[2]*60/(1+v3[3])+68,
   v3[3]
  }
  vt[i]=v4
 end
 ft={}
 for i=1,fcount do
  f=faces[i]
  v1=vt[f[1]]
  v2=vt[f[2]]
  v3=vt[f[3]]
  ft[i]={
   v1[1],v1[2],v1[3],
   v2[1],v2[2],v2[3],
   v3[1],v3[2],v3[3],
  }
 end
 table.sort(ft,
  -- dammit it's a comparison function
  -- why does lua have to be so annoying
  function(f1,f2)
   return (
    math.max(f1[3],f1[6],f1[9])
    < math.max(f2[3],f2[6],f2[9])
   )
  end
 )
 for i=1,fcount do
  f=ft[i]
  clr=f[3]*5+8
  tri(
   f[1],f[2],
   f[4],f[5],
   f[7],f[8],
   clr)
 end
 -- just some design overlay thing I guess
 for y=1,20 do
  circ(0,y*16-8,edges[y],0)
  circ(0,y*16-8,edges[y]-4,4)
  circ(240,y*16-8,edges[21-y],0)
  circ(240,y*16-8,edges[21-y]-4,4)
 end
end
