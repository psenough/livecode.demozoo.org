particles={}
count=64
t=0

function BOOT()
 for i=1,count do
  particles[i]={
   x=math.random(0,240),
   y=math.random(0,136),
   dx=math.random()*2+1,---1.5,
   dy=math.random()*3-2.5
  }
 end
 
 vbank(1)
 for i=0,3 do
  print("=^^=",195-i,i,i+8,0,2)
 end
 for i=0,3 do
  print("=^^=",i,i,i+1,0,2)
 end
 for i=0,3 do
  print("=^^=",i,120-i,7-i,0,2)
 end
 for i=0,3 do
  print("=^^=",195-i,120-i,15-i,0,2)
 end
 vbank(0)
end

function length(v)
 return (v.x*v.x+v.y*v.y)^0.5
end

function TIC()
 cls()
 
 t=math.max(0,t*0.9+fft(1)/3)
  
 local parts2={}
 for i=1,count do
  parts2[i]=particles[i]
 end
  
 for i=1,count do
  local p=particles[i]
  --pix(p.x,p.y,12)
  
  table.sort(parts2, function(a,b)
   local v1={x=a.x-p.x,y=a.y-p.y}
   local v2={x=b.x-p.x,y=b.y-p.y}
   return length(v1)<length(v2)
  end)
  
  local p2=parts2[2]
  local p3=parts2[3]
  
  --local v={x=p2.x-p.x,y=p2--.y-p.y}
  --local l=length(v)
  --if l<10 then
   --p.x=p.x-(v.x)/l
   --p.y=p.y-(v.y)/l
  --end
  
  local col=(p.x+p.y+time()/10)//16
  tri(
   p.x,p.y,p2.x,p2.y,p3.x,p3.y,col-1)
  for x=0,1 do
   for y=0,1 do
    line(p.x+x,p.y+y,p2.x+x,p2.y+y,col)
    line(p.x+x,p.y+y,p3.x+x,p3.y+y,col)
   end
  end
  p.x=(p.x+p.dx)%240
  p.y=(p.y+p.dy)%136
  particles[i]=p
 end
 
 local hpos=100-t*10
 rect(175,hpos,30,40,3)
 elli(150,120,70,40,3)
 
 --head
 elli(175,hpos-17,10,10,3)
 elli(175,hpos-16,8,10,4)
 elli(205,hpos-17,10,10,3)
 elli(205,hpos-16,8,10,4)
 elli(190,hpos+1,30,20,1)
 elli(190,hpos,30,20,3)
 elli(190,hpos+3,20,10,12)
 rect(170,hpos-7,41,10,3)
 circ(180,hpos-7,5,12)
 circ(180,hpos-7,3,0)
 circ(200,hpos-7,5,12)
 circ(200,hpos-7,3,0)
 
 for i=0,15 do
  circ(80+i*7,
  130-math.max(0,math.sin(time()/100+i/4))*2*i,
  7,3+i%2)
 end
end
