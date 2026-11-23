-----
-- MUFFINTRAP
--------

-- Brain still in C++/Vim mode
-- After assembly but maybe
-- I remember how to Lua

-- Check out https://natureofcode.com
-- for nice particle codes!

-- Palette from sizecoding.org

-- Globals
W=240
H=136
R=math.random
ABS=math.abs
DELTA=0.016

-- Gravity
gravx=0
gravy=0

-- Particle functions
function Particle(tp)
	return {
	x=R(0,W),
	y=R(0,H),
	dx=R(-1,1),-- Direction?
	dy=R(-1,1), 
	vx=0, -- Velocity
	vy=0,
	ax=0,	--Acceleration
	ay=0,
	maxs=R(70,200), -- Max speed
	target=tp,
	s=R(6,32),
	c=R(4,15)
	}
end

function AddForce(p,f)
	p.ax=p.ax+f.x*DELTA
	p.ay=p.ay+f.y*DELTA
end

function GoTarget(p)
	if p.target==nil then
		return
	end
	ttx=p.target.x-p.x
	tty=p.target.y-p.y
	AddForce(p,{x=ttx*100,y=tty*100})
end

function Update(p)
	p.vx=p.vx+p.ax*DELTA
	p.vy=p.vy+p.ay*DELTA

	-- Limit max velocity
	if ABS(p.vx)>p.maxs then
		p.vx=p.maxs
	end
	p.vy=p.vy+gravy*DELTA
	if ABS(p.vy)>p.maxs then
		p.vy=p.maxs
	end

	-- Move
	p.x=p.x+p.vx*DELTA
	p.y=p.y+p.vy*DELTA

	-- Looppeti-luup
	if p.y>H then
		p.y=0
	end
	if p.x>W then
		p.x=0
	end
	if p.y<0 then
		p.y=H
	end
	if p.x<0 then
		p.x=W
	end

	p.ax=0
	p.ay=0
end

-- Timer for changing effect
fxtimer=0
fxtime=5.0

-- Timer for inside effect
timer=0
turntime=1.0

particles={}
target=Particle()

function ShuffleParticles()
	for i=1,#particles do
		f=R(1,#particles)
		t=R(1,#particles)
		tp=particles[t]
		particles[t]=particles[f]
		particles[f]=tp
	end
end

-- Create particles and target
for p=1,64 do
	table.insert(particles,p,Particle(target))	
end

target.vx=R(-100,100)
target.vy=R(-100,100)
target.target=particles[R(0,#particles)]

function LinesFX()
	cls(0)
	for i,p in pairs(particles) do
		AddForce(p,{x=5000.0,y=4000})
		Update(p)
		ti=i+math.floor(t*8)
		
		ti=1+(ti%(#particles-1))
		tp=particles[ti]
		line(p.x,p.y,tp.x,tp.y,p.c)
	end
end

function FlyingFX()
	cls(0)		
	if timer>turntime then
		timer=0
		target.target=particles[R(0,#particles)]
	end

	gv={x=gravx,y=gravy}
	for i,p in pairs(particles) do
		-- Accelerate
		AddForce(p,gv)
		GoTarget(p)		
		Update(p)
	end	

	GoTarget(target)
	Update(target)
        -- Draw particles
	for i,p in pairs(particles) do
		circb(p.x,p.y,2,p.c)
	end
	circ(target.x,target.y,2,15)
end

function SnakesFX()
	-- Move particles
	turn=false
	if timer>turntime then
		turn=true
		timer=timer-turntime
		ShuffleParticles()
	end
	for i,p in pairs(particles) do
		p.x=p.x+p.dx*p.s*0.016
		p.y=p.y+p.dy*p.s*0.016
		if turn then
			p.dx=R(-1,1)
			p.dy=R(-1,1)
		end
	end		
	-- Draw particles
	for i,p in pairs(particles) do
		circ(p.x,p.y,2,p.c)
	end
end

-- Demo start

-- Setup palette
for j=0,47 do
	poke(16320+j,255/(1+2^(4+2*j%3-j/5)))
end
cls(0)
fx=0
function TIC()
	t=time()/1000	
	timer=timer+DELTA
	fxtimer=fxtimer+DELTA
	if fxtimer>fxtime then
		fxtimer=0
		fx=(fx+1)%3
		cls(0)
	end
	if fx==0 then
		SnakesFX()	
	elseif fx==1 then
		FlyingFX()
	elseif fx==2 then
		LinesFX()
		fxtimer=fxtimer+DELTA*2
	end
end