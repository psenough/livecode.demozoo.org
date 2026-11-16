-- zool
-- i am SO tired
-- should stop messing with it

-- greetz 

-- thank you zeno4ever for setting this up
-- thanks Reality and Violet for orga
-- greetz to gasman, Trevor, Frankie

sin=math.sin

for j=3,47 do
	poke(16320+j,sin(j)^2*255)
end

cos=math.cos
pi=math.pi
abs=math.abs
function TIC()
	t=time()/456
	t2=time()/345
	cls()
	s=80
	for xi=-160,160,6 do
		a=abs(xi)/10
		
		for i=0,2*pi,.1 do
			r=1
			x=sin(i)*r*s
			y=cos(i/2)*r*s
			circ(120+xi+x,68+y,4,i*4+t+a)
		end
	end
	
	for s=10,50,10 do
		dots((80+sin(t)*8)+s,68+sin(t2)*8,s)
	end	
end



function dots(cx,cy,s)
	--s=20
	ffs=fft(s-10,s+2)*4
	for i=0,2*pi,.1 do
			x=sin(i)*s*ffs
			y=cos(i)*s
			
			y1=y*sin(1.2)--+t)		
			x1=x*cos(t)+y*cos(t)
			
			circ(cx+x1,cy+y1,2,0)
			circ(cx+x1,cy+y1,1,i*4+t2)

			--pix(cx-x,cy+y,0)

	end
end

