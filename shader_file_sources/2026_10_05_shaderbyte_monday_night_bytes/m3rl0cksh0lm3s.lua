-- ello dis is merlock
-- greetz to: muffintrap, altiga,
--            gasman, finkel, jtruk
--            aldroid, d/v, aart1256,
--            canmom, and you!
-- i'm starting to get something 3d-ish already :P
t=0
m=math
sin=m.sin
cos=m.cos
function TIC()
cls()
t=t+0.1
for i=0,71 do
circ(120+m.tan(i/3+t/4)*64+2,2*i,4+sin(i+t)*2,i+t*4)
circb(120+m.tan(i/3+t/4)*64,2*i,4+sin(i+t)*2,i+t*4)
end
for i=0,255 do
circ(120+sin(i*1.5/6+t/4)*48,68+cos(i/3)*48,2,i/128+t)
end
for i=0,1 do
print("discolissajous field",66,i,i+-t)
end
end