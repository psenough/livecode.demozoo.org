t=0
S=math.sin
A=table.insert

pal = "000000800000008000808000000080800080008080c0c0c0808080ff000000ff00ffff000000ffff00ff00ffffffffff"
for i=0,47 do
	poke(16320+i, tonumber(pal:sub(i*2+1,i*2+2),16) )
end

space = 50
function TIC()
	
	for n=0,6 do
		rect(-(t%space) + space*n - space/2,0,space,136,(t/space+n)%8)
	end
	
	for i=0,3e4 do
		x=i%240
		y=i//240
		if (y<68+16*S(x/99+t/24*(1+ffts(x*4,x*4+3)/16))+4*S(x/99/2+t/99)) then
		c=
			S( (x/16+t/16+S(y/9+x))/1.25 )>0
			and (4*S(x)*S(y)+S(t/8))%8
			or (y/4-t/16+S(x/44+t/9))%8
		pix(x,y,c)
		end
	end
	
	for i=0,5 do
	
		x=i*space-t%space
		y=115
		R=10
		
		for T=0,4,4 do
			P={}
			v=i+t//space
			for n=0,5 do
				
				r = (n+T)//2 * 1.571 + v + 16*S(v+t/99)
				p = R*( S(r-11) + S(r)*(-1)^n ) + (n&1<1 and x or y)
				A(P,p)
			end
			A(P,8+v%8)
			tri(table.unpack(P))
		end
	
	end
	
	rect(0,16,240,16,8)
	
	max = 32
	for n=1,max do
		str = 'who up arraying their graphics '
		ind = (n+t//8)%(#str)
		print(str:sub(ind,ind),n*8-t%8-8,21,7+8*((ind+(t+n*4)//16)%2),true)
	end
	
	t=t+1
	
end