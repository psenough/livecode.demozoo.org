-- mt here
-- back to fft shenanigans
-- then maybe twisty donuts

-- greets to alia, aldroidia, ferris
-- gasman, hoffman, jtruk, and you!

m=math
s=m.sin
c=m.cos
fc={}
fm={}
fn={}
fh={}
fs={}
fa={}

function BOOT()
 for i=0,255 do
  fc[i]=0
  fm[i]=0
  fn[i]=0
  fh[i]=0
  fs[i]=0
  fa[i]=0
 end
end

function BDR(l)
 vbank(0)
 if l == 0 then
 for i=1,15 do
  poke(0x3fc0+i*3, (i*15+t*.3)%255)
  poke(0x3fc0+i*3+1, (i*15+t*.5+60)%255)
  poke(0x3fc0+i*3+2, (i*15+t*.7+120)%255)
 end
 end
end

function TIC()t=time()/100
 cls()
 
 for i=0,255 do
  fc[i] = fft(i)*.1
  if fc[i] > fm[i] then fm[i] = fc[i] end
  fn[i] = fc[i]/fm[i]
  fa[i] = fa[i] + fc[i]
  fh[i] = fh[i]*.95 + fn[i]*.05
  bi = m.max(0,i-5)
  ei = m.min(255,i+5)
  fs[i]=0
  for i = bi,ei do
   fs[i] = fs[i]+fh[i]*.1
  end
 end

 vbank(0)
 cls()
 --[[
 it=t%50
 dt=it//25
 it=it/25
 it=it-0.5
 it=it*128
 if dt < 1 then
  poke(0x3ffa,128+it)
  poke(0x3ff9,0)
 else
  poke(0x3ffa,0)
  poke(0x3ff9,128+it)
 end
 --]]
 for i=0,239 do
  line(i,10,i,10-fc[i]*100,2)
  print("fft current * 100",0,12,2,true,1,true)

  line(i,36,i,36-fm[i]*100,4)
  print("fft max * 100",0,38,4,true,1,true)

  line(i,62,i,62-fn[i]*10,6)
  print("fft normalized * 10",0,64,6,true,1,true)

  line(i,88,i,88-fh[i]*10,8)
  print("fft history * 10",0,90,8,true,1,true)

  line(i,114,i,114-fs[i]*10,10)
  print("fft smooth * 10",0,116,10,true,1,true)


 end
 
 vbank(1)
 cls(0)
 
 for i=0,255,.5 do
  cx=160
  cy=68
  r = 50
  a = i/255 * m.pi * 2 + fa[0]*10
  
  
  mx = r * s(a)  
  my = r * c(a)
  w = 5*(1+10*fs[i//1])
  
  ra = i/255+t/500
  x1= w*s(ra)
  y1= w*c(ra)
  x2= w*s(ra+m.pi/2)
  y2= w*c(ra+m.pi/2)
  x3= w*s(ra+m.pi)
  y3= w*c(ra+m.pi)
  x4= w*s(ra+m.pi/2+3)
  y4= w*c(ra+m.pi/2+3)

  segment2(x1,y1,x2,y2,r,a,12)
  segment2(x2,y2,x3,y3,r,a,13)
  segment2(x3,y3,x4,y4,r,a,14)
  segment2(x4,y4,x1,y1,r,a,15)
  
--[[  segment(x1,y1,x2,y2,mx,my,2)
  segment(x2,y2,x3,y3,mx,my,6)
  segment(x3,y3,x4,y4,mx,my,10)
  segment(x4,y4,x1,y1,mx,my,14)
  --]]
 end
end

function segment2(x1,y1,x2,y2,r,a,col)
 ix1= (r-x1) * s(a)
 iy1= (r+y1) * c(a)
 ix2= (r-x2) * s(a)
 iy2= (r+y2) * c(a)
 line(ix1+cx,iy1+cy,ix2+cx,iy2+cy,col)

 --[[ nope.
 if xa <= 0 and x1 < x2 then
  if ya <= 0 and y1 > y2 then
   ix1= (r-x1) * s(a)
   iy1= (r-y1) * c(a)
   ix2= (r-x2) * s(a)
   iy2= (r-y2) * c(a)
   line(ix1+cx,iy1+cy,ix2+cx,iy2+cy,col)
   
  elseif ya >= 0 and y1 < y2 then
   ix1= (r-x1) * s(a)
   iy1= (r-y1) * c(a)
   ix2= (r-x2) * s(a)
   iy2= (r-y2) * c(a)
   line(ix1+cx,iy1+cy,ix2+cx,iy2+cy,col)
   
  end
 elseif xa > 0 and x1 > x2 then
  if ya <= 0 and y1 > y2 then
   ix1= (r+x1) * s(a)
   iy1= (r+y1) * c(a)
   ix2= (r+x2) * s(a)
   iy2= (r+y2) * c(a)
   line(ix1+cx,iy1+cy,ix2+cx,iy2+cy,col)
   
  elseif ya >= 0 and y1 < y2 then
   ix1= (r+x1) * s(a)
   iy1= (r+y1) * c(a)
   ix2= (r+x2) * s(a)
   iy2= (r+y2) * c(a)
   line(ix1+cx,iy1+cy,ix2+cx,iy2+cy,col)
   
  end
 end--]]
end


function segment(x1,y1,x2,y2,mx,my,c)
 --hmmmmmmm
 if mx <= 0 and x1 < x2 then
  if my <= 0 and y1 < y2 then
   line(x1+cx+mx,y1+cy+my,x2+cx+mx,y2+cy+my,c)
  elseif my > 0 and y1 > y2 then
   line(x1+cx+mx,y1+cy+my,x2+cx+mx,y2+cy+my,c)
  end
 elseif mx > 0 and x1 > x2 then
  if my <= 0 and y1 < y2 then
   line(x1+cx+mx,y1+cy+my,x2+cx+mx,y2+cy+my,c)
  elseif my > 0 and y1 > y2 then
   line(x1+cx+mx,y1+cy+my,x2+cx+mx,y2+cy+my,c)
  end
 end
   return
end

function fftcirc()
 for i=0,255,.1 do
  cx=120
  cy=68
  r = 50
  a = i/255 * m.pi * 2
  
  ix = r * s(a)  
  iy = r * c(a)  
  ox = r*(1+2*fs[i//1]) * s(a)  
  oy = r*(1+2*fs[i//1]) * c(a)  
  line(ix+cx,iy+cy,ox+cx,oy+cy,13)
 end
end
-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

