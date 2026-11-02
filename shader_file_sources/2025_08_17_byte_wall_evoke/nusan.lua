rnd,flr,sin=math.random,math.floor,math.sin
cls(0)
function SCN(y)
	for k=0,47 do
		poke(0x3fc0+k, math.min(flr(k/3)*15+(k>10 and 300 or 40),255) * math.min(1,sin(y*0.04+(k<30 and (k%3) or 1)-t*5)*0.5+0.5))
	end
end
t=0
function TIC()
	t=t+0.033
	for i=0,600 do
		x2,y2=rnd(240),rnd(160)
		g=pix(x2,y2)
		if g<10 then
			circb(x2,y2,3,g*0.7)
		end
	end
	for i=0,4000 do
		x2,y2=rnd(240),rnd(160)
		g=pix(x2,y2)
		for j=1,100 do
			pix(x2,y2+g,g*0.9)
		end
	end
	x,y,s=rnd(240),rnd(160),20+rnd(20)
	rect(x,y,s,s,rnd(6)+10)
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>