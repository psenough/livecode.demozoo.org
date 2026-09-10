sin=math.sin
cos=math.cos
pi=math.pi
rand=math.random

t=0
str1="TRANS RIGHTS"
size=3

pal={
 {91,207,251},
 {245,171,185},
 {255,255,255},
 {245,171,185},
 {91,207,251},
}
cls()
for k=0,1 do
	vbank(k)
	for i=0,2 do
	 local c=pal[i+1]
	 local b=1
	 for j=0,4 do
	  poke(16320+i*15+j*3+3,c[1]*b)
	  poke(16320+i*15+j*3+4,c[2]*b)
	  poke(16320+i*15+j*3+5,c[3]*b)
	  b=b*.6
	 end
	end
end

cls()
for i=0,3 do
	local split=size*6/5
	local y=i*6*size
	local y2=135-(i+1)*8
	for j=0,4 do
		col=1+(j<3 and j or 4-j)*5+i
		clip(0,y+j*split,240,136)
		print(str1,0,y,col,0,size)
		print(str1,0,y+1,col,0,size)
		print(str1,1,y+1,col+1,0,size)
		rect(j*8,y2,8,8,col+1)
		rect(j*8+1,y2+1,7,7,col)
	end
end
clip()
memcpy(0x4000,0,16320)
cls()

uv={
 {x=0,y=0},
 {x=size*6,y=0},
 {x=0,y=size*6},
 {x=size*6,y=size*6}
}

function char(i,p,s,r)
 local h=s*cos(r)
 local yo=sin(r)*s/10
 local uvox=size*6*i
 
 for i=8,-8,-1 do
  local y=p.y+yo*i
  local uvoy=((((yo*i+74)+(i+8)//4)//4)*size*6)-(size*2)*6+2
	 ttri(
	  p.x-s,y-h,
	  p.x+s,y-h,
	  p.x-s,y+h,
	  uv[1].x+uvox,uv[1].y+uvoy,
	  uv[2].x+uvox,uv[2].y+uvoy,
	  uv[3].x+uvox,uv[3].y+uvoy,
	  2,0
	 )
	 ttri(
	  p.x+s,y-h,
	  p.x-s,y+h,
	  p.x+s,y+h,
	  uv[2].x+uvox,uv[2].y+uvoy,
	  uv[3].x+uvox,uv[3].y+uvoy,
	  uv[4].x+uvox,uv[4].y+uvoy,
	  2,0
 	)
 end
end

function block(p,s,l,c)
 local col=c*5+1+4
 local d={
  x=(p.x-120)/120,
  y=(p.y-68)/68
 }
 for i=0,l do
 	rect(
   p.x+i,
   p.y+i,
   s,
   s,
   col-i/2)
 end
end

function TIC()
 if(1==1) then
	 vbank(0)
	 memcpy(0,0x4000,16320)
	 
	 vbank(1)
	 cls()
	 for i=0,#str1-1 do
	  local ph=t/20+i
	 	char(i,{x=10+i*20,y=-sin(ph)*10+98},10+cos(ph*2)*4,sin(ph))
	 end
		
		print("it's that day of the year when it's time to ",0,1,5)
		print("it's that day of the year when it's time to ",0,0,1)
		print("decloak. So hi everyone, I'm catnip and i'm ",0,11,10)
		print("decloak. So hi everyone, I'm catnip and i'm ",0,10,6)
		print("transgender. I guess that's all I need to",0,21,15)
		print("transgender. I guess that's all I need to",0,20,11)
		print("say. Greets to aldoid, px, weatherman115,",0,31,10)
		print("say. Greets to aldoid, px, weatherman115,",0,30,6)
		print("immibis AND YOU. Fuckings to terfs :3",0,41,5)
		print("immibis AND YOU. Fuckings to terfs :3",0,40,1)
	 vbank(0)
	 cls()
		math.randomseed(t//60)
		for y=13,0,-1 do
		 for x=23,0,-1 do
			 local l=math.min(8,fft(rand()*30//1)*30)
			 block({x=x*10,y=y*10},10,l,(rand()*3)//1)
			end
		end
 end
 t=t+1	
end
