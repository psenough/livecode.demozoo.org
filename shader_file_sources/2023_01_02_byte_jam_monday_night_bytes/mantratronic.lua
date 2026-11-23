-- hello all! mt here
--                        ^
-- hf+gl to alia, kii, & tobach
r=math.random
s=math.sin
fto={}
for i=0,255 do
fto[i]=0
end

p={}
np=48
for i=0,np do
p[i]={x=r(240.0),y=r(136.0),sx=r(10.0)-5,sy=r(10.0)-5}
end

tc=0

function SCN(l)
 for i=0,15 do
  poke(0x3fc0+i*3, 255-15*i)
  poke(0x3fc0+i*3+1, math.max(0,math.min(255,255-8*i-l)))
  poke(0x3fc0+i*3+2, math.max(0,math.min(255,255-26*i)))
 end
end

t=0.0
function TIC()
t=t+1--fft(1)*5.0 -- nm
n = 255//np
for i=0,255 do
 ftoa = 0
 for j=0,n do
  ftoa=ftoa+fft(i/n+j)/n
 end
 fto[i]=(fto[i]+ftoa)/2
end

for i=0,np do
 v=p[i]
 v.x=(v.x+v.sx/5*s(i/10+t/100))%240
 v.y=(v.y+v.sy/8*s(i/11+t/100))%136
 pix(v.x,v.y,fto[i]*500)
 
 for j=0,np do
  w=p[j]
  d=(v.x-w.x)^2 + (v.y-w.y)^2
  d=d^.5
  ft = fto[i] + fto[j]
  if d < ft * 250 and i ~= j then
   line(v.x,v.y,w.x,w.y,ft*100)
   for l=0,np do
    z=p[l]   
    d=(v.x-z.x)^2 + (v.y-z.y)^2
    d=d^.5
    ft = fto[i] + fto[j] + fto[l]
    if d < ft * 125 and l ~= j and l ~= i then
     tri(v.x,v.y,w.x,w.y,z.x,z.y,ft*100)
     goto continue
    end
   end
  end
  
 end
 
 ::continue::
end

if t%4 < 1 then
 for i=0,239 do
  for j=0,135 do
   pix(i,j,math.max(0,pix(i,j)-1))
  end
 end
 
 if t%64<1 then
  tc=tc+1
  tc=tc%4  
 end
end



end

function OVR()
 if t%64<15 then
  if tc<1 then
   print("eat",112,64,15)
  elseif tc<2 then  
   print("sleep",108,64,15)
  elseif tc<3 then  
   print("livecode",102,64,15)
  elseif tc<4 then  
   print("repeat",106,64,15)
  else
  end
 end
end
