sin=math.sin
cos=math.cos

maxv={}
for i=1,256 do
	maxv[i]=0.0000000000000000000001
end

verts={}

function n2s(p)
	return {
	 x=(p.x/2+.5)*240,
		y=(p.y/2+.5)*136
	}
end

function rot(p,a)
	local c=cos(a)
	local s=sin(a)
	return {
		x=(c*p.x)+(s*(-p.y)),
		y=p.y,
		z=(c*p.y)+(s*p.x)
	}
end

t=0
vs={}
function TIC()
	t=t+1
	for i=1,256 do
		local v=fft(i-1)
		maxv[i]=math.max(maxv[i]*.98,v)
		vs[i]=v/maxv[i]
	end
	
	local row={}
	for i=1,15 do
		local v=0
		for j=0,15 do
		 v=v+vs[i*16+j]
		end
		vs[i]=v
		row[i]={x=(i-1)/7-1,y=v/15}
		--trace(row[i].y)
	end
	table.insert(verts,1,row)
	if #verts>16 then
		table.remove(verts,#verts)
	end
	
	vbank(1)
	cls()
	for i=0,15 do
		pix(i,0,i)
	end
	vbank(0)
	--cls()
	memcpy(0,120,16320-120)
	local start=0 local ends=16320-1048
	for i=0,2 do
	 local d=math.random()*ends
		local s=math.random()*ends
		local l=math.random()*1048
		l=math.min(l,ends-l)
		memcpy(d,s,l)
	end
	
	for y=t%2,135//2 do
		for x=t%2,239//2 do
			pix(x*2+t%2,y*2+t%2,pix(x*2,y*2)-.9)
		end
	end	
	for i=0,12 do
		print("=^^=",
		 5+sin(t/40+i/4)*15,
		 80+cos(t/40+i/4)*15-vs[1]/2,i,0,10)
	end
	
	--local rotation=t/20
	
	--for z=1,#verts-1 do
		--local row0=verts[z]
		--local row1=verts[z+1]
		--local z0=(z-1)/16-.5
		--local z1=z/16-.5
		
		--for i=1,#row0-1 do
			--local col=0
			--local v0={x=row0[i].x,y=row0[i].y,z=z0}
			--col=col+v0.y
			--local tv=rot({x=v0
			--v0=n2s(rot(v0,rotation))
			--local v1={x=row0[i+1].x,y=row0[i+1].y,z=z0}
			--col=col+v1.y
			--v1=n2s(rot(v1,rotation))
			--local v2={x=row1[i].x,y=row1[i].y,z=z1}
			--col=col+v2.y
			--v2=n2s(rot(v2,rotation))
			--local v3={x=row1[i+1].x,y=row1[i+1].y,z=z0}
			--v3=n2s(rot(v3,rotation))
			--trace(v0.x..":"..v1.x..":"..v2.x)
			--col=(col*10//1)%16+1.5
			--ttri(
				--v0.x,v0.y,
				--v1.x,v1.y,
				--v2.x,v2.y,
				--col,0,
				--col,0,
				--col,0,
				--2)
			--ttri(
				--v1.x,v1.y,
				--v2.x,v2.y,
				--v3.x,v3.y,
				--col,0,
				--col,0,
				--col,0,
				--2)
			--end
	--end
	vbank(1)
	cls()
	--for i=1,240 do
	 --pix(i-1,135-vs[i]*5,12)
	--end
end

function SCN(y)
	vbank(0)
	poke(0x03FF9,vs[(y+1+t)%255+1]*2//1)
end