T=0
M=math
S=M.sin

function rgb(i,r,g,b)
 local a=16320+i*3
	poke(a,r)
	poke(a+1,g)
	poke(a+2,b)
end
function BOOT()
 rgb(0,0,0,0)
end

function BDR(y)
	local tskew=S(T*.005)*.1
	for v=0,1 do
 	vbank(v)
	 local i=.4+v*.6
		for c=1,15 do
		 local xsh=S(y*tskew+T*.04)*30
		 poke(0x3ff9,xsh)
		 local r=200+S(c*.1+T*.05+y*.04)*40
		 local g=150+S(c*.1+T*.02+y*.03)*40
		 local b=100
			if c==0 then
			 b=g
				g=100
			end
		 rgb(c,r*i,g*i,b*i)
		end
	end
end

function TIC()
 poke(0x3ffb,0)
 for v=0,1 do
  vbank(v)
  cls()
  local s=100
		for i=0,s,7 do
			for c=1,15 do
			 local w=(1+S(i*.01+T*.02)*.6)*.7
				local y=i+S(T*.06+v*1+c*.8)*2
			 local x0=-w*(i+S(T*.04+v+c*.1)*5)
			 local x1=w*(i+S(T*.08+v*.2+c*.13)*5)
				for x=x0,x1,10 do
					local skew=S(T*.007)*x
					local skew2=S(T*.005)*y
				 pix(120+x-skew2,y+skew,c)
				end
			end
		end
	end
	 
 T=T+1
end
