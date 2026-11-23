-- pos: 0,0
sin=math.sin
cos=math.cos
abs=math.abs

function setcolor(num, r, g, b)

	poke(16320+num*3+0, r)
	poke(16320+num*3+1, g)
	poke(16320+num*3+2, b)

end

function SCN(l)
	
	local r=255.9*abs(sin( (l/7+t)/47 ))
	local g=255.9*abs(sin( (l/19+t)/67 ))
	local b=255.9*abs(sin( (l/31+t)/97 ))
	
	setcolor(1,
		r,
		g,
		b
	)
	
	local avg = (r+g+b)/3
	local val = (avg)*l/256
	setcolor(0,
		val,
		val,
		val
	)
	
end

cls()
function TIC()
	
	t=time()*60/1000
	tInt=t//1
	for n=0,16319 do
		poke(n,peek(n)&tInt)
	end
	
	for n=0,119 do
		line(-1,n+8,vqts(n)*240,n+8,1)
	end
	
	for n=2,15 do
		circ(120+60*cos(t/32+n/9+sin(n/9+t/9)),68+60*sin(t/99+n/9+cos(n/9+t/20)),8+4*sin(n+t/44),n)
	end
	
	scrollstr = "scrolling text "
	for n=0,17 do
		local scrollPosShift = t%8
		local scrollTextPointer = 1+(n+t//8)%#scrollstr
		
		local chrX=228+8*sin( (n-scrollPosShift/8)+t/16 )-3
		local chrY=n*8-scrollPosShift
		
		if t%512<256 then
			rect(chrX-1,chrY-1,8,8,1)
		end
		print(string.sub(scrollstr,scrollTextPointer,scrollTextPointer),chrX,chrY,t%512<256 and 15 or 1)
	end
	
end