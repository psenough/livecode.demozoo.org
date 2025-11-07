-- Hi! I don t know wtf I m doing
 
function TIC()t=time()//25
for y=0,136 do for x=0,240 do
pix(x*math.sin(t)*20,y,
(x&y&t)>>3)

pix(x,y*math.sin(t)*100,
(x|y+t)>>1)
end end end
