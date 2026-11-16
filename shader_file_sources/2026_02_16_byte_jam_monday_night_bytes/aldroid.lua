bds = {}
nbd = 20
for i=0,nbd do
 bds[i]={
 	x=math.random()*240,y=math.random()*136,
  dx=0,dy=0
  }
end

function sgn(x)
 if x<0 then return -1 else return 1 end
end

cx=120
cy=68
scm=300
function TIC()
 t = time()/500
 for x=2,238,4 do for y=2,134,4 do
 pix(x+math.random(-2,2),y+math.random(-2,2),0)
 end end
	ncx=0
	ncy=0
	for i=0,nbd do
	 bd = bds[i]
	 circ(bd["x"],bd["y"],t%3,(t+i)//1)
		dfx=cx - bd["x"]
		dfy=cy - bd["y"]
		dfx = dfx/scm
		dfy = dfy/scm
		
		for j=0,nbd do
		 bd2 = bds[j]
			djx=bd2["x"]-bd["x"]
			djy=bd2["y"]-bd["y"]
			if math.abs(djx)<10 and math.abs(djy) <10 then
			if djx<1 then djx = sgn(djx) end
			if djy<1 then djy = sgn(djy) end
			bd["dx"]=bd["dx"]-1/djx
			bd["dy"]=bd["dy"]-1/djy
			end
		end
		
		bd["dx"]=(bd["dx"]+dfx)/2
		bd["dy"]=(bd["dy"]+dfy)/2
		
		bd["x"]=bd["x"]+bd["dx"]
		bd["y"]=bd["y"]+bd["dy"]
		if bd["x"]>230 then bd["dx"]=bd["dx"]-2 end
		if bd["x"]<10 then bd["dx"]=bd["dx"]+2 end
		if bd["y"]>126 then bd["dy"]=bd["dy"]-2 end
		if bd["y"]<10 then bd["dy"]=bd["dy"]+2 end
		
		ncx=ncx+bd["x"]
		ncy=ncy+bd["y"]
	end
	cx=ncx/nbd
	cy=ncy/nbd
	if cy>126 then cy = 10 end
	if cy< 10 then cy = 126 end
	if cx>230 then cx = 10 end
	if cx< 10 then cx = 230 end
	cx = cx + math.sin(t*.3)*500
	cy = cy + math.sin(t*.32)*500
end
