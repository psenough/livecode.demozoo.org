sin=math.sin
cos=math.cos
max=math.max

function rotate(x,y,r)
	return x*cos(r)-y*sin(r),x*sin(r)+y*cos(r)
end

for i=0,47 do
	poke(16320+i,i*5)
end

rotList={}
for n=0,119 do
	rotList[n]=math.random()*math.pi*2
end

thump=0

cls()
vbank(1)
print("vqt and fft living together :)",0,128,15)
function TIC()
	
	vbank(0)
	
	for i=0,0x3FBF do
		
		local val = max(peek(i)-15,0)
		poke(i,val)
		
	end
	
	for n=0,119 do
		rotList[n]=rotList[n]+vqt(n)/9
		local x,y = rotate(0,n+1,rotList[n])
		x=x+120
		y=y+68
		circ(x,y,vqt(n)*8,15)
	end
	
	vbank(1)
	rect(200,0,40,136,0)
	
	thump=thump+fft(9,16)+.5
	for y=0,135 do
		xShift=8*( 2+1*sin( (y+thump)/9  )*sin(y/9)*sin(y/40+time()/500 + sin(y/17)) )
		for x=240-xShift//1,239 do
			pix(x,y,1+(x+y+thump)%15)
		end
	end
	
end

function SCN(l)
	for i=0,45,3 do
		local colMult = i/45
		local r,b = rotate(colMult,0,l/80-time()/600)
		local g = colMult
		poke(16320+i+0,(1+r/2)*255)
		poke(16320+i+1,i==45 and 196 or 0)
		poke(16320+i+2,(1+b/2)*255)
	end
end