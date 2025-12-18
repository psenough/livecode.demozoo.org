
grid={
{0,0,0,0,0,0},
{0,0,1,0,0,0},
{0,0,0,1,0,0},
{0,1,1,1,0,0},
{0,0,0,0,0,0},
{0,0,0,0,0,0},
}
og=grid

function alive(x,y)
 if grid[y+1][x+1]>=1 then
   return 1
 else
   return 0
 end
end

p={}
r=math.random
function addp(x,y)
 p[#p+1]={x+r()*10-5,y+r()*10-5,r(),r(),r()}
end

function step()
 local new={}
 for y=0,5 do
 new[y+1]={}
 for x=0,5 do
  local n=alive(x,y)*9
  for dx=-1,1 do
  for dy=-1,1 do
   n=n+alive((x+dx+6)%6,(y+dy+6)%6)
  end
  end
  if n==3 or n==12 or n==13 then
   new[y+1][x+1]=1
   if grid[y+1][x+1]<1 then
     new[y+1][x+1]=3
   end
  else
   new[y+1][x+1]=grid[y+1][x+1]*0.8
   if grid[y+1][x+1]>0.99 then
    for j=1,5 do 
    addp((16*x-tt/4)%96+72,(16*y-tt/4)%96+20)
    end
   end
  end
 end
 end
 grid=new
end

tt=0
function TIC()
 t=0
 rect(0,0,240,136,0)
 for y=1,6 do
 for x=1,6 do
   if grid[y][x]<1 then
     grid[y][x]=grid[y][x]*0.9
   end
   s=7*math.sqrt(grid[y][x])
   elli((16*x-tt/4)%96+72,
    (16*y-tt/4)%96+20,s,s,
    (grid[y][x]*12)^2/12)
   if grid[y][x]>1 then
     grid[y][x]=math.sqrt(grid[y][x])
   end
 end
 for i=1,#p do
  s=p[i][3]*5
  c=p[i][3]*15
  elli(p[i][1]+16,p[i][2]+16,s,s,c*c/16)
  p[i][1]=p[i][1]-p[i][4]/3
  p[i][2]=p[i][2]-p[i][5]/3
  p[i][3]=p[i][3]-0.01
 end
 
 for i=1,#p do
  if not p[i] then break end
  if p[i][3]<0 then
   p[i]=p[#p]
   table.remove(p,#p)
  end
 end
 
 end
 tt=tt+1
 if tt%16>14 then step() end
 print("@chordbug",2,2)
end