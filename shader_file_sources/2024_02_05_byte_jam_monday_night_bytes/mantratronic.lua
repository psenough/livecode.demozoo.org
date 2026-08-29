-- hi mt here
-- bit slow today, so started early
--
-- greets to aldroid, catnip, jtruk,
-- raccoonviolet, vurpo, and polynomial

M=math
S=M.sin
C=M.cos
PI=M.pi

quads={}

-- offset x/y, bend x/y, angle main/bend
reeds={}

function drawQuad(q)
ttri(q[1],q[2],q[3],q[4],q[5],q[6],
     0,0,0,9,99,0,2)
ttri(q[3],q[4],q[7],q[8],q[5],q[6],
     0,9,99,9,99,0,2)
end

LEN=240
WID=5

function rot(X,Y)
ret={}
ret.d=(X^2+Y^2)^.5
ret.a=M.atan2(Y,X)
return ret
end


function TIC()t=time()/32
vbank(0)
cls()
rect(0,0,99,1,15)
rect(0,1,99,1,14)
rect(0,2,99,6,6)
rect(0,8,99,1,14)
rect(0,9,99,1,15)

bt=(t//10)%40
t=t/10

vbank(1)
cls()

reeds={}

-- offset x/y, bend x/y, angle main/bend
reeds[1]={ox=0,oy=0, bx=0,by=0, am=t/10, ab=t/10+PI}

for i=2,bt do
reeds[i]={ox=i*.7,oy=i*.7, bx=-1.5*i,by=-i, am=t/10+(i-2)*PI/2, ab=t/10+(i-2)*PI/2+S(i)/100}
end

quads={}
qi=1
for i=1,#reeds do
	local X1=reeds[i].ox+LEN/2 
	local Y1=reeds[i].oy+WID/2 
	local X2=reeds[i].ox+reeds[i].bx 
	local Y2=reeds[i].oy-WID/2
	local X3=reeds[i].ox+LEN/2 
	local Y3=reeds[i].oy-WID/2
	
	local p1=rot(X1,Y1)
	local p2=rot(X1,Y2)
	local p3=rot(X2,Y1)
	local p4=rot(X2,Y2)
	local p5=rot(X2,Y1)
	local p6=rot(X3,Y2)
	local p7=rot(X3,Y1)
	
	quads[i*2-1]={p1.d*S(p1.a+reeds[i].am)+120,
										 p1.d*C(p1.a+reeds[i].am)+68,
											p2.d*S(p2.a+reeds[i].am)+120,
										 p2.d*C(p2.a+reeds[i].am)+68,
										 p3.d*S(p3.a+reeds[i].am)+120,
										 p3.d*C(p3.a+reeds[i].am)+68,
											p4.d*S(p4.a+reeds[i].am)+120,
										 p4.d*C(p4.a+reeds[i].am)+68}
	quads[i*2]={p4.d*S(p4.a+reeds[i].am)+120,
										 p4.d*C(p4.a+reeds[i].am)+68,
											p5.d*S(p5.a+reeds[i].am)+120,
										 p5.d*C(p5.a+reeds[i].am)+68,
										 p6.d*S(p6.a+reeds[i].ab)+120,
										 p6.d*C(p6.a+reeds[i].ab)+68,
											p7.d*S(p7.a+reeds[i].ab)+120,
										 p7.d*C(p7.a+reeds[i].ab)+68}
end

for i=1,#quads do
 drawQuad(quads[i])
end

vbank(0)
cls()

-- hmmm. 
by=fft(5)*20

pl=print("HAPPY",0,140,12,false,6)
print("HAPPY",120-pl/2,10+by,12,false,6)
pl=print("ST.BRIGID'S DAY",0,140,12,false,3)
print("ST.BRIGID'S DAY",120-pl/2,42+by,12,false,3)


pl=print("HAPPY",0,140,12,false,6)
print("HAPPY",120-pl/2,60+by,12,false,6)
pl=print("IMBOLC",0,140,12,false,6)
print("IMBOLC",120-pl/2,92+by,12,false,6)

end
