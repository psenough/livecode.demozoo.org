t=0
st=0
x=120 y=68
fma=0
fch=0

cls()

function fb()
 local p0={x=0,y=135}
 local p1={x=239,y=135}
 local p2={x=0,y=0}
 local p3={x=239,y=0}
 
 ttri(
  p0.x,p0.y,
  p1.x,p1.y,
  p2.x,p2.y,
  p1.x,p1.y,
  p0.x,p0.y,
  p3.x,p3.y,
  2)
 ttri(
  p1.x,p1.y,
  p2.x,p2.y,
  p3.x,p3.y,
  p0.x,p0.y,
  p3.x,p3.y,
  p2.x,p2.y,
  2)
end

function r2d(p,a)
 return {
  x=(math.cos(a)*p.x)+(math.sin(a)*-p.y),
  y=(math.cos(a)*p.y)+(math.sin(a)*p.x)
 }
end

function mix(a,b,t)
 return a*(1-t)+b*t
end

l0=0 l1=0 r0=0 r1=0 h=0

function TIC()
	local fc=0
	for i=0,15 do
	 fc=fc+fft(i)
	end
 fma=math.max(fma*.98,fc)
 if fc>fma*.9 and t-fch>20 then
  st=st+1
  fch=t
 end
 
 vbank(1)
 memcpy(0,0x4000,16320)
 
 x=(x+(st//8%3)-1+((st+2)//4%3)-1)%240
 y=(y+((st+4)//8%3)-1+(st//4%3)-1)%136
 
 print("=^^=",x-60,y-10,15,0,6)
 print("=^^=",240-x-60,136-y-10,15,0,6)
 
 vbank(0)
 fb()
 
 for y=0,135 do
  for x=0,239 do
   pix(x,y,pix(x,y)-(x+y)%2*(t%3==0 and .9 or 0))
  end
 end
 
 if t%2==0 then
 	memcpy(0x4000,120,16200)
 else 
 	memcpy(0x4000,0,16320) 
 end
 
 vbank(1)
 local x=-t%240
 local x1=x
 local y=135
 
 for i=0,10 do
  elli(x,y,20,10,13+i%2)
  y=y-6
  x=x+math.sin(y/10+t/10)*5
 end
 
 local sl={x=x-12,y=y+8}
 local sr={x=x+12,y=y+1}
 local el={x=-40,y=0}
 local er={x=40,y=0}
 
 l0=l0+0.05*(st//4%2*2-1)
 l1=l1+0.07*(st//2%2*2-1)
 r0=l0+0.04*((st+2)//4%2*2-1)
 r1=l1+0.06*((st+1)//2%2*2-1)
 
 el=r2d(el,math.sin(l0))
 el={x=el.x+sl.x,y=el.y+sl.y}
 er=r2d(er,math.sin(r0))
 er={x=er.x+sr.x,y=er.y+sr.y}
 
 hl={x=-30,y=0}
 hl=r2d(hl,math.sin(l1))
 hl={x=hl.x+el.x,y=hl.y+el.y}
 hr={x=30,y=0}
 hr=r2d(hr,math.sin(r1))
 hr={x=hr.x+er.x,y=hr.y+er.y}
 for i=0,10 do
  circ(
   mix(sl.x,el.x,i/10),
   mix(sl.y,el.y,i/10),
   5,
   13+i%2)
  circ(
   mix(el.x,hl.x,i/10),
   mix(el.y,hl.y,i/10),
   5,
   13+i%2)
  circ(
   mix(sr.x,er.x,i/10),
   mix(sr.y,er.y,i/10),
   5,
   13+i%2)
  circ(
   mix(er.x,hr.x,i/10),
   mix(er.y,hr.y,i/10),
   5,
   13+i%2)
 end
 
 h=h+(st//8%2*2-1)
 local bob=math.abs(h%30-15)-5
 elli(x,y-13+bob,18,12,15)
 elli(x,y-15+bob,18,12,13)
 
 print("=^^=",x-23,y-18+bob,15,0,2)
 print("=^^=",x-23,y-20+bob,12,0,2)
 
 -- Fire was added to tie in with the end of the mix...
 --for i=0,5 do
  --tri(
   --x+math.random()*14-7,135,
   --x+math.random()*14-7,135,
   --x+math.random()*14-7,135-math.random()*20,
   --3)
 --end
 
 t=t+1
end

function SCN(y)
 poke(0x3ff9,fft(y+t%136)*8+math.sin(y/20+t/20)*20)
end