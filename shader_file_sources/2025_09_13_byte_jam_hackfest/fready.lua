-- Hackfest 2025, livecoding
-- FREADY, uses fft

sin=math.sin
cos=math.cos
rnd=math.random
pi=math.pi
t=0
cls()
function TIC()

  for k=1,10000 do
    x=rnd(240)-1
    y=rnd(136)-1
    pix(x,y,0)
  end

  mx=sin(t*4)*120
  
  tpi=2*pi
  step=2*pi/10

  f=fft(1)*40

 fx=fft(1)*20
 for i=1,10+fx do  
  d1=40+sin(t*2)*(10+f)-(i*30)
  d2=50+sin(t*2)*(10+f)-(i*30)
  t2=t+i
  for s=0,tpi,step do
   x1=120+sin(s+t2)*d1
   y1=68+cos(s+t2)*d1
   
   s2=(s-step/2)%tpi
   x2=120+sin(s2+t2)*d1
   y2=68+cos(s2+t2)*d1
   
   s3=(s-step)%tpi
   x3=120+sin(s3+t2)*d2
   y3=68+cos(s3+t2)*d2
   
   x4=120+sin(s3+t2)*d1
   y4=68+cos(s3+t2)*d1
   
   line(x1,y1,x2,y2,i)
   line(x2,y2,x3,y3,i)
   line(x3,y3,x4,y4,i)

  end
 end
  f2=fft(1)*20
  f3=fft(1)*100
  print("hack",15-mx,20+f2,2+f3%7,true,4)

  print("fest",150+mx,80-f2,2+f3%7,true,4)

  t=t-0.01
  

end
