sin=math.sin
cos=math.cos
abs=math.abs
pi=math.pi
tau=pi*2

t=0 t2=0
cls()

f={}
fm={}

function TIC()
 for i=1,256 do
  f[i]=fft(i-1)
  fm[i]=math.max(fm[i] or 0,f[i])
 end
 
 for i=0,255 do
  local a=i/256
  local s=(f[i+1]/fm[i+1])
  local q=s
  s=40+s*40
  local x0=sin(a*tau)*s+120
  local y0=cos(a*tau)*s+68
  local x1=sin((i+1)*tau/256)*s+120
  local y1=cos((i+1)*tau/256)*s+68
  local q=(t//4)*2%16*pi
  x0=x0+sin(t+i/q)*10
  x1=x1+sin(t+(i+1)/10)*10
  y0=y0+cos(t+i/q)*10
  y1=y1+cos(t+(i+1)/10)*10
  line(
   x0,y0,x1,y1,
   q*15)
 end
 
 circb(math.random()*240,
  math.random()*135,
  math.random()*10,
  15)
 
 vbank(1)
 ttri(
  0,0,
  480,0,
  0,272,
  
  sin(t/3.24)*2,sin(t/2.536)*4,
  480+sin(t/3.563)*2,sin(t/4.567)*4,
  sin(t/1.47)*2,272+sin(t/5.53)*4,
  2
 )
 
 local str={
  "=^^=",
  "greets to",
  "aldroid",
  "synesthesia",
  "jtruk",
  "mantratronic",
  "tobach",
  "and you!",
  "trans rights",
  "visit nova",
  "pet cats",
  "xx alia"
 }
 if t//10%2==1 then
  local s=str[t//20%#str+1]
  local w=#s*6
  local si=240/w
  local h=si*5
  local y=135-h-abs(sin(t2/4))*50
  print(s,5,y,0,0,si)
  print(s,6,y-1,12,0,si)
 end
 
 memcpy(0x4000,0,16320)
 cls()
 vbank(0)
 memcpy(0,0x4000,16320)
 
 
 local bt=0
 for i=1,10 do
  bt=bt+f[i]
 end
 t=t+bt
 t2=t2+.4
end

function SCN(y)
 for x=0,239 do
  pix(x,y,
   (math.max(0,pix(x,y)-(x//2%2+y//2%2+x%2+y%2)%2)+
   pix(x+1,y)+pix(x,y+1))/3
   +math.random()*(x%2+y%2)*.7
   )
 end
 --poke(0x3FF9,
  --(f[y+1]/fm[y+1])*10
 --)
 --poke(0x3FFA,
  --(f[y+1]/fm[y+1])*10
 --)
end
