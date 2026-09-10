sin=math.sin
cos=math.cos
abs=math.abs
max=math.max
min=math.min
rand=math.random
pi=math.pi

t=0

function makeP(p,dir)
 return {
  x=p.x,y=p.y,
  dx=dir.x,dy=dir.y
 }
end

plist={
 makeP({x=120,y=135},{x=0,y=-1})
}
pidx=1
--trace(plist[1].dx)
cls()

for i=0,47 do
 local s=i%3==1 and 1 or .5
 poke(16320+i,((i/47))*255*s)
end

function rot(p,a)
 local sa=sin(a)
 local ca=cos(a)
 return {
  x=(ca*p.x)-(sa*p.y),
  y=(ca*p.y)+(sa*p.x)
 }
end

maxP=16

sox=0
soy=0
sodx=1
sody=0

function TIC()
	vbank(1)
	cls()
	vbank(0)
	for i=1,#plist do
	 local p=plist[i]
		local v=pix(p.x,p.y)
		--if v==--15 then 
		 --circ(p.x,p.y,10,1)
		 --circb(p.x,p.y,10,2)
			--cls() 
		--end
		--if v==16 then		
		 --local d=rot({x=p.dx,y=p.dy},
			 --rand()>0.5 and -pi/4 or pi/4
			--)
			--p.dx=d.x
			--p.dy=d.y
		 --p.x=p.x+p.dx*4
		 --p.x=p.x+p.dx*4
		--else
		pix(p.x,p.y,v+2)
		pix(p.x+1,p.y,pix(p.x+1,p.y)+1)
		--if p.dx>0 then
		 --pix(p.x+1,p.y,max(0,pix(p.x+1,p.y)-1))
		--end
		p.x=(p.x+p.dx)%240
		p.y=(p.y+p.dy)%136
		--trace(p.dx)
		--local d=rot({x=p.dx,y=p.dy},0.01)
		--trace(p.dx)
		--p.dx=d.x
		--p.dy=d.y
		
		--if t%60==59 then
		if rand()<0.1 then
		--if v>0 then
			pidx=(pidx+1)%maxP
			if pidx==0 then pidx=1 end
		 --local idx=((#plist)%maxP)+1
			--vbank(1)
			--print("Idx " .. pidx,0,0,12)
			--vbank(0)

			local p2=makeP(
			 {x=p.x,y=p.y},
				{x=p.dx,y=p.dy}
			)
			local a=max(0.03,fft(0,10)/8)
			--rand()/4
			d=rot({x=p.dx,y=p.dy},-a*2)
			local d2=rot({x=p2.dx,y=p2.dy},a)
			p.dx=d.x p.dy=d.y
			p2.dx=d2.x p2.dy=d2.y
			plist[pidx]=p2
		end
	end
	
	--local lx=0
	if t%240<2 then
	for i=t%2,32640,2 do
	 local x=i%240
		local y=i//240
		--local v=pix(x,y)
		pix(x,y,max(0,pix(x,y)-1))
	end
	end	
	--y=fft(0,10)*10
	--print("=^^=",5,52-y,0,0,10)
	--print("=^^=",5,50-y,12,0,10)
	t=t+1
	poke(0x3FF9,sox%240-120)
	poke(0x3FFa,soy%136-68)
	sox=sox+sodx
	soy=soy+sody
	d=rot({x=sodx,y=sody},
	 sin(t/30+sin(t/47))*0.01)
	sodx=d.x
	sody=d.y
end
