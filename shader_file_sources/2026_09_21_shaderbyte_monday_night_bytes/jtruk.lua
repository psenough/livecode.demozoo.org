-- Monday Night Bytes 2026-09-21 jtruk
-- Thanks Aldroid (Host)
-- Polynomial (tunes)
-- Greetz Canmom, Borisvanschooten
--        Finkel, Merlocksholmes
--        +YOU

T=0
M=math
R=M.random
S,C=M.sin,M.cos
PI=M.pi
TAU=PI*2
BUFF=0x11164
BSIZE=0x3FC0
TSZ=64

function rgbs(s,r1,g1,b1)
	rgb(0,0,0,0)
	for i=0,6 do
	 local v=255*i/7
		rgb(s+i,r1*v,g1*v,b1*v)
	end
end

function BOOT()
	vbank(0)
	cls()
end

function shuffle()
	vbank(0)
	cls()
	rgbs(1,R(0,4)*63,R(0,4)*63,R(0,4)*63)
	rgbs(8,R(0,4)*63,R(0,4)*63,R(0,4)*63)
	vbank(1)
	rgb(1,60,60,60)
	rgb(2,180,180,180)
	MAX_SIDES=R(4,15)
end

function TIC()
	if T%400==0 then
		shuffle()
	end

	vbank(1)
	cls()
	for v=0,1 do
		local xsh=v*TSZ
		local m=4+v*8
	 for y=0,TSZ do
		 for x=0,TSZ do
				pix(x+xsh,y,m+S(S(x*.1)+S(y*.1)+T*.01)*3)
		 end
	 end
	end

	vbank(0)
	for i=0,4 do
		local j=fft(i*40)
		local cs=3+(i*5)%MAX_SIDES
		local z=-i+S(i*10+T*.02)+j*1
		local d1=.4+i*.2
		local d2=d1*(1.05)*cs
		local pal=i%2
		ring(0,0,d2,d1,cs,i*T*.005,i,z,pal)
	end

 vbank(1)
 cls()
 print("jtruk",209,129,1)
 print("jtruk",208,128,2)
 T=T+1
end

function ring(xc,yc,d1,d2,c,r,cl,z,psh)
	local psh=psh*TSZ
 local lx,ly,la
 local tshs=TSZ/2
	for i=0,c do
		local a=i*TAU/c+r
		local x=S(a)*d1
		local y=C(a)*d1
		if lx~=nil then
		 local ma=la+(a-la)/2
			local mx=S(ma)*d2
			local my=C(ma)*d2
			local x1,y1,z1=proj(xc+lx,yc+ly,z)
			local x2,y2,z2=proj(xc+x,yc+y,z)
			local x3,y3,z3=proj(xc+mx,yc+my,z)
			local sx1,sy1=psh+tshs+S(x1*.03)*tshs,tshs+S(x2*.01+z1)*tshs
			local sx2,sy2=psh+tshs+S(x2*.02)*tshs,tshs+S(y2*.04+z2)*tshs
			local sx3,sy3=psh+tshs+S(x3*.01)*tshs,tshs+S(y3*.02+z3)*tshs
			ttri(
				x1,y1,x2,y2,x3,y3,
				sx1,sy1,sx2,sy2,sx3,sy3,
				2,-1,
				1/z1,1/z2,1/z3
			)
		end
		lx,ly,la=x,y,a
	end
end

function proj(x,y,z)
 local zd=.05/z
 return 120+x/zd,68+y/zd,zd
end

function rgb(i,r,g,b)
	local a=16320+i*3
	poke(a,r) poke(a+1,g) poke(a+2,b)
end