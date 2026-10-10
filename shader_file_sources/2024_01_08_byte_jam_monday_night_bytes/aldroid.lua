-- Hi! Can I play and host at the same
-- time? Hope so... Greets all, HNY
-- and glhf to mantra, catnip, and
-- HeNeArXn (welcome!)

-- hmm no idea what to do

C=math.cos
S=math.sin


for i=0,15 do
poke(0x3fc0+i*3,10+i*35)
poke(0x3fc1+i*3,10+i*35)
poke(0x3fc2+i*3,40+i*25)
end

function mba(a,ox,oy,c)

l=10
for i=0,5 do
 x1=-l
 x2=l
 y1=i-2
 y2=i-2
	line(
	  ox+C(a)*x1-S(a)*y1,
			oy+C(a)*y1+S(a)*x1,
			ox+C(a)*x2-S(a)*y2,
			oy+C(a)*y2+S(a)*x2,c)
end
end

cls()
function TIC()t=time()/32
for x=0,239 do for y=1,134 do

pix(x,y-1,(
	 pix(x-1,y-1) + pix(x,y-1) + pix(x+1,y-1)+
	 pix(x-1,y) + pix(x,y) + pix(x+1,y)+
	 pix(x-1,y+1) + pix(x,y+1) + pix(x+1,y+1)
	)/(10-(y/2+1)/2*fft(138-y))
)
end end
for i=0,7 do
a=(t-i*20)/20
a=a+C(a*4-2+fft(i)*(1+i))/3.1415
ox=120 + 55*C(a)
oy=68 + 55*S(a)
mba(a,ox,oy,a*3)
end

for i=0,60 do
pix(90+i,84-fft(i*2)*(1+i/2)*8,12)
end

seq={"M","N","B"}
t = t/4
if t//3%3<1 then
print(seq[t//9%3 +1],110,48,14,false,4)
end
end
