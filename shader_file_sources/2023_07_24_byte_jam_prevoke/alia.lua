function mix(a,b,t)
 return a*(1-t)+(b*t)
end

function setpal(i,a,b)
 for j=0,4 do
  poke(0x03FC0+i*5*3+3+j*3,mix(a.x,b.x,j/4))
  poke(0x03FC0+i*5*3+3+j*3+1,mix(a.y,b.y,j/4))
  poke(0x03FC0+i*5*3+3+j*3+2,mix(a.z,b.z,j/4))
 end
end

vbank(0)
setpal(0,{x=40,y=0,z=40},{x=255,y=0,z=255})
setpal(1,{x=0,y=40,z=40},{x=0,y=255,z=255})
setpal(2,{x=40,y=40,z=0},{x=255,y=255,z=0})
vbank(1)
setpal(0,{x=40,y=0,z=0},{x=255,y=0,z=0})
setpal(1,{x=0,y=40,z=0},{x=0,y=255,z=0})
setpal(2,{x=0,y=0,z=40},{x=0,y=0,z=255})

function add(a,b)
 return {x=a.x+b.x,y=a.y+b.y}
end

function spline(pts,t,o)
 local idx=(t*#pts)+1
 local t2=idx%1
 idx=math.floor(idx)
 --o.x=0 o.y=.
 local a=add(o,pts[math.max(1,idx-1)])
 local b=add(o,pts[idx])
 local c=add(o,pts[math.min(#pts,idx+1)])
 local d=add(o,pts[math.min(#pts,idx+2)])
 
 return {
  x=0.5*(2*b.x)+
   (-a.x+c.x)*t+
   (2*a.x-5*b.x+4*c.x-d.x)*t*t+
   (-a.x+3*b.x-3*c.x+d.x)*t*t*t,
  y=0.5*(2*b.y)+
   (-a.y+c.y)*t+
   (2*a.y-5*b.y+4*c.y-d.y)*t*t+
   (-a.y+3*b.y-3*c.y+d.y)*t*t*t
  }
 --return {
  --x=mix(b.x,c.x,t2),
  --y=mix(b.y,c.y,t2)
 --}
end

e={
 {x=.25,y=.5},
 {x=.75,y=.5},
 {x=.5,y=.25},
 {x=.25,y=.5},
 {x=.5,y=.75},
 {x=.7,y=.6},
}
v={
 {x=.25,y=.25},
 {x=.5,y=.75},
 {x=.75,y=.25},
}
o={
 {x=.25,y=.5},
 {x=.5,y=.75},
 {x=.75,y=.5},
 {x=.5,y=.25},
 {x=.25,y=.5},
}
k={
 {x=.25,y=.25},
 {x=.25,y=.75},
 {x=.25,y=.5},
 {x=.75,y=.75},
 {x=.25,y=.5},
 {x=.75,y=.25},

}
evoke={e,e,v,o,k}

t=0
function TIC()
 t=t+1
 vbank(0)
 cls()
 for c=0,4 do
  local col=c*5+1+(t//30)*5
  --if c>2 then 
   --vbank(1)
   --cls()
   --col=(c-3)*5+1+5
  --end
  local x=(((c*136)-t)%(136*5))-136
  rect(x+5,5,125,125,col)
  
  for q=0,3 do
   local r={
   	x=q*4,
   	y=q*8
   }
		 local lp=nil
	 	for i=0,1,.02 do
   	local off={
   	 --x=math.random()*.05-.025,
   	 --y=math.random()*.05-.025
     x=math.sin(t/60+i*40+r.x)*0.1,
     y=math.cos(t/60+i*4+r.y)*0.1,
   	}
	 	 local p=spline(evoke[c+1],i,off)
		  l=lp or p
		  line(
		   x+p.x*134,
		   1+p.y*134,
		   x+l.x*134,
		   1+l.y*134,
		   col+q+1)
		  lp=p
		 end
		end
 end
 
 --for i=0,15 do
  --vbank(0)
  --print("###",0,i*6,i)
  --vbank(1)
  --print("###",30,i*6,i)
 --end
 --vbank(1) 
 --print("=^^=",5,32,0,0,10)
 --print("=^^=",5,30,15,0,10)
end
