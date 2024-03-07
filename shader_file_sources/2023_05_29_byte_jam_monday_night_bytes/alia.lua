abs=math.abs
sin=math.sin
max=math.max

fmax={}
flist={}
xcount=15
dcount=100

for i=1,255 do
 fmax[i]=0
 for d=0,dcount do
  local t={}
  for x=0,xcount do
   t[x+1]=0
  end
  flist[d+1]=t
 end
end

cls()
t=0

function TIC()
 cls()
 for i=0,xcount do
  for j=0,15 do
   local t=i*15+j
   fmax[t+1]=math.max(fmax[t+1],fft(t))
  end
 end
 
 for d=dcount,0,-1 do
  if d==0 then
   local t={}
   for x=0,xcount do
    local v=0
    for i=0,15 do
     local idx=x*15+i
     v=v+(fft(idx)/fmax[idx+1])/15
    end
    t[x+1]=v
   end
   flist[1]=t
  else
  	flist[d+1]=flist[d]
  end
 end
 
 local h=90
 local hx=xcount/2
 
 for dp=dcount,1,-1 do
  local y0=185-(dp/dcount)*150
  local y1=185-((dp-1)/dcount)*150
  local xs=0.1+1/(dp/dcount)^.4
 
 	for x=1,xcount do
 	 local a={
    x=((x-1-hx)*xs+hx)*16,
    y=y0-flist[dp][x]*h,
    c=flist[dp][x]
   }
 	 local b={
    x=((x-hx)*xs+hx)*16,
    y=y0-flist[dp][x+1]*h,
    c=flist[dp][x+1]
   }
   local c={
    x=((x-1-hx)*xs+hx)*16,
    y=y1-flist[max(1,dp-1)][x]*h,
    c=flist[max(1,dp-1)][x]
   }
   local d={
    x=((x-hx)*xs+hx)*16,
    y=y1-flist[max(1,dp-1)][x+1]*h,
    c=flist[max(1,dp-1)][x+1]
   }
   tri(
    a.x,a.y,
    b.x,b.y,
    c.x,c.y,
    -10*(a.c+b.c+c.c)/3-t/20
   )
 	 tri(
    b.x,b.y,
    c.x,c.y,
    d.x,d.y,
    -10*(d.c+b.c+c.c)/3-t/20
   )
   --line(
 	  --(x-1)*16,135-a*30-dp*2,
 	  --x*16,136-b*30-dp*2,
 	  --12+dp/15
 	  --)
  --elli(x*16,68,s*10,s*40,s*4)
 	end
 end
 
 t=t+1
end
