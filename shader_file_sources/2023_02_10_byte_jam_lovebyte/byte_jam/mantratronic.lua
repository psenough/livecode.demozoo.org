-- mt here
--     ^
-- gl tobach, visy, blossom

m=math
s=m.sin
c=m.cos
r=m.random
tau=m.pi*2

-- when life doesn t give you lemons
lemons={}
col={}
rd={}
np=20
nl=20
nc=5

magicy=4

ffth={}

function BOOT()
 for h=1,nc do
  for i=1,nl do
   local points={}
   local rands={}
   for j=1,np do
    points[j]=0
    rands[j]=r()*5
   end
   lemons[i]=points
   rd[i]=rands
  end
  col[h]=lemons
 end
 
 
 for h=1,nc do
  ffth[h]={}
  for i=1,nl do
   ffth[h][i]=0
  end
--  ffth[i]=fftl

 end
end

function clamp(x,a,b)
 return m.max(a,m.min(b,x))
end

lt=0
function TIC()t=time()

 vbank(1)
 cls()
 
 for i=0,15 do
  poke(0x3fc0+i*3,i*15)
  poke(0x3fc0+i*3+1,i*15)
  poke(0x3fc0+i*3+2,i*8)
 end

 
 if t-lt>40 then
 for h=1,nc do 
  for i=nl,2,-1 do
   ffth[h][i]=ffth[h][i-1]
  end
  ffth[h][1]=10*fft(h)
 end
 end

 t=t/1000
 for h=1,nc do 
  lemons={}
  for i=1,nl do
   local points={}
   for j=1,np do
    local a=j/np * tau
    d=(rd[i][j]+20+10*ffth[h][i])
    p={x=s(a+t)*d*s(i/nl*math.pi),
               y=(i-(nl/2))*magicy,
               z=c(a+t)*d*s(i/nl*math.pi)}
    a=t/4+h
    points[j]={x=p.x*s(a)-p.y*c(a),
               y=p.y*s(a)+p.x*c(a),
               z=p.z}
   end
   lemons[i]=points
  end
  col[h]=lemons
 end
  
 for h=1,nc do
--  lemons=col[h]
  for i=1,nl do
--   local points=lemons[i]
   for j=1,np-1 do
    sp = col[h][i][j]
    ep = col[h][i][j+1]
    
    sz=sp.z-100
    sx=120+sp.x*99/sz -140 +h*50
    sy=68+sp.y*99/sz  

    ez=ep.z-100
    ex=120+ep.x*99/ez -140 +h*50
    ey=68+ep.y*99/ez

    if(ez+sz)>-200 then
   
     line(sx,sy,ex,ey,clamp(sz+90,0,15))
    end
   end
    sp = col[h][i][np]
    ep = col[h][i][1]
  
   sz=sp.z-100
   sx=120+sp.x*99/sz -140 +h*50
   sy=68+sp.y*99/sz 

   ez=ep.z-100
   ex=120+ep.x*99/ez -140 +h*50
   ey=68+ep.y*99/ez

   line(sx,sy,ex,ey,clamp(sz+90,0,15))
  end
 end

 vbank(0)
 cls()
 circ(40,40,40,15)
 tt=t%4
 if tt <1 then
 len=print("LOVE",-100,60,12,true,3)
 print("LOVE",42-len/2,20,12,true,3)
 len=print("BYTE",-100,60,12,true,3)
 print("BYTE",42-len/2,43,12,true,3)
 elseif tt <2 then
 len=print("20",-100,60,12,true,4)
 print("20",42-len/2,18,12,true,4)
 len=print("23",-100,60,12,true,4)
 print("23",42-len/2,43,12,true,4)
 elseif tt <3 then
 len=print("MT",-100,60,12,true,6)
 print("MT",44-len/2,25,12,true,6)
 else
 len=print("LOVE",-100,60,12,true,3)
 print("LOVE",42-len/2,20,12,true,3)
 len=print("BY TEA",-100,60,12,true,2)
 print("BY TEA",42-len/2,43,12,true,2)
 end
 
 memcpy(0x4000,0,40*240)
 cls()
 
 size=80+60*fft(1)
 for x=0,size do
  for y=0,size do
   px=x-size/2
   py=y-size/2
   
   a=m.atan2(px,py)
   d=(px^2+py^2)^.5
   d=d*(d/(size/2))^fft(1)
  
   ix=d*s(a)+40
   iy=d*c(a)+40
   pix(px+120,py+68,peek4(0x8000+ix+iy//1*240))
  end
 end
 
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

