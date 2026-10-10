s=math.sin
c = math.cos
vx = 1
vy = 1
cx = 10
cy = 10
cls()
function TIC()t=time()//100
for i=0,136,10 do
	for j=0,240,10 do
		rect(j+math.random(0,10),i,j+5,i+4,t+math.random(0,1))
end end


end

function OVR()
cx = cx + vx
cy = cy + vy
if cx > 240 or cy < 0 then
	vx = -vx
end
if cy > 136 or cy < 0 then
	vy = -vy
end

for i=1,8 do
	circ(cx,cy,20-(i*2),i+(t%4))
 end
-- ^.^

print("quick, hide the glitchy part! It's intentional!",0,4,12)

end
function SCN(l)
 poke(0x3FF9,math.random(0,5))
end
