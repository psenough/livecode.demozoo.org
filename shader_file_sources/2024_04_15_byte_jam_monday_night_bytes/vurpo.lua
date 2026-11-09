-- greeting to pumpuli and muffintrap
-- and to mintimperial
-- and to aldroid
-- and to everyone watching the jam
--  vurpo

m=math

p={}
p2={}

function r()
 return m.random()-0.5
end

function newp()
	table.insert(p, {
		x=r()*300,
		y=r()*200,
		z=r()*5,
		c=m.floor(m.random()*16)
	})
end

function jam(x,y,s,c)
 line(
 	x-6*s,y-5*s,
  x-6*s,y+5*s,
  12
 )
 line(
 	x+6*s,y-5*s,
  x+6*s,y+5*s,
  12
 )
 line(
 	x-5*s,y+6*s,
  x+5*s,y+6*s,
  12
 )
 line(
 	x-6*s,y+5*s,
  x-5*s,y+6*s,
  12
 )
 line(
 	x+6*s,y+5*s,
  x+5*s,y+6*s,
  12
 )
 line(
 	x-6*s,y-5*s,
  x-5*s,y-6*s,
  12
 )
 line(
 	x+6*s,y-5*s,
  x+5*s,y-6*s,
  12
 )
 rect(
 	x-4*s,y-2*s,
  9*s,7.5*s,
  c)
 rect(
 	x-5*s,y-9*s,
  11*s,3*s,
  2)
end

function BOOT()
	poke(0x3fc0,0)
	poke(0x3fc1,0)
	poke(0x3fc2,0)
end

function TIC()
	t=time()/1000
	
	while #p<200 do newp() end
	cls(0)
	
	--jam(10,10,1)
	center={x=120,y=68}
	table.sort(p,function(a,b)return a.z<b.z end)
	for i=1,#p do
		i0=i%2*2-1
		z=((p[i].z*0.25)+1.2)
		x=p[i].x*z+(i0*20*fft(3))/z
		y=p[i].y*z+(i0*50*fft(10))/z
	 --pix(x+center.x,y+center.y,12)
		jam(x+center.x,y+center.y,z*0.6+fft(2),p[i].c)
		
		p[i].z = p[i].z+0.1
	end
	for i=#p2,1,-1 do
		z=((p2[i].z*0.25)+1.2)
		x=p2[i].x*z
		y=p2[i].y*z
		jam(x+center.x,y+center.y,z*0.6,p2[i].c)
		
		p2[i].y=p2[i].y+p2[i].yv
		p2[i].yv=p2[i].yv+0.1
		
		if p2[i].y>50 then
			table.remove(p2,i)
		end
	end
	for i=#p,1,-1 do
		if p[i].z > 5 then
			if p[i].y>-20 and r()>0.3 then
				local jar=p[i]
				jar.yv=0
				table.insert(p2,jar)
			end
			table.remove(p,i)
		end
	end
end