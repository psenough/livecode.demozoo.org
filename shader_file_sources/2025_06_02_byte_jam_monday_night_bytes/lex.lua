
-- oh okay here we go
-- I'm a little rusty and have
-- not much of a plan :D

function hsl2rgb(hsl)
 h,s,l = table.unpack(hsl)
 function f(n) k = (n+12*h)%12 a = s*math.min(l,1-l)
  return l-a*math.max(-1,math.min(k-3,9-k,1))
 end
 return f(0),f(8),f(4)
end


lines = {
{x1=0,y1=0,x2=10,y2=10}
}
num_lines = 64

dx1 = 1
dy1 = 1
dx2 = 2
dy2 = 2

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end


function step_lines()
 for i = 0,num_lines-2 do
  prev = lines[num_lines-1-i]
  if prev == nil then
  	lines[num_lines-i] = copy(lines[1])
  else
   lines[num_lines-i] = copy(prev)
  end
 end
 lines[1].x1 = lines[1].x1+dx1
 lines[1].y1 = lines[1].y1+dy1
 lines[1].x2 = lines[1].x2+dx2
 lines[1].y2 = lines[1].y2+dy2
 if lines[1].x1 > 240 then dx1 = -3 end
 if lines[1].x1 < 0 then dx1 = 3 end
 if lines[1].x2 > 240 then dx2 = -2 end
 if lines[1].x2 < 0 then dx2 = 5 end

 if lines[1].y1 > 136 then dy1 = -2 end
 if lines[1].y1 < 0 then dy1 = 2 end
 if lines[1].y2 > 136 then dy2 = -2 end
 if lines[1].y2 < 0 then dy2 = 3 end
end

function setcolor(num, r, g, b)
 poke(16320+num*3+0, r)
 poke(16320+num*3+1, g)
 poke(16320+num*3+2, b)
end

function init_colours()
  t = time()
  h = ((t/100)%360)/360
  s = 1
  for i=0,15 do
   l = (i*8)/255
   r,g,b = hsl2rgb({h,s,l})
   setcolor(i,math.floor(r*255),math.floor(g*255),math.floor(b*255))
  end
end

word = 0
lt = 0
function TIC()
 cls()
 init_colours()
 step_lines()
 for i=1,num_lines do
  local l = lines[i]
  line(l.x1,l.y1,l.x2,l.y2,16-(i/4))
 end
 if word==0 then print("Monday", 30, 60,0,0,5) end
 if word==1 then print("night", 40, 60,0,0,5) end
 if word==2 then print("bytes", 40, 60,0,0,5) end
 t = time()
 if t-lt > 1000 then
  lt = t
  word = (word + 1) % 3
 end
end
