S,C,A=math.sin,math.cos,math.atan2

T=0
M={
	{v=0,f=0,x=70,w=50,h=20},
	{v=0,f=0,x=140,w=30,h=30},
	{v=0,f=0,x=180,w=20,h=40},
	{v=0,f=0,x=205,w=15,h=48},	
}
MSGS={
	"Hey",
	"There",
	"Trust",
	"Your",
	"Fellow",
	"Martians",
	"To",
	"Sing",
	"A",
	"Groovy",
	"Song",
	"",
	"Greetz",
	"To",
	"Alia",
	"Mantratronic",
	"ToBach",
	"Synesthesia",
	"Aldroid",
	"You All! =)",
	"",
}
MSG=1
MINT=70

function BDR(y)
	vbank(0)
	local o=T*.01
	for i=1,15 do
		local addr=0x3fc0+i*3
		r=S(o+i*.1)*.5+.5
		g=S(o*.7-i*.13)*.5+.5
		b=S(o*.6+i*.07)*.5+.5
		poke(addr,(r*255)//1)
		poke(addr+1,(g*255)//1)
		poke(addr+2,(b*255)//1)
	end	
end

function TIC()
	vbank(1)
	cls()
	M[1].f=aveFFT(0,4,15)
	M[2].f=aveFFT(60,4,150)
	M[3].f=aveFFT(100,4,300)
	M[4].f=aveFFT(200,4,600)
		
	for i=1,4 do
		openV(M[i])
	end
	
	elli(120,125,150,20,1)

	for i=4,1,-1 do
		m=M[i]
		local bounce=M[i].v*10
		local h=m.h+bounce
		local y=135-m.h-bounce/2-i*5
		local ym=y+h/3
		local ye=y-h
		local es=11-i
		elli(m.x+1,y+1,m.w,h,i*2-1)
		elli(m.x,y,m.w,h,i*2)
		elli(m.x,ym,m.w*.8,M[i].v*15,i*2-1)
		elli(m.x,ym,m.w*.8,M[i].v*12,12)
		circ(m.x+1,ye+1,es,i*2-1)
		circ(m.x,ye,es,12)
		circ(m.x,ye,es-5,15)
	end
		
	local msg=MSGS[1+(T//MINT)%(#MSGS)]
	local y=60-T%MINT
	local x=30+S(T*.1)*10
	print(msg,x+1,y+1,15)
	print(msg,x,y,12)
	
	vbank(0)
	cls()
	
	for x=0,240 do
		for y=0,136 do
			local p=S(x*.1)+C(y*.1)+T*0.01
			local a=A(x,y)
			p=8+math.sin(p*.5+a+S(T*0.005))*7
			pix(x,y,p)
		end
	end
	
	for i=0,10 do
	 for s=10,0,-1 do
			a=(math.pi*2*i/10-T*.01+s*.05)
			x=120+C(a)*200
			y=150+S(a)*110+S(s-T*.1)*20
			col=1+s%15
			circ(x+1,y+1,15-s,1+(col+5)%15)
			circ(x,y,15-s,col)
		end
	end

	T=T+1
--[[
	rect(0,0,32,fft1*136,12)
	rect(60,0,32,fft2*136,12)
	rect(120,0,32,fft3*136,12)
	rect(180,0,32,fft4*136,12)
--]]
end

function aveFFT(st,c,m)
	local acc=0
	for i=st,st+c do
		acc=acc+fft(i)
	end
	return math.max(0,math.min(1,(m*acc/c)))
end

function openV(m)
	if m.f>(m.v)*2 then
		m.v=m.f
	else
	 m.v=m.v*.95
	end
end