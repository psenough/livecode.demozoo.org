fmax={}
for i=1,256 do fmax[i]=0.00001 end

function mix(a,b,t)
 return a*(1-t)+b*t
end

function pal(bk,r,g,b)
 for i=0,15 do
  local t=i/15
  poke(16320+i*3+0,mix(bk,r,t))
  poke(16320+i*3+1,mix(bk,g,t))
  poke(16320+i*3+2,mix(bk,b,t))
 end
end

pal(0,255,110,110)
cls()

vbank(1)
pal(0,255,255,255)
cls()
t=0

function sample(x,t)
 local v=0
 for i=1,20 do
  v=v+math.sin((x+i+t)*math.pi*2^i)*fft(i-1)
 end
 return v
end

function r2d(p,a)
	local sa=math.sin(a)
	local ca=math.cos(a)
	return {
	 x=ca*p.x+sa*-p.y,
		y=ca*p.y+sa*p.x
	}
end

function TIC()
	for i=1,256 do
	 fmax[i]=math.max(fmax[i],fft(i-1))
	end
	
	vbank(0)
 if t%2==1 then
  memcpy(1,0,16319)
 end
 poke(0x03ff9,(t+1)%2)
 
 for i=0,135 do
  local j=(i/(135*(10/9))+.1)^2*255//1
  local v=math.min(15,
   (fft(j)/fmax[j+1])^.75*16
  )
  pix(t%2,135-i,v)
 end
 
	vbank(1)
	cls()
 if t%2==1 then
  memcpy(1,0,16319)
 end
 poke(0x03ff9,(t+1)%2)
	local lastx1=nil local lasty1=nil
	local lastx2=nil local lasty2=nil
	
	for x=0,239 do
	 local i=x/240
	 local v=sample(i,-t/100)
		v=v*40
		local px=x
		local py=v+68
		
		
		line(
		 (lastx2 or px)+2,(lasty2 or py)+2,
			px+2,py+2,1)
		line(
		 lastx2 or px,(lasty2 or py),
			px,py,15)
		lastx2=px
		lasty2=py
		
		v=sample(i*(t//40%4+1),0)
		v=v*40
		local ptemp=r2d({x=0,y=v+40},i*math.pi*2)
		local mp=math.sin(t/80)*.5+1.5
		mp=1
		px=mix(px,ptemp.x+120,mp)
		py=mix(py,ptemp.y+68,mp)
		
		line(
		 (lastx1 or px)+2,(lasty1 or py)+2,
			px+2,py+2,1)
		line(
		 lastx1 or px,(lasty1 or py),
			px,py,12)
		lastx1=px
		lasty1=py
	end
	
	for y=0,135 do
	 for x=0,239 do
		 --pix(x,y,math.max(0,pix(x,y)-x%3+y%3%1))
		end
	end
 
 t=t+1
end
