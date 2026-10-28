--hello this is Roeltje!
--letsdothissss

W,H=240,136
W2,H2=120,68
sin,cos=math.sin,math.cos
min,max=math.min,math.max
rnd=math.random
abs=math.abs

particles={}
for i=1,500 do
	p={}
	p.x=rnd(0,W)
	p.y=rnd(0,H)
	p.vx=1
	p.vy=1
	p.a=0
	particles[i]=p
end

cls()
function TIC()
	t=time()/1000
	
	vbank(0)
	bpm=130
	beattime=60/bpm
	beat=t/beattime
	
	for i=0,47 do
		o=beat//4
		poke(16320+i,(i+o)%3*i*2.7)
		--poke(16320+i,sin(i/15+sin(i%3*1))^2*255)
		--poke(16320+i,sin(i/15+sin(i%3*1))^2*255)
	end

	for y=0,H do for x=0,W do
		if rnd()<0.25 then
			pix(x,y,pix(x,y)-.1)
		end
		--pix(x,y,noise(x,y)*15)
	end end
	
	zoom=2+sin(t*.62)
	offsetx=-zoom*W2+W2
	offsety=-zoom*H2+H2
	
	for i=1,#particles do
		p=particles[i]
		
		--p.a=p.a+rnd()*0.5-0.25
		--p.a=noise(p.x//1,p.y//1)*(6+sin(t)*3)
		--p.vx=cos(p.a)
		--p.vy=sin(p.a)
		
		p.a=noise(p.x//1,p.y//1)*(4+sin(t*0.85))
		p.vx=p.vx+cos(p.a)*.2
		p.vy=p.vy+sin(p.a)*.2
		p.vx=p.vx*.8
		p.vy=p.vy*.8
		
		p.x=p.x+p.vx
		p.y=p.y+p.vy
		
		p.x=p.x%W
		p.y=p.y%H
		
		--pix(p.x,p.y,15)
		r=ffts(i)*25
		--r=r*r
		--if r<10 then
		--	circ(p.x,p.y,r,15)
		--else
			circ(p.x*zoom+offsetx,p.y*zoom+offsety,r,15)
		--end
	end
	
	
	--vbank(1)
	--cls()
	
	ty=55+abs(beatsin(t))^10*10
	ty=55
	if beat%1<.05 then
	if beat//1%2==0 then
		print("LETS",67,ty+3,3,true,5)
		print("LETS",64,ty,5,true,5)
	else
		print("GOOO",67,ty+3,3,true,5)
		print("GOOO",64,ty,5,true,5)
	end
	end
	
	--circ(W2,H2,abs(beatsin(t))^10*20+10,12)
	--circ(W2,H2,abs(beatsin(t+.1))^10*20+10,15)
end

function noise(a,b)
	return ((a*3875937~b*5829583~1234567)%631)/631
end

function beatsin(tt)
	return sin(tt/beattime*(math.pi*2)/2)
end