t=0
M=math
S=M.sin
C=M.cos
R=M.random

T=0
m1=0
m2=0
m3=0
m4=0
function TIC()
	cls()
	
	for r=3,0,-1 do
		for i=0,3 do
		 x=((r+i)*47)%240
			y=100-M.abs(S(i+m1))*5
			h=(20+i*10)*(r+1)
			hH=20+S(T*i)*10
			lH=10+(10*(r+i)%40)
			c=4+i*2
			drawRobot(x,y,h,hH,lH,c*2,x*y*.001)
		end
	end

	xOfs=m1
	yOfs=m2
	for y=0,136 do
		for x=0,239 do
			p=pix(x,y)
				if((x+xOfs)%20<4 and ((y+yOfs)%20<4))then
					pix(x,y,p+1)
				end
		end
	end
	
	for c=0,10 do
		print("Discooo",10+C(m2+c)*10,5+S(m1+c)*5,c,1,5)
	end
	print("I have no idea what this is",50+S(T*.3)*40,120,12)

	T=T+0.1

	m1=m1+fft(0)*.6
	m2=m2+fft(1)*.6
	m3=m3+fft(1)*.3
	m4=m4+fft(0)*0.2
end

function drawRobot(x,y,h,headH,legH,c,ofs)
 c1=(c%15)+1
 c2=((c+1)%15)+1
	bodyX=x-legH+S(m1+ofs)*20
	waistY=y
	bodyH=h/2
	bodyW=40+S(m1*10)*10
	headY=waistY-bodyH
	headX=bodyX
	headW=20
	headH=headH
	feetY=waistY+legH
	-- body
	rect(bodyX-bodyW/2,waistY-bodyH,bodyW,bodyH,c1)

	-- head
	rect(bodyX-headW/2,headY-headH,headW,headH,c2)

	-- leye	
	lEyeY=headY-headH/2+S(T*1.2)*3
	elli(headX-10,lEyeY,5,3,12)
	circ(headX-10+S(T),lEyeY,3,0)

	-- reye
	rEyeY=headY-headH/2+S(T)*3
	elli(headX+10,rEyeY,5,3,12)
	circ(headX+10+S(T),rEyeY,3,0)

	lFootX=x-10+S(m2)*5
	rFootX=x+10+S(m3)*5
	tri(bodyX-10,waistY,bodyX-15,waistY,lFootX,feetY,12)
	tri(bodyX+10,waistY,bodyX+15,waistY,rFootX,feetY,12)

	lShoulderX=bodyX-bodyW/2
	lShoulderY=headY
	lArmX=lShoulderX+C(m4)*20
	lArmY=lShoulderY+S(m4)*20
	tri(lShoulderX,lShoulderY,lShoulderX,lShoulderY+2,lArmX,lArmY,12)

	lHandX=lArmX+C(m3)*10
	lHandY=lArmY+S(m3)*10
	tri(lArmX,lArmY,lArmX,lArmY+4,lHandX,lHandY,12)

	rShoulderX=bodyX+bodyW/2
	rShoulderY=headY
	rArmX=rShoulderX-C(m4)*20
	rArmY=rShoulderY-S(m4)*20
	tri(rShoulderX,rShoulderY,rShoulderX,rShoulderY+4,rArmX,rArmY,12)

	rHandX=rArmX+C(m2)*10
	rHandY=rArmY+S(m2)*10
	tri(rArmX,rArmY,rArmX,rArmY+4,rHandX,rHandY,12)
end
