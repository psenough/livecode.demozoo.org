s=math.sin
c=math.cos
function noise(x,y,t)
 return s(x*3+t*3)*s(y*5+t*1+s(x*5)*10)
end
function fbm(x,y,t)
 acc=noise(x,y,t)
 amp=2
 sc=1.3
 --for i=0,0 do
  --th=0.1*i*t
  --x=x*c(th)-y*s(th)
  --y=x*s(th)-y*c(th)
  --x=x*sc
  --y=y*sc
  --acc=acc+noise(x,y,t)*amp
  --amp=amp*0.9
 --end
 return acc
end
t=0
vel=0
function TIC()
 ff=fft(20,40)
 --ff=math.min(ff,1)
 --ff=math.pow(ff,10)
 --vel=math.max(vel,ff)
 --vel=vel*0.6
 t=t+1/20.0+vel*0.1
 for j=0,239 do
  for i=0,135 do
   if math.random(0,1000) > 600 then
   x=j/239.0*1
   y=i/135.0*3
   x=x+x*ff*0.1
   lt=t+x+3*y+noise(x,y,t)
   lt=lt+c(lt)
   col=fbm(x,y,lt)
   pix(j,i,(col*0.5)%5+lt*0.3)
   end
  end
 end
end
