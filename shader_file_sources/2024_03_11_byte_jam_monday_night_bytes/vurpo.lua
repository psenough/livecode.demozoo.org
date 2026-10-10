-- YIPPEE!!!
-- created by vurpo
-- greetings to mallard violet aldroid theremin catnip

m=math
p={
{1,-3},{1,8},{2,13},{5,15},{9,13},{11,8},
{11,5},{11,8},{13,13},{15,15},{18,13},
{19,12},{20,4},{25,4},{25,13},{28,15},
{31,14},{32,13},{33,8},{33,-2},{31,-6},
{20,-7}
}

function sign(x)
 if x<0 then return -1
 else return 1 end
end

function drawthing(x,y,flip)
 for i=1,#p-1 do
  line(
  	x+p[i][1]*flip,
   y+p[i][2],
   x+p[i+1][1]*flip,
   y+p[i+1][2],
   0)
 end
 circb(x+8*flip,y-21,18,0)
 circ(x+1*flip,y-21,5,0)
 circ(x+15*flip,y-21,5,0)
 circ(x-1*flip,y-22,1.5,12)
 circ(x+13*flip,y-22,1.5,12)
 line(x+6*flip,y-11,x+11*flip,y-11,0)
end

function len(x,y)
	return m.sqrt(m.pow(x,2)+m.pow(y,2))
end

function rotscale(p,angle,scale)
 return {
  x=scale*(p.x*m.cos(angle)-p.y*m.sin(angle)),
  y=scale*(p.y*m.cos(angle)+p.x*m.sin(angle))
 }
end

function drawthings()
 for i=#c,1,-1 do
 	c[i][1]=c[i][1]+c[i][3]
 	c[i][2]=c[i][2]+c[i][4]
  
  c[i][3]=c[i][3]*0.91
  c[i][4]=c[i][4]*0.96+0.2
  
		mag=len(c[i][3],c[i][4])
  
  if c[i][4] > 1.8 then
  	table.remove(c,i)
  else
	 	x=c[i][1]
	  y=c[i][2]
			angle=m.atan2(c[i][4],c[i][3])
	 	x1=m.abs(c[i][3])
	  y1=m.abs(c[i][4])
			m2=m.min(1.1,mag)
			p1=rotscale({x=-2-mag,y=-1.8*m2},angle,mag*0.04+0.6)
			p2=rotscale({x=-2-mag,y= 1.8*m2},angle,mag*0.04+0.6)
			p3=rotscale({x= 2+mag,y=-1.8*m2},angle,mag*0.04+0.6)
			p4=rotscale({x= 2+mag,y= 1.8*m2},angle,mag*0.04+0.6)
	 	tri(
				x+p1.x,y+p1.y,
				x+p2.x,y+p2.y,
				x+p3.x,y+p3.y,
	   c[i].c)
			tri(
				x+p2.x,y+p2.y,
				x+p3.x,y+p3.y,
				x+p4.x,y+p4.y,
	   c[i].c)
  end
 end
end

x=0

function triangle(x)
 return 2*m.abs(x-m.floor(x+0.5))
end

c={{100,100,1.5,-1.5,c=3}}

function r()
 return m.random()-0.5
end

colors={2,3,4,5,10}

function add(x,y,x2)
	if #c < 400 then
		table.insert(c,
			{
				x,y,
				x2*6.5+r()*12,
				  -8.3+r()*7.5,
				c=colors[m.floor(m.random(1,#colors))]
			}
		)
	end
end

function TIC()
	t=time()/1000
	cls(12)
	drawthing(
	 70+100*triangle(t*2.5/m.pi),
		100-25*m.abs(m.sin(t*10)),
		-sign(m.sin(t*5)))
	if m.random() > fft(3)*5 then
		for _=1,3 do
			add(  0+10*r(),140,1)
			add(240+10*r(),140,-1)
			add(120+10*r(),140,0)
		end
	end
	drawthings()
end
