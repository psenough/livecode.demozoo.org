function TIC()t=time()/100
for y=0,136 do
for x=0,240 do
local v = math.sin(t/32+y/8+x/256*y)
local col = math.floor(y/512+v*8+x-t)
pix(x,y,col+x)
end
end
end
