S=math.sin
C=math.cos

function setcolor(num, r, g, b)

	poke(16320+num*3+0, r)
	poke(16320+num*3+1, g)
	poke(16320+num*3+2, b)

end
t=0
function SCN(l)
	for c=0,15 do
		
		setcolor(c,
			c+l+t,
			255*(ffts( (c+l) )^.5),
			c*c~(l+t//1)
			)
		end
end

function TIC()
	
	cls()
	
	T=time()*60/1000
	
	p={}
	for n=0,6 do
		table.insert(p,{
			120+60*C(t/9+n),
			68+60*S(t/9+n),
			64*S(t/6+n),
			1+n*8
			})
	end
	
	for x=0,239 do
		for y=0,135 do
			t=T%(1+x+32*y)
			local c = (x+y+99*ffts( (x+y)%1024 ))/8 + (y//16) + 8*S(t/ (x~y&t//8) ) * ((x*x + y*y ~ (x+t)//6)^.5)/(1+(y+t)%128)
			
			pix(x,y,c)
		end
	end
	
	for bank=1,0,-1 do
		vbank(bank)
		if (bank==1) then 
		if math.random()<.5 then cls() end
		
		for n=0,16 do
			rect(120+112*S(t/64+n),n*8,8,8,1+ffts(n*32,n*32+31)+8*n)
		end
		
		end
		for n=0,15 do
			x=120
			y=68
			r=45-n*3 + 8*ffts(n*15,n*15+14)
			F = (bank==0 and circ or circb)
			F(x,y,r,15-n)
		end
	
	end
	
	
end