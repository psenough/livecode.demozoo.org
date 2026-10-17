-- mantratronic here
-- phew, that was close
-- some trib+trig tonight
--  ^  greets to h0ffman, totetmatt,
-- tobach, alia, and suule!

m=math
s=m.sin
c=m.cos

ts={} -- x,y,d,s,a
nt=50

ffth={}
fftm={}

function rot(x,y,a)
return {x=x*s(a)-y*c(a), y=y*s(a)+x*c(a)}
end

function clamp(x,a,b)
return m.max(a,m.min(b,x))
end

function BOOT()
for i=0,255 do
ffth[i]=0
fftm[i]=0
end

for i=1,nt do
ts[i]={x=240*((i/nt)*2-1),y=0,d=10,s=10,a=0}
end


cls(15)
end
function BDR(y)
sr=s(t/10+y/300)
sg=s(t/10+y/200+m.pi*2/3)
sb=s(t/10+y/100+m.pi*4/3)
for i=0,15 do
vbank(0)
poke(0x3fc0+i*3, clamp(i*(24+8*sr),0,255))
poke(0x3fc0+i*3+1, clamp(i*(24+8*sg),0,255))
poke(0x3fc0+i*3+2, clamp(i*(24+8*sb),0,255))
vbank(1)
poke(0x3fc0+i*3, clamp(i*(24+8*sr),0,255))
poke(0x3fc0+i*3+1, clamp(i*(24+8*sg),0,255))
poke(0x3fc0+i*3+2, clamp(i*(24+8*sb),0,255))
end
vbank(0)end

function TIC()t=time()/300

for i=0,255 do
f=fft(i)
if f > fftm[i] then fftm[i] = f end
ffth[i]=ffth[i]*.9 + f/fftm[i]*.1

--ffth[i]=ffth[i]*.8+m.random()*.2
end

--cls(15)
memcpy(0,120,120*135)
x=(s(t*20)+1)*120
rect(x,0,2,135,15)

for i=0,100 do
x=240*m.random()
y=136*m.random()
circb(x,y,5*m.random(),pix(x,y))
end

for i=1,nt do

ts[i].s=ffth[i]*20
ts[i].a=t+i/nt*m.pi*2

a=s(i/nt*m.pi*2+t)
d=clamp(s(ts[i].s)*25+25,0,50)
r=rot(d,0,a)

r.x=ts[i].x+r.x
r.y=68+r.y+30*s(ffth[5]*i/20)

r1=rot(ts[i].s,0,a)
r2=rot(0,ts[i].s/2,a)
r3=rot(0,-ts[i].s/2,a)

trib(r1.x+r.x,r1.y+r.y,
	r2.x+r.x,r2.y+r.y,
	r3.x+r.x,r3.y+r.y,
	1+clamp(d/4,0,14))

-- HMMM. not doing what i want
	
end

vbank(1)
cls()
for x=0,240 do
for y=68,98 do
ny=(y+t*4)%136
vbank(0)
p=pix(x,ny)
vbank(1)
pix(x,ny,clamp(15-p,1,15))
end
end

len=print("mt",0,140,15)
print("mt",240-len,130,8)

end
