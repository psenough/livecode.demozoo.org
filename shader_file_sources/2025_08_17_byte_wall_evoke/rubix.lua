--rubix
abs=math.abs
sin=math.sin
cos=math.cos
tan=math.tan
atan=math.atan
function pal(i)
 return (i+
  math.ceil(4*time()*.001))
  %12
end
function TIC()
	local t=time()*.001
	for y=0,135 do
		for x=0,239 do
			local dx=120-x
			local dy=68-y
			local k = (25+math.floor(t*1.5)%4) * .01
			dx=dx*k
			dy=dy*k
			local p=6.3+sin(33*t)
			local d=(abs(dx)^p+abs(dy)^p)^(1/p)
			local a=math.atan2(dy,dx)
			local h=0
			h=h+15*dx*sin(150*dy)
			h=h+15*dy*sin(150*dx)
			c=(4+math.sin(d*.1+a-t)*13)
			c=c*(2^(5.5+1.6*0*sin(t*10.7)))/h
			c=pal(c)
			pix(x,y,c)
  end
 end

	--print(text,x,y,12,false,3)
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>