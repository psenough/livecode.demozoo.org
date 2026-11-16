pe={}
ps={}
fe={}
gen={"boy","girl","enby","cat",0}

k=math.random

function rot2d(v,a)
 return {
  x=(math.cos(a)*v.x)-(math.sin(a)*v.y),
  y=(math.cos(a)*v.y)+(math.sin(a)*v.x)
 }
end

function BOOT()
 for i=1,16 do 
  pe[i]={
   x=k()*239,
   y=k()*135,
   dx=k()*2-1,
   dy=k()*2-1,
   f=false,
   g=math.random(1,#gen),
   fs=0,
   c=0,
   t=false
  }
  
  ps[i]={
   x=k()*239,
   y=k()*135,
   dx=k()*2-1,
   dy=k()*2-1,
   hist={},
   f=false
  }
  h={}
 	for j=1,15 do
   ps[i].hist[j]={x=ps[i].x,y=ps[i].y}
  end
 end
end

t=0

function length(v)
 return (v.x*v.x+v.y*v.y)^.5
end

function TIC()
 cls()
 t=t+0.1
 
 for i=1,#pe do
  local e=pe[i]
  for j=0,2 do
   local f=e.f and 11 or 2
   circ(e.x,e.y,5-j,f+j)
  end
  e.x=(e.x+e.dx)%240
  e.y=(e.y+e.dy)%136
  e.dx=e.dx*.95
  e.dy=e.dy*.95
  if e.f then
   local g=gen[e.g]
   g=g==0 and "trans rights!" or g
   print(g,e.x+7,e.y-7,12)
   e.c=e.c-1
   if e.c==0 then
    e.f=false
    e.dx=math.random()*10-5
    e.dy=math.random()*10-5
    ps[e.fs].f=false
    ps[e.fs].x=math.random()*239
    ps[e.fs].y=math.random()*136
   end
  end
  
  local s=ps[i]
  if s.f~=true then
  	for h=#s.hist,1,-1 do
  	 if h==1 then
  	  s.hist[h].x=s.x
   	 s.hist[h].y=s.y
  	 end
  	 if h<#s.hist then
  	  s.hist[h+1].x=s.hist[h].x
  	  s.hist[h+1].y=s.hist[h].y
  	 end
   
  	 for j=0,1 do
  	  circ(
  	   s.hist[h].x,s.hist[h].y,
   	  ((h==1 and 3 or 2-j)+(#s.hist-h)/4)/2,
  	   12+j)
  	 end
  	end
  	s.x=(s.x+s.dx)%240
  	s.y=(s.y+s.dy)%136
  
  	--local v={x=s.dx,y=s.dy}
  	--local u=rot2d(v,t)
  --s.dx=u.x
  --s.dy=u.y
  	s.dx=s.dx+math.sin(t*.26*4*8)*.05
  	s.dy=s.dy+math.sin(t*.26*4)*.05
  
   for t=1,#pe do
    local v={x=s.x-pe[t].x,y=s.y-pe[t].y}
    if length(v)<5 and pe[t].f ~= true then
     --fe[#fe+1]={x=s.x,y=s.y}
     s.f=true
     pe[t].f=true
     pe[t].c=60*4
     pe[t].fs=i
    end
   end
  end
  
 end
 
 
 print("Game of Life",80,130,12)
end
