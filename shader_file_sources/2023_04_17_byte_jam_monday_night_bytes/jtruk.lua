S=math.sin
C=math.cos
A=math.atan2
PI=math.pi
PI2=PI*2
T=0

DOTS={}
function	addDot(xc,yc)
	getIFreeDot=function()
		for i=1,#DOTS do
			local dot=DOTS[i]
			if dot.life<0 then
				return i
			end
		end
		return #DOTS+1
	end

	nextFree=getIFreeDot()
	DOTS[nextFree]={
		x=xc,
		y=yc,
		life=100,
	}
end

function doDot(dot)
	if dot.life>=0 then
		local size=1+(dot.life/100)*5
		circ(dot.x,dot.y,size,15)
		dot.life=dot.life-1
		dot.y=dot.y+1
	end
end


-- COLOURS!!!
function BDR(y)
	vbank(0)
	for c=0,14 do
		local addr=0x3FC0+(1+c)*3
		local i=c/14
--		local r=0.5+S(i)*.25+S(T*.05+y*.08)*.25
--		local g=0.5+S(.3+i)*.25+S(T*.06+y*.1)*.25
--		local b=0.5+S(.6+i)*.25+S(T*.07+y*.12)*.25
		local r=0.5+S(.3+i)*.25+S(T*.04+y*.05)*.25
		local g=0.5+S(.2+i)*.25+S(T*.06+y*.04)*.25
		local b=0.5+S(.5+i)*.25+S(T*.07+y*.06)*.25
		poke(addr,(r*255)//1)
		poke(addr+1,(g*255)//1)
		poke(addr+2,(b*255)/1)
	end

	vbank(1)
	for c=1,15 do
		local addr=0x3FC0+c*3
		local i=c/15
		local r=0.5-S(i)*.25+S(T*.05+y*.08)*.25
		local g=0.5-S(.3+i)*.25+S(T*.06+y*.1)*.25
		local b=0.5-S(.6+i)*.25+S(T*.07+y*.12)*.25
		poke(addr,(r*255)//1)
		poke(addr+1,(g*255)//1)
		poke(addr+2,(b*255)/1)
	end

	local ofs=
		((S(T*.09+y*.05)*10)
		+(S(T*.04+y*.03+fft(0)*40)*10)
		)//1
	poke(0x3ff9,ofs)
end

function TIC()
	vbank(1)
	cls()

	for i=1,#DOTS do
		doDot(DOTS[i])
	end

	for s=0,30 do
		local ox=s*.8+T*.023
		local oy=s*.6+T*.012
		local oz=s*1.1+T*.019
		local xc=S(ox)*800
		local yc=C(oy)*600
		local zc=10+S(oz)*20
		local xst,yst,ast=drawStar(xc,yc,zc,T*.1,s)

		if T%15==s then
			addDot(xst,yst,ast)
		end
	end

	local lastp=0
	for y=0,136 do
		for x=0,240 do
			p=pix(x,y)
			if p>0 then
				local dx,dy=x-120,y-68
				local d=(dx^2+dy^2)^0.7
				local a=A(dx,dy)
				local p=p*5+
					S(a^2)+S(d*.05+T*.1)
				pix(x,y,2+(p%14))
			elseif(lastp>0)then
				pix(x,y,1)
			end
			lastp=p
		end
	end

	print("jtruk",209,129,1)
	print("jtruk",208,128,15)

	vbank(0)
	for y=0,136 do
		for x=0,240 do
			local dx,dy=x-120,y-68
			local d=(dx^2+dy^2)^0.7
			local a=A(dx,dy)
			local p=
				8
				+S(
					d*.03
					-T*.2
					+d*.005+a
				)*7
			pix(x,y,p)
		end
	end
	
	T=T+1
end

function drawStar(xc,yc,zc,a,c)
	local xcp,ycp,zcp=proj(xc,yc,zc)
	local size=100/zcp

	for p=0,4 do
		local a0=p/5*PI2+a
		local xi0=xcp+S(a0)*size
		local yi0=ycp+C(a0)*size
		local a1=(p+1)/5*PI2+a
		local xi1=xcp+S(a1)*size
		local yi1=ycp+C(a1)*size
		
		local a2=(p+.5)/5*PI2+a
		local xo=xcp+S(a2)*size*2
		local yo=ycp+C(a2)*size*2
		
		tri(xcp,ycp,xi0,yi0,xi1,yi1,1+c%15)
		tri(xi0,yi0,xi1,yi1,xo,yo,1+c%15)
	end
	
	return xcp,ycp,a
end

function proj(x,y,z)
	return
		120+(x/z),
		68+(y/z),
		z
end