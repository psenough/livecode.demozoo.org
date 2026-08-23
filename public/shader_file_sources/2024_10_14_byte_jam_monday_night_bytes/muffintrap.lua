-- SENDING BEANS...kkjj
S=math.sin
C=math.cos
R=math.random
TAU=math.pi*2
cx=120
cy=68

rings=10
zstep=0.4
positions={}
levels=rings/zstep
for l=0,levels do
	positions[l]=0
end

function tunnel(t)
	t=t/100
	r=100
	vels={}
	levels=rings/zstep
	bin=0
	-- Change velocity
	bs=math.floor(128/levels)
	for l=0,levels do
		sign=l%2
		if sign==0 then
			sign=-1
		else
			sign=1
		end
		vels[l]=fft(bin,bin+bs)*0.10*sign
		bin=bin+bs
		-- Update position		
		v=vels[l]
		p=positions[l]
		positions[l]=p+v
	end
	
	level=0	
	for z=0.001,rings,zstep do		
		cx=120+S(t*(4+level))*8
		cy=68+C(t*(4+level))*8
	
		depth_r=r/z
		color=2+level
		
		--lines
		eps=TAU/360*15
		end_r=r/(z+zstep)
		round=positions[level]
		for p=0,3 do

	 		rx=cx+S(round+eps*p)*depth_r
			ry=cy+C(round+eps*p)*depth_r
			rx2=cx+S(round+eps*p)*end_r
			ry2=cy+C(round+eps*p)*end_r
			u=p+1
			rx3=cx+S(round+eps*u)*depth_r
			ry3=cy+C(round+eps*u)*depth_r
			rx4=cx+S(round+eps*u)*end_r
			ry4=cy+C(round+eps*u)*end_r
			
			tri(rx,ry,rx2,ry2,rx3,ry3,color)
			tri(rx2,ry2,rx3,ry3,rx4,ry4,color)
		end
		level=level+1	
	end
end

stars={}
for s=0,256 do
	stars[s]={x=R(-10,10),y=R(-10,10),z=R()*5.0}
end

ramp={0,15,14,13,12}

function starfield(t)
	for s=0,#stars-1 do
		z=stars[s].z
		if z<3.5 then
		ci=6-math.floor(z)
		
		x=cx+stars[s].x/z
		y=cy+stars[s].y/z
		
		sz=1
		hsz=sz/8
		step=sz/z
		half=step/2
		
		xl=x-step		
		yt=y-step		
		xr=x+step
		yb=y+step
		c=1+s%15--ramp[ci-1]
		tri(xl,y,
		x,yt+half,
		x,yb-half,c)
		tri(xr,y,
		x,yt+half,
		x,yb-half,c)
		tri(x,yt,
		xl+half,y,
		xr-half,y,c)
		tri(x,yb,
		xl+half,y,
		xr-half,y,c)
		end
		stars[s].z=z-0.01
		if stars[s].z<=0.0 then
			stars[s].z=5.0
		end
	end
end

function TIC()
t=time()//32
cls(0)
tunnel(t)
starfield()
end
