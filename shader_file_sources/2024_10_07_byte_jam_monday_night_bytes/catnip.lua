sin=math.sin
cos=math.cos
pi=math.pi
abs=math.abs
min=math.min
max=math.max

t=0
mt=0

vbank(1)
for i=0,44 do
 poke(16320+i, sin(i)^2*255)
end

function btime(t)
 return abs(sin(t*pi))*10
end

function mix(a,b,x)
 return b*x+a*(1-x)
end

function dog(x,yp,to)
	--arms
	local y=yp-btime(mt+to)
	local y2=btime(mt-.1+to)*2
	
	for i=0,10 do
	 circ(x-25-i,mix(y,yp-y2,i/10)-i*4,5,15)
	 circ(x+25+i,mix(y,yp-y2,i/10)-i*4,5,15)
	end
	circ(x-35,yp-y2-45,8,12)
	circ(x-35,yp-y2-41,3,15)
	circ(x-35,yp-y2-49,2,15)
	circ(x-40,yp-y2-46,2,15)
	circ(x-30,yp-y2-46,2,15)
	
	circ(x+35,yp-y2-45,8,12)
	circ(x+35,yp-y2-41,3,15)
	circ(x+35,yp-y2-49,2,15)
	circ(x+40,yp-y2-46,2,15)
	circ(x+30,yp-y2-46,2,15)
	
	y=yp-btime(mt+to)
 --body
 elli(x,y+20,30,40,15)
 elli(x,y+15,20,30,12)
	elli(x-15,y+70,10,30,15)
	elli(x+15,y+70,10,30,15)
 --ears
	local y=yp-btime(mt-.1+to)
 circ(x-17,y-35,7,14)
 circ(x-12,y-35,7,14)
 circ(x-15,y-32,7,15)
 circ(x+17,y-35,7,14)
 circ(x+12,y-35,7,14)
 circ(x+15,y-32,7,15)
 --head
	local y=yp-btime(mt-.05+to)
 elli(x,y-20,20,20,15)
 elli(x,y-13,14,20,15)
 elli(x,y-17,15,20,12)
 --eyes
	local y=yp-btime(mt-.07+to)
 circ(x-10,y-20,5,15)
 circ(x-10,y-20,4,12)
 circ(x-11,y-20,3,15)
 circ(x-13,y-21,1,12)
 circ(x+10,y-20,5,15)
 circ(x+10,y-20,4,12)
 circ(x+11,y-20,3,15)
 circ(x+10,y-21,1,12)
 --nose
	local y=yp-btime(mt-.1+to)
	circ(x,y-5,4,15)
	circ(x-1,y-6,1,12)
	
end

function TIC()
	mt=(t/60)*(130/60)
	vbank(0)
	cls(7)
	
	for i=0,40 do
		math.randomseed(i)
	 local x=(t*(1+(i+math.random())/40)+i*37)%360-60
		dog(
		 x,
			20+i*3+math.random()*15,
		 math.random()*.4-.2)
	end
	
	--local y=abs(sin(mt*pi))*10
	vbank(1)
	cls()
	poke(0x3ff9,sin(t/200)*240%240-120)
	poke(0x3ffa,sin(t/237)*136%136-68)
	--192
	for i=0,14 do
		local x=48+sin(i/7+t/35+sin(i/9+t/37)^3)*24
		local y=60+cos(i/7+t/37+cos(i/9+t/39)^3)*16
		local c=(t/4+i)%13+1
		print("come  to\nbuelfest",x+2,y+2,15,0,3)
  print("come  to\nbuelfest",x,y,c,0,3)
	end
	--trace(w)
	t=t+1
end
