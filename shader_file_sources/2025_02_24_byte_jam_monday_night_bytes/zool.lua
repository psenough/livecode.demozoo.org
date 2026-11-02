-- greetz to jtruk, weatherman115, 
-- Catnip, gasman, Suule, g33kou
-- and to gsuberland for the set
-- and to Reality404 for the MC-ing!
-- this has been lovely chaos first jam
m=math

shp={}
shx={}
S=64

function calc(S)
	for i=0,S do
		--it'll come back to me 
		x=i^.3
		shp[i]={m.sin(i/2)*x/2,
									 m.cos(i),
										m.abs(m.cos(i/2))*x}
		-- ???
		shx[i]={m.cos(x/3),
										m.sin(x)*i/8,
										m.cos(2*i)}
	end
end

calc(S)

function TIC()
	cls()
	t=time()
	for i=0,2*m.pi,2*m.pi/5 do
		shape(60+m.cos(i+t/345)*16,
								68+m.sin(i+t/456)*16,
								15,t/456,t/345,i,shp)
								
		shape(180+m.cos(i+t/456)*16,
								68+m.sin(i+t/567)*16,
								15,t/456,t/655,i,shx)

		
	end
end

function BDR(y)
	-- ???
	if y>100 then
		ff=fft(y-90, y-80)*20
		poke(16320,0)
		poke(16321,ff)
		poke(16322,0)

	end
end

function shape(cx,cy,s,tr,tr2,a,shape)

	here={}
	for i=0,S do
		-- yes well
		idx=a*20+i*2
		
		ff=fft(idx,idx+5)*16
		x=shape[i][1]*(s+ff)		
		y=shape[i][2]*(s+ff/2) 
		z=shape[i][3]*s+ff		
		
		x0=x*m.cos(tr+a)+z*m.sin(tr+a)
		z0=z*m.cos(tr+a)-x*m.sin(tr+a)
		y0=y
		
		y1=y0*m.cos(tr)+z0*m.sin(tr)
		z1=z0*m.cos(tr)-y0*m.sin(tr)
		x1=x0
		
		here[i]={x1,y1,z1}
	end
	for i=0,S do
		x1=here[i][1]
		y1=here[i][2]
		z1=here[i][3]


		c=3+(z1+tr+1)%5

		circ(cx+x1+1,cy+y1-1,1,c)

		if i~=0 then
			x2=here[i-1][1]
			y2=here[i-1][2]
			
			line(cx+x1,cy+y1,cx+x2,cy+y2,14)
		end
	end
end
