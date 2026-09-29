-- alice here
--
-- greets:
--   aldroid,
--   jtruk,
--   gasman,
--   nusan
--
--   and the entire FieldFX discord
--
-- see you at EMF!

-------------------

-- pico8 the colors
pico8="0000001D2B537E2553008751AB52365F574FC2C3C7FFF1E8FF004DFFA300FFEC2700E43629ADFF83769CFF77A8FFCCAA"

function palit(p)
 for i=1,#p,6 do
  for j=0,2 do
   poke(0x3fc0+((i//6)*3)+j,
    tonumber(p:sub(i+j*2,i+j*2+1),16))
  end
 end
end

palit(pico8)

------------

pi,sin,cos=math.pi,math.sin,math.cos
PI=math.pi; TAU=PI*2

psin=function(a)
 return -math.sin(a*TAU)
end

pcos=function(a)
 return math.cos(a*TAU)
end

patan2=function(a,b)
 return (math.atan2(-a,-b)/PI+1)/2
end

sqrt=function(a)
 return math.sqrt(a)
end

min,max,abs=math.min,math.max,math.abs
floor,ceil=math.floor,math.ceil

function ptime()
 return time()/1000
end

SCRW,SCRH,SCRWH,SCRHH=240,136,120,68
MIDX=120
MIDY=68

sub=string.sub

---

t=0
fwd=true
m="hello outline"
f={}
fs={}
c=0
tt=0
function TIC()
 tt=tt+0.03
 if fwd then
  t=t+1
 else
  t=t-1
 end
 cls()
 for i=0,239 do
  f[i]=fft(i)
 	fs[i]=ffts(i)
 end
 
 for i=0,239 do
 line(i,136,i*fft(i),10, i%15)
	end
 len=print(m,0,-1000)
 print(m, t, 0, t//10%15)
 if t == 236-len then 
  fwd=false
 end
 
 if t == 0 then
  fwd=true
 end

	for j=1,19 do
	 if fft(j) > 0.3 then
		 --rect(150, 20+j*10, j*10, 4, j%15)
   print("BEAT", 218, j*7, j%15)
  end
 end
 
 bx=150
 by=40
 bs=10
 cnt=8
 line(bx+10,by+24,bx+18,by+70,3)


 --elli(bx+bs*2*psin(tt),by+bs*pcos(tt),bs,bs,8)
 --elli(bx+bs*2*psin(tt),by+20+bs*-pcos(tt),bs,bs,8)
 --elli(bx+20*2*psin(tt),by+bs*pcos(tt),bs,bs,8)
 --elli(bx+20*2*psin(tt),by+20+bs*-pcos(tt),bs,bs,8)

 elli(bx,by,bs,bs,8)
 elli(bx,by+20,bs,bs,8)
 elli(bx+20,by,bs,bs,8)
 elli(bx+20,by+20,bs,bs,8)

 elli(bx+10,by+10,cnt,cnt,9)
 
 print("i love pjanoo!!",30,30,7)
 
 --fftss=fftssum(0,239)
 --rect(SCRW-fftss,50,fftss,4,8)
end
