t=0
x=96
y=24

sin=math.sin
cos=math.cos
pi=math.pi

l=0
h=0

br=5
bx=3
by=3
bdx=2
bdy=2

	cls(8)

function BDR(s)
poke(0x3FF9,sin(s/10+t/10)*h)
end
function TIC()
	t=t+1
h=fft(1,9)
if h>0 then
l=l*0.1+h
end

poke(16320+8*3+2,100+50*sin(t/33))

bx=bx+bdx
by=by+bdy

circ(bx,by,br,8)
if bx+3>240 then bdx=-bdx+sin(t)*0.5 end
if bx-3<0 	 then bdx=-bdx+sin(t)*0.5 end
if by+3>136 then bdy=-bdy+sin(t)*0.5 end
if by-3<0 	 then bdy=-bdy+sin(t)*0.5 end


--	print("HELLO WORLD!",20,70+sin(t/10)*20,0,0,3 )

for k =0,3 do
	for i=0,20 do
	x=120+sin(i/2+pi*k/2+t/30)*i*1.5^l
	y=65+cos(i/2+pi*k/2+t/30)*i*1.5^l
	pix(x,y,3+2*k+3*((t//500)))
	end

end

vbank(1)
cls(0)
circb(bx,by,br,9)
if t%600>540 then print("wroom wroom",bx+br,by+br,10) end
for k =0,3 do
	for i=0,20 do
	x=120+sin(i/2+pi*k/2+t/30)*i*1.5^l
	y=65+cos(i/2+pi*k/2+t/30)*i*1.5^l
	circb(x,y,2,3+2*k+3*((t//500)))
	circb(x,y,3,3+2*k+3*((t//500)))
	end
end
vbank(0)

--if ((t%100)>50) then br=30 end
--if (t%100==53) then br=5 end

end
