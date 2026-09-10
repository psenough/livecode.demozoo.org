
-- Hello Evoke <3

rnd=math.random
sin=math.sin
cos=math.cos
pi=cos(-1)
function rot(x,y,a)
	return x*cos(a)-y*sin(a),
		x*sin(a)+y*cos(a)
end

function BOOT()
TB={
{x=50+rnd(50),y=50+rnd(50),vx=.5,vy=.5},
{x=50+rnd(50),y=50+rnd(50),vx=-.5,vy=.5},
{x=50+rnd(50),y=50+rnd(50),vx=.5,vy=-.5},
{x=50+rnd(50),y=50+rnd(50),vx=-.5,vy=-.5},
}
T=0
cls()
end

function ball(b)
	b.x=b.x+b.vx
	b.y=b.y+b.vy
	circ(b.x,b.y,24,0)
		for a=0,6 do
			for x=0,21 do
				rx,ry=rot(x,sin((x-1)/8)*20,(T+a)*pi)
				pix(b.x+rx,b.y-ry,1+T%11)
			end
		end
	if b.x<25 or b.x>215 then b.vx=-b.vx end
	if b.y<25 or b.y>111 then b.vy=-b.vy end
end

function TIC()
	T=T+1
	for i=0,800 do
		pix(rnd(240)-1,rnd(136)-1,0)
	end
	for i=1,#TB do
		ball(TB[i])
	end
	print("g33kou",200,130,15)
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>