W=240
H=136
STEP=2

max=math.max
min=math.min
abs=math.abs
cos=math.cos
sin=math.sin
rnd=math.random
BPM=130



function quad(x1,y1,x2,y2,x3,y3,x4,y4,c,z)
	ttri(x1,y1,x2,y2,x4,y4,x1+c,y1+c,x2+c,y2+c,x4+c,y4+c,2,0,z,z,z)
	ttri(x1,y1,x3,y3,x4,y4,x1+c,y1+c,x2+c,y2+c,x4+c,y4+c,2,0,z,z,z)	
end
function rot(xx,yy,r)
    local x,y=xx,yy
    x=math.cos(r)*xx-math.sin(r)*yy
    y=math.cos(r)*yy+math.sin(r)*xx
    return x,y
end
function lerp(a, b, t)
	return a + (b - a) * t
end
function subpix(i,a,f)
	local p=peek4(i+f)
	poke4(math.min(i-f,0x3fbf*2+1),math.max(p-a,0))
end
function addpix(i,a)
	local p=peek4(i)
	poke4(math.min(i,0x3fbf*2+1),math.min(15,p+a))
end

--cls()

function box(x,y,r,c,z)
	local x1,y1,x2,y2,x3,y3,x4,y4=0,0,0,0,0,0,0,0
	x1=x+r
	y1=y+r
	x2=x-r
	y2=y-r
	x3=x-r
	y3=y+r
	x4=x+r
	y4=y-r
	quad(x1,y1,x2,y2,x3,y3,x4,y4,c,z)
end

tf=0
ttf=0
frm=0

dith={}

for x=0,W*H do
	dith[x]=rnd(100)/100
end
cls()
function TIC()
	frm=frm+1
	bm=fft(0,16)*10
	for i=0,W*H,STEP do
		subpix(i+frm%STEP,4,0)
	end
	tt=time()/60000*(BPM*2)
	t=tt/2
	tt=tt//1*10
	t=t//1*10
	tf=lerp(tf,t,.8)
	ttf=lerp(ttf,tt,.8)
	--x=W/2+cos(t)*bm
	--y=H/2+sin(t)*bm
	x=rnd(W)
	y=rnd(H)
	--quad(x-f,y-f,x+f,y+f,x-f,y+f,x+f,y-f,8,y)
	for x=0,W do
		for y=0,H do
			X=x/W-.5+sin(tf*.02)*.1
			Y=y/H-.5+cos(tf*.021)*.1
			X,Y=rot(X,Y,tf)
			X=X*W*(X*30)
			Y=Y*W*(Y*30)
			X=abs(X)
			Y=abs(Y)
			mi=min(X,Y)
			ma=max(X,Y)
			d=X*X+Y*Y
			d=d*.1
			mi=max(0,min(1023,mi))
			ma=max(0,min(1023,ma))
			f=fft(mi,ma)*10
			c=(f//10)%3*3+tf%14-d*.0002*dith[x*y]
			c=c-d*.001/f
			c=max(0,c)
			if c>0 then
				if t%2==0 then 
					addpix(x+y*W,c,0)
				end
				if c>0 then 
					pix(x,y,c)
				end
			end
		end
	end
end
