m=math
function BDR(i)
 poke(0x3fc0,255+2*m.min(0,i-50))
 poke(0x3fc1,255)
 poke(0x3fc2,255+1.5*m.min(0,i-50))
end
colors={
	255,0,0,
	255,128,0,
	0,0,255,
	128,0,128,
	0,255,255,
	0,255,0
}

colors2={
	0,0,0,
	127,0,255,
	0,0,255,
	0,255,0,
	255,255,0,
	255,127,0,
	255,0,0
}
function BOOT()
	for i=0,#colors do
		poke(0x3fc3+i,colors[i+1])
	end
end
offset=14
c_x=120
c_y=92
r=14
function lerp(x,y,a)
	return x*(1-a)+y*a
end

function TIC()
	t=time()/100
	for i=0,#colors2-1 do
		poke(0x3fd5+i,m.floor(lerp(colors2[i+1],255,m.sin(t*2)*0.10+0.85)))
	end
	cls(0)
	print("Z",0+offset,10,1,false,4)
	print("o",25+offset,8,2,false,4)
	print("m",50+offset,6,3,false,4)
	print("b",75+offset,8,4,false,4)
	print("o",100+offset,10,5,false,4)
	print(".",125+offset,10,3,false,4)
	print("c",140+offset,10,2,false,4)
	print("o",165+offset,10,6,false,4)
	print("m",190+offset,10,3,false,4)
	
	local d_x=c_x+m.cos(t*3)
	local d_y=c_y+m.sin(t*3)
	circ(d_x,d_y,r,7)
	for i=1,6 do
		circ(
			d_x+(r*2+2)*m.cos(t+3.141592/3*i),
			d_y+(r*2+2)*m.sin(t+3.141592/3*i),
			r,i+7
		)
	end
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>