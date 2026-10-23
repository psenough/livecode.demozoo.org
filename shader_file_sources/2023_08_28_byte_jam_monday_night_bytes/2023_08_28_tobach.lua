--helllooooooo :)
--aaaaand we're off!!
--greetz to alia jtruk and totetmatt <3

sin=math.sin
cos=math.cos
abs=math.abs

function TIC()
cls(8)
t=time()/100

--this one's gonna take a while
--to cook ;)

fv=-abs(sin(t/4)*16)
fv2=-abs(sin(t/4-0.2)*32)
fv3=-abs(sin(t/4-0.4)*32)
fv4=-abs(sin(t/4-0.6)*32)
fv5=-abs(sin(t/4-0.8)*32)

for i=0,16 do
 rect(0+i*22,0,20,136,6)
 rect(0-2+i*22,0,2,136,5)
end

 rect(20,10,80,80,12)
 rect(22,12,76,76,10)
 rect(16,85,100,6,12)

for i=0,32 do
 line(60-i,80+i,170+i,80+i,13)
end
	rect(60,50,110,30,14)
 rect(28,113,175,24,14)

 elli(115,98,18,4,14)
 elli(115,96,18,4,15)

 elli(70,98,18,4,14)
 elli(70,96,18,4,15)

 elli(160,98,18,4,14)
 elli(160,96,18,4,15)
 
 for i=0,12 do
  elli(115+sin(i/2)*16,95+cos(i/2)*4,1,2,3+math.random()*2)
 end

elli(120,85+fv,32,11,0)
elli(120,85+fv,30,9,14)
elli(120,83+fv,30,7,15)
rect(151,83+fv,25,3,15)
rect(151,84+fv,25,3,14)
for i=0,8 do
 line(180,80+i+fv,240,78+i,2)
end
elli(170,83+fv,15,8,4)

for i=0,5 do
 circ(44+(i*28),128,5,1)
end

--sosig :)
for i=0,8 do
 circ(105+sin(i/4-1+sin(t/2)/2)*12,68+cos(i/4-1+sin(t/2)/2)*12+fv3,4,2)
end
for i=0,8 do
 circ(105+sin(i/4-1+sin(t/2)/2)*12,68+cos(i/4-1+sin(t/2)/2)*12-2+fv3,1,3)
end

--egg
for i=0,18 do
 circ(115+sin(i+t/8)*4,78+cos(i+t/8)*2+fv2,2,4)
 circ(115+sin(i+t/8)*(8+fv2/8+2),78+cos(i+t/8)*4+fv2,2,12)
end
for i=0,30 do
 circ(115+i,68+sin(i/2)*(2+sin(t/2+1))+fv5,1,1)
 circ(115+i,68+sin(i/2)*(2+sin(t/2+1))+2+fv5,1,2)
 circ(115+i,68+sin(i/2)*(2+sin(t/2+1))+4+fv5,1,1)
 circ(115+i,68+sin(i/2)*(2+sin(t/2+1))+6+fv5,1,2)
end
for i=0,8 do
 circ(135+sin(i/4-1-sin(t/2+1)/2)*12,68+cos(i/4-1-sin(t/2+1)/2)*12+fv4,4,2)
end
for i=0,8 do
 circ(135+sin(i/4-1-sin(t/2+1)/2)*12,68+cos(i/4-1-sin(t/2+1)/2)*12-2+fv4,1,3)
end

end
