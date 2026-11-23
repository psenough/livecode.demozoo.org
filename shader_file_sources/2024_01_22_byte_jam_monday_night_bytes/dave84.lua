--lets get a grid going...
local GRID_SIZE = 100
local PARTICLE_COUNT = 1000
local W,H=240,136
local vectors = {}
local particles = {}

function noise(x,y,t)
 local n = math.sin(x*fft(5)*10+t) + math.cos(y+t)
 return (n+1)/2
end

for x=0,W/GRID_SIZE do
 vectors[x] = {}
 for y=0,H/GRID_SIZE do
  --make noise less noisy later
  vectors[x][y] = {math.random(),math.random()}
 end
end

--particles do
for i=1,PARTICLE_COUNT do
 table.insert(particles,
 {
  x=math.random(W),
  y=math.random(H),
  speed = math.random(4)
 })
end



--cls() --team cls()

function TIC()
 t=time()/1000
 cls()
 
 for x=0,W/GRID_SIZE do
 for y=0,H/GRID_SIZE do
  --make noise less noisy later
  vectors[x][y] = {noise(x,y,t),noise(x,y,t)}
  end
 end
 
 --lets update those particles...
 for _,p in ipairs(particles) do
  local gridX, gridY = math.floor(p.x/GRID_SIZE),math.floor(p.y/GRID_SIZE)
  if gridX >= 0 and gridX <= W/GRID_SIZE and gridY >= 0 and gridY <= H/GRID_SIZE then
   local vector = vectors[gridX][gridY]
  -- p.speed = 1+fft(4+gridX~gridY)*10
   p.x = p.x + vector[1] * p.speed
   p.y = p.y + vector[2] * p.speed
  end

  if p.x < 0 then p.x = p.x+W elseif p.x > W then p.x=p.x -W end
  if p.y < 0 then p.y = p.y+H elseif p.y > H then p.y=p.y -H end
 end
 
 for _,p in ipairs(particles) do
  circ(p.x,p.y,0,p.speed)
 end

end
