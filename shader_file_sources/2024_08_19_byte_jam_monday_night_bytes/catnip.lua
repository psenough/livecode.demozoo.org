sin=math.sin
cos=math.cos
pi=math.pi
abs=math.abs
min=math.min
max=math.max

-- Greets to gasman + tina <3
-- it me, catnip

bass=0
t=0

vbank(1)
poke(16320+3,255)

function mix(a,b,k)
	return a*(1-k)+b*k
end

t2=0

function TIC()
 vbank(0)
	bass=max((bass or 0)*.9, fft(1,10))
	if bass<1.5 then 
	 cls(3) 
	end
	local r=150
	local d=sin(t/4)*5+6
	d=5
	for i=0,500 do
	 local l=(i/500+t/4)%1^.3+.1
		local x=sin(t/2+i/d)*l*r+120
		x=x+sin(l*8+t)*60*l
		local y=cos(t/2+i/d)*l*r+68
		y=y+cos(l*8+t)*60*l
		circ(x,y,l*3+2,l*15-t*5)
	end
	
	vbank(1)
	cls()
	
	--for i=0,19 do
	 --local y=fft(i+1)*50
		--rectb(
		 --i*12,135-y,
			--12,y,
			--i+1)
		--rectb(
		 --i*12,0,
			--12,y,
			--i+1)
	--end
	
	local y=abs(sin(t*4)*20)-20
	local x=sin(t*4)^3*10
	circ(120+x,30-y,20,4)
	circ(120+x,136-50-y,20,4)
	rect(100+x,30-y,41,56,4)
	
	circ(120+x,20-y,8,2)
	circ(120+x,136-40-y,8,2)
	rect(112+x,20-y,17,76,2)

	circ(116+x,25-y,3,12)
	circ(124+x,25-y,3,12)
	circ(115+x,25-y,2,11)
	circ(123+x,25-y,2,11)
	circ(115+x,25-y,1,15)
	circ(123+x,25-y,1,15)
	
	clip(110+x,35-y,20,10)
	elli(120+x,35-y,5,3,12)
	clip(110+x,25-y,20,10)
	circ(123+x,33-y,2,1)
	
	-- feets
	clip()
	for i=0,10 do
		local x2=mix(-20,x-15,i/10)
		local y2=mix(116,-y+90,i/10)
		circ(x2+120,y2,2,4)
		x2=mix(20,x+15,i/10)
		circ(x2+120,y2,2,4)
	end
	clip(0,110,240,10)
	elli(120-23,120,10,5,2)
	elli(120+23,120,10,5,2)
	clip()
	
	-- arm
	for i=0,6 do
	 circ(135+x+i*2,40-y,3,4)
	end
	rect(135+x+10,35-y,5,15,12)
	tri(
	 135+x+10,35-y,
	 135+x+10+5,35-y,
	 135+x+10+2.5,35-y-5,
		12)
		
	-- other arm
	for i=0,10 do
	 circ(105+x-i*2,40-y,3,4)
	 circ(105+x+i-20,40-y-i*3,3,4)
	end
	rect(115+x-25,38-y-30,15,5,1)
	tri(
	 115+x-10,38-y-30,
		115+x-10,38-y-30+5,
		115+x-10+5,38-y-30+2.5,
		12)
	circ(118+x,17-y,3,1)
	circ(116+x,14-y,3,1)
	circ(116+x,20-y,2,1)
	t=t+.03
	t2=t2+1
	
	for y=0,135 do
	 memcpy(y*120,y*120+40,40)
	 memcpy(y*120+80,y*120+40,40)
	end
end

function SCN(y)
 poke(0x3FF9,(sin(t*3+y/20)*20))
 poke(0x3ffa,sin(t*3+y/20)^3*10)
end