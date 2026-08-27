-- pumpuli here o/
W,H=240,136
PI=3.1415

m=math
abs=math.abs
exp=math.exp
log=math.log
min=math.min
max=math.max
rnd=math.random

lft={}
mft={}
sft={}

function lerp(a, b, t)
	return a + (b - a) * t
end

function rot(xx,yy,r)
    local x,y=xx,yy
    x=m.cos(r)*xx-m.sin(r)*yy
    y=m.cos(r)*yy+m.sin(r)*xx
    return x,y
end

function BOOT()
	for i=1,1024 do
		lft[i]=0
		mft[i]=0
		sft[i]=0
	end
	cls(0)
end

BPM=175

tf=0
frm=0

tx={"jtruk","weatherman115","g33kou","littletheremin","catnip","gasman","zool","suule"}

function TIC()
	frm=frm+1
	t=time()/60000*BPM
	tf=lerp(tf,t//2,.5)
	for i=1,1024 do
		lft[i]=ffts(i-1,i+1)
		if lft[i]>mft[i] then mft[i]=lft[i] else mft[i]=max(0,mft[i]*.9) end
		sft[i]=sft[i]/mft[i]
	end
	vbank(0)
	for y=0,H,2 do 
		for x=0,W,2 do
			X=x/W
			Y=y/H
			
			Y=Y/(W/H)
			X=X-.5
			Y=Y-.3
			
			X,Y=rot(X,Y,t*.02+X)
			for i=1,16 do
				X=abs(X)-.1
				X,Y=rot(X,Y,tf*PI/16+t*.01+Y*.05)
			end
			--fr=exp((abs(Y)+.1)*14)
			fr=abs(Y)*128
			--fr=min(1023,max(0,fr))
			fr=fr%512
			f=ffts(fr)*10
			c=((X*20)//1+t//1-f//1)>>3
			c=c%4+8*((X+f*.01)+tf%2)
			c=c+f*0.5
			pix(x+frm%2,y+(frm//2)%2,c)
		end 
	end 
	vbank(1)
	for i=0,W*H do
		x=i%W
		y=i//W
		if rnd(100)<20 then
			pix(x,y,0)
		end
	end
	
	if t-t//1<0.25 then
		ttx=tx[t//2%#tx+1]
		sn=t%2
		w=print(ttx,0,-24,0,1,5-sn*2)
		x=W/2-w/2
		y=H/2-12/(1+sn)
		print(ttx,x+1,y-1,t%6+3,0,5-sn*2)
		print(ttx,x-1,y-1,t%6+3,0,5-sn*2)
		print(ttx,x+1,y+1,t%6+3,0,5-sn*2)
		print(ttx,x-1,y+1,t%6+3,0,5-sn*2)
		print(ttx,x  ,y   ,12,0,5-sn*2)
	end
	
end

function BDR(i)
	local ii=abs(i-H/2-2)
end
