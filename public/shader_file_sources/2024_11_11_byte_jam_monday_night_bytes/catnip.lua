sin=math.sin
cos=math.cos
abs=math.abs
min=math.min
max=math.max
pi=math.pi

t=0
f={}
fm={}
fs={}

vbank(0)
for i=0,47 do
 poke(16320+i,i*5)
end

function mix(a,b,t)
 return b*t+a*(1-t)
end

function mix2(a,b,t)
 return {x=mix(a.x,b.x,t),y=mix(a.y,b.y,t)}
end

function e(p,v,x)
	elli(p.x,p.y,v*5,v*30,x-1+t/8)
	ellib(p.x,p.y,v*5,v*30,x+t/8)
end

function r(p,v,x)
 local w=v*5
 local h=v*60
	rect(p.x-w/2,p.y-h/2,w,h,w-1+t/8)
	rectb(p.x-w/2,p.y-h/2,w,h,w+t/8)
end

function l(p,v,x)
 local w=v*10
 local h=v*60
 local s=sin(t/20+x/60)
 local c=cos(t/20+x/60)
	line(
	 p.x+s*w,
		p.y+c*h,
		p.x-s*w,
		p.y-c*h,h)
end

strm=true

cls()

function TIC()
 vbank(0)
 if keyp(1) then strm=false end
 --if t%240<60 then
	 memcpy(0x4000,0,120)
		memcpy(0,121,16319-120)
		memcpy(16200,0x4000,120)

	for i=1,240 do
	 local v=fft(i)
		fm[i]=max(v,fm[i] or 0)
		v=v/fm[i]
		f[i]=v
		fs[i]=(fs[i] or 0)*.8+v*.5
	end
	
	--cls()
	local a={
	 x=sin(t/23)*20,
		y=cos(t/27)*40+68
	}
	local b={
	 x=cos(t/29)*20+240,
		y=sin(t/17)*40+68
	}
	
	for x=0,239 do
	 local mp=x/239
		local p=mix2(a,b,mp)
		local v=f[x+1]--*20
		if strm then v=v*20 end
		--if t%120<60 then
			e(p,v,x)
		--else
		 --l(p,v,x)
		--end
	end
	
	vbank(1)
	--local y=fs[5]*10
	print("=^^=",7,44,15,0,10)
	print("=^^=",5,40,12,0,10)
	
	vbank(0)
	
	t=t+1
 --poke(0x3FFa,0)
end

function SCN(y)
 vbank(0)
 for i=0,47 do
  poke(16320+i, sin((i+y/30+t/30)%47)^2*255)
 end
 for x=0,119 do
  pix(239-x,y,(
   pix(x,y)+pix(x+1,y)+pix(x,y+1)
   )/3+1)
 end
 vbank(1)
 local o=(y-68)/68
 poke(0x3ff9,sin(t/20+y/30)^3*20)
 poke(0x3ffa,sin(t/20+y/30)^7*20)
end
