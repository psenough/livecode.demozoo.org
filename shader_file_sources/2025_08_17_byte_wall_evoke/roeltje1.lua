-- hi from tibs ^ roeltje

sin=math.sin
cos=math.cos
W=240
H=136
W2=W/2
H2=H/2
rnd=math.random
sqrt=math.sqrt
pi=math.pi

cls()
function TIC()
-- cls()
	local t=time()*.001
	
	
	
	for y=0,135 do
		for x=0,239 do
		 pix(x,y,pix(x+rnd(0,2),y))
			if rnd() <0.2 then
			 pix(x,y,0)	
			end
		end
	end


 print("BONKY",30,30+sin(t*3)*6,0,0,4)
 print("BONKY",30+1,30+1+sin(t*3)*6,12,0,4)
 
 for i=0,5 do 
 	tt=(t+i)*4
		x=(i*50+t*20)%300-50
		y=20+sin(tt)^4*95
		w=15+sin(tt)^40*10-cos(tt*2+pi/2)^6*4
		h=15-sin(tt)^40*10
 	elli(x,y,w,h,(t+i)%15+1)
 end 
 
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>