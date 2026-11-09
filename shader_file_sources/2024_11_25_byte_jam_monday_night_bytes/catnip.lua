sin=math.sin
cos=math.cos
abs=math.abs
min=math.min
max=math.max
pi=math.pi
rand=math.random

t=0

poke(16320+6*3+0,255)
poke(16320+6*3+1,128)
poke(16320+6*3+2,128)

b={} bm={}
for i=1,10 do b[i]=0 bm[i]=1e-5 end

function flwr()
 for f=1,10 do
  local x=(sin(t/20+f)^7+sin(t/20+f)^3)*10
  local y=10+f*10
  line(x+40,y,40-x-5,y+130,1)
  line(200-x,y,x+200-5,y+130,1)
  local r=15+b[((f+t//15)%10)+1]*10
 	for i=0,5 do
 		circ(x+40,y,r-i*2,i%2*(i+t/15))
 		circ(200-x,y,r-i*2,i%2*(i+t/15))
  end
 end
end

function mix(a,b,t)
 return b*t+a*(1-t)
end

function mix2(a,b,t)
	return {mix(a[1],b[1],t),mix(a[2],b[2].t)}
end

function skelly()
 local lf={90,130}
 local rf={150,130}
 local hp={
  sin(t/10)*20+120,
  -abs(cos(t/10)*10)+90
 }
 local lk={
  sin(t/10)*10+95,
  -abs(cos(t/10)*5)+105
 }
 local rk={
  lk[1]+50,
  lk[2]
 }
 --f
 clip(0,0,240,lf[2])
 circ(lf[1],lf[2],7,3)
 circ(rf[1],rf[2],7,3)
 clip()
 
 --l
 for i=0,6 do
  local t=i/6
  circ(
   mix(lf[1],lk[1],t),
   mix(lf[2]-6,lk[2],t),
   4,3+i%2)
  circ(
   mix(rf[1],rk[1],t),
   mix(rf[2]-6,rk[2],t),
   4,3+i%2)
  circ(
   mix(lk[1],hp[1],t),
   mix(lk[2],hp[2],t),
   5,3+i%2)
  circ(
   mix(rk[1],hp[1],t),
   mix(rk[2],hp[2],t),
   5,3+i%2)
 end
 
 local cp={} 
 for i=0,8 do
  local s=i/8
  cp[1]=hp[1]+sin(t/20+i/4)*20*s
  cp[2]=hp[2]-i*5
  elli(
   cp[1],
   cp[2],
   10+i,8,
   3+i%2)
 end
 
 local a=sin(t/10)-.5
 local le={
  cp[1]+sin(a)*15-20,
  cp[2]+cos(a)*15+10}
 local re={
  cp[1]+sin(-a)*15+20,
  cp[2]+cos(-a)*15+10}
  
 a=sin(t/10)+1
 local lw={
  le[1]+sin(-a)*15,
  le[2]+cos(-a)*15+10}
 local rw={
  re[1]+sin(a)*15,
  re[2]+cos(a)*15+10}
  
 for i=0,6 do
  local t=i/6
  circ(
   mix(cp[1]-15,le[1],t),
   mix(cp[2],le[2],t),
   5,3+i%2)
  circ(
   mix(cp[1]+15,re[1],t),
   mix(cp[2],re[2],t),
   5,3+i%2)
  circ(
   mix(le[1],lw[1],t),
   mix(le[2],lw[2],t),
   4,3+i%2)
  circ(
   mix(re[1],rw[1],t),
   mix(re[2],rw[2],t),
   4,3+i%2)
 end
 
 circ(lw[1]-5,lw[2],5,4)
 circ(lw[1]-8,lw[2],1,6)
 circ(lw[1]-7,lw[2]+3,1,6)
 circ(lw[1]-7,lw[2]-3,1,6)
 circ(rw[1]+5,lw[2],5,4)
 circ(rw[1]+8,lw[2],1,6)
 circ(rw[1]+7,lw[2]+3,1,6)
 circ(rw[1]+7,lw[2]-3,1,6)
 
 local hp={
  cp[1]-sin(t/20)^3*10,
  cp[2]-10-abs(cos(t/10))*5
 }
 elli(hp[1]-8,hp[2]-8,5,7,3)
 elli(hp[1]-8,hp[2]-8,5,7,3)
 elli(hp[1]-8,hp[2]-8,4,6,4)
 elli(hp[1]-8,hp[2]-8,4,6,4)
 elli(hp[1]+8,hp[2]-8,5,7,3)
 elli(hp[1]+8,hp[2]-8,5,7,3)
 elli(hp[1]+8,hp[2]-8,4,6,4)
 elli(hp[1]+8,hp[2]-8,4,6,4)
 elli(hp[1],hp[2],17,10,3)
 
 clip(hp[1]-8,hp[2],16,16)
 elli(hp[1],hp[2],8,5,12)
 elli(hp[1]-4,hp[2],4,1,3)
 elli(hp[1]+4,hp[2],4,1,3)
 clip()
 
 circ(hp[1]+7,hp[2]-4,3,12)
 circ(hp[1]-7,hp[2]-4,3,12)
 circ(hp[1]-7,hp[2]-4,1,0)
 circ(hp[1]+7,hp[2]-4,1,0)

end

cls(12)

function TIC()
 for i=1,#b do
  local v=fft(i*3,(i+1)*3)
  bm[i]=max(bm[i],v)
  b[i]=v/bm[i]
 end
 
 vbank(0)
 --if t/4%60<30 then
 	--memcpy(0,120,16200)
 --else
 	memcpy(0,1,16319)
 --end
 if t%8==0 then
	 for i=0,16320*2 do
	  poke4(i,peek4(i)+1)
	 end
 end
 --cls(12)
 skelly()
 
 vbank(1)
 cls() 
	
 flwr()
	
	t=t+1
end
