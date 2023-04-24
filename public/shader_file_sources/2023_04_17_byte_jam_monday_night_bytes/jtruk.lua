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
	cls(0)

	vbank(1)
	for i=1,#DOTS do
		doDot(DOTS[i])
	end

	for s=0,10 do
		local ox=(s^2)*.03+T*.05
		local oy=(s^2)*.034+T*.032
		local oz=(s^2)*.034+T*.032
--		local xc=120+S(ox)*100
--		local yc=68+C(oy)*50
		local xc=S(ox)*8
		local yc=C(oy)*2
		local zc=C(oz)*500+500
		xc,yc=drawStar(xc,yc,zc,T*.1,1+(s%15))
	end

	if T%3==1 then
		local x=S(T*.02)*120+120
		local y=C(T*4)*30+30
		addDot(x,y)
	end

	for y=0,136 do
		for x=0,240 do
			if pix(x,y)>0 then
				local dx,dy=x-120,y-68
				local d=(dx^2+dy^2)^0.7
				local a=A(dx,dy)
				local p=
					8+
					S(a^2.5+T*.01+S(d*.1))*7
				pix(x,y,p)
			end
		end
	end
	
	vbank(0)
	for y=0,136 do
		for x=0,240 do
			local dx,dy=x-120,y-68
			local d=(dx^2+dy^2)^0.7
			local a=A(dx,dy)
--			local p=1+C(T*.1)+d^1.1*(C(T*.01+a/PI2)*.2)
			local p=
				8+
				C(d*.1+T*S(T*.03))*.5+S(a^2+T*.01+d*.01+C(a^2))*3
			pix(x,y,p)
		end
	end
	
	T=T+1
end

function drawStar(xc,yc,zc,a,c)
	for p=0,4 do
		local a0=p/5*PI2+a
		xc,yc,zc=proj(xc,yc,zc)
		local size=zc^.5
		local xi0=xc+S(a0)*size
		local yi0=yc+C(a0)*size
		local a1=(p+1)/5*PI2+a
		local xi1=xc+S(a1)*size
		local yi1=yc+C(a1)*size
		
		local a2=(p+.5)/5*PI2+a
		local xo=xc+S(a2)*size*2
		local yo=yc+C(a2)*size*2

--		xi0,yi0,z0=proj(xi0,yi0,z)
	--	xi1,yi1,z1=proj(xi1,yi1,z)
	--	xo,yo,zo=proj(xo,yo,z)
		
		tri(xc,yc,xi0,yi0,xi1,yi1,c)
		tri(xi0,yi0,xi1,yi1,xo,yo,c)
	end
	
	return xc,yc
end

function proj(x,y,z)
	pz=z/100
	return
		120+(x/pz),
		68+(y/pz),
		z
end