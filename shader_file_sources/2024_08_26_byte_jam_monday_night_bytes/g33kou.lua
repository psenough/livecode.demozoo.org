-- pos: 0,0
b={
x=120,
y=68,
vx=0.5,
vy=0.5,
s=16,
}
p={}
pp=1
c=1
function TIC()
	t=time()//32
	-- ball
	b.x = b.x+b.vx*b.s
	b.y = b.y+b.vy*b.s
	if b.x>230 or b.x<10 then
		b.vx = -b.vx
	end
	if b.y>126 or b.y<10 then
		b.vy = -b.vy
	end
	r=math.min(fft(0,20)*3,10)
	-- color
	if fft(100,300) > 2 then  -- tune fft for color here
		c=c+1
	end
	if c%16==0 then c=1 end
	-- tail
	p[pp] = {x=b.x, y=b.y, r=r, c=c}
	pp=pp+1
	if pp>300 then pp=1 end
	-- draw
	cls()
	for _,v in ipairs(p) do
		circb(v.x,v.y,v.r,v.c)
	end
	circ(b.x,b.y,r,c)
	circb(b.x,b.y,r,c+1)
	-- angle
	if t~=0 and t%1000==0 then
		a = math.random()*3.14
		b.vx = math.cos(a)
		b.vy = math.sin(a)
	end
end
