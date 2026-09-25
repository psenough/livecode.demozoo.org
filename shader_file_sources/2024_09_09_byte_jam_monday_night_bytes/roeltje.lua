--hello this is roeltje!
--shoutout to:
--enfys, pumpuli, geekou, catnip, 
--aldroid, henearxn, violet and lynn!
W,H=240,136
W2,H2=120,68
sin,cos=math.sin,math.cos
rnd=math.random
min,max=math.min,math.max
pi=math.pi

for i=0,47 do
	poke(16320+i,i//3/15*255)
	poke(16320+i,i/47*255)
	--poke(16320+i,sin(i/15+i%3*.2)^2*255)
end
poke(16320+47,10)

x=rnd(0,W)
y=rnd(0,H)
r=rnd(1,15)
c=rnd(12,15)
a=0
e=0
turn=.25

cls()
function TIC()
	t=time()/1000
	turn=sin(t*.1)*1.5
	
	bpm=88
	beattime=60/bpm
	beat=t/beattime
	
	for y=0,H do for x=0,W do
		if (x/4+y/4+t//.3)%15==0 and beat%4<.05 then
			--pix(x,y,6)
		end
		if (x/4-y/4+t//.3)%15==0 and (beat+2)%4<.05 then
			--pix(x,y,6)
		end
	
	
		local c=pix(x,y)
		local c2=pix(x+1,y)
		if rnd()<0.05 then c=c-0.1 end
		if rnd()<0.1 and c2<5 and c2>1 then c=c2 end
		pix(x,y,c)
	end end
	
	circ(x,y,r,c)
	
	if rnd()<0.1 then
		e=e+e*2
		circb(x,y,r+e,c)
	end
	
	--if rnd()<0.01 then
		--line(x,y-1000,x,y+1000,15)
		--line(x-1000,y,x+1000,y,15)
	--end
	
	if rnd()<0.01 then
		print((x//1)..","..(y//1),x+r*1.5+5,y,14)
	end
	
	if rnd()<0.1 then
		if rnd()<0.1 then
			circ(x,y,r,15)
		end
	
		--[[if rnd()<0.1 then
			local h=rnd(0,H)
			line(0,h,W,h,rnd(12,15))
		end
		
		if rnd()<0.1 then
			local w=rnd(0,W)
			line(w,0,w,H,rnd(12,15))
		end]]
	
		newr=rnd(1,15)
		c=rnd(12,15)
		a=a+(rnd()-0.5)*turn
		
		x=x+cos(a)*(r+newr)
		y=y+sin(a)*(r+newr)
		
		r=newr
		e=1
		
		if x>W then x=0 end
		if y>H then y=0 end
		if x<0 then x=W end
		if y<0 then y=H end
		
		--[[if x>W then x=W a=a+pi end
		if y>H then y=H a=a+pi end
		if x<0 then x=0 a=a+pi end
		if y<0 then y=0 a=a+pi end]]
	end
end