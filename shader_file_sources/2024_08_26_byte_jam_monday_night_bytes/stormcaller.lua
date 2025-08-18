-- pos: 0,0
wgl=0
clk=0
txtclr=0
mov=1
wglr=0
movr=1

function TIC()

t=time()//32
fftvar=fft(3,10)+2

for y=0,136 do for x=0,240 do
pix(x,y,(x^2+y^2+t)>>5)
end end 


clk=clk+1
if clk%30==0 then
	txtclr=math.random(0,15)
	end
	
-- text doofer	

print('Patarty!',60-2*fftvar,28,txtclr,false,3)

-- wiggler

wgl=wgl+mov
if wgl>5 then
	mov=-mov
	end
if wgl<0 then
	mov=-mov
	end

-- wiggler2

wglr=wglr+movr
if wglr>10 then
	movr=-movr
	end
if wglr<0 then
	movr=-movr
	end


-- Patarto

circ(120,68+wgl,12,4)
circ(119,74+wgl,12,4)
circ(119,80+wgl,12,4)
circ(118,86+wgl,12,4)
circ(125,68+wgl,3,0)
circ(115,68+wgl,3,0)
pix(126,67+wgl,3,12)
pix(116,67+wgl,3,12)
circ(113,76+wgl,3,3)
circ(124,82+wgl,3,3)
circ(127,80+wgl,3,3)
circ(110,89+wgl,3,3)

-- patomatos

circ(50,90-wgl,15+2*fftvar,2)
circ(45,85-wgl,2*fftvar,12)
circ(55,85-wgl,2*fftvar,12)
pix(46,85-wgl,0)
pix(54,85-wgl,0)


circ(190,90-wgl,15+2*fftvar,2)
circ(185,85-wgl,2*fftvar,12)
circ(195,85-wgl,2*fftvar,12)
pix(186,85-wgl,0)
pix(194,85-wgl,0)

print('I have no idea what Im doing',50,115,txtclr,false,1)




end
