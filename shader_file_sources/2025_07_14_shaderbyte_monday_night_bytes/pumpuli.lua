W,H=240,136
BPM=126
STP=2
PARTS=2000

abs=math.abs
sin=math.sin
cos=math.cos
rnd=math.random
max=math.max
math.randomseed(20)
prt={}
flw={}

function BOOT()
	init_parts()
	init_flow()
	cls(0)
end

function init_parts()
	for i=1,PARTS do 
		pt={
			x=rnd(W),
			y=rnd(H),
			c=4,
			s=0,
			xv=rnd(-2,2),
			yv=rnd(-2,2),
		}
		prt[i]=pt
	end
end	

function init_flow()
	for x=0,W do
		for y=0,H do
			flw[x+y*W+1]={x=rnd(-2,2),y=rnd(-2,2)}
		end
	end
end

frm=0
fr=0
pr={}
pairs={
{12,0},
{5,8},
{1,4},
{15,3},
{3,7},
}

function TIC()
	frm=frm+1
	fr=dt(frm,STP)
	t=time()/60000*BPM
	ti=t//1
	tf=t-ti
	tf=tf*tf*tf
	bg=(t//1)
	pr=pairs[bg%#pairs+1]
	vbank(1)
		cls()
	vbank(0)
	for xx=0,W-1,STP do
	for yy=0,H-1,STP do
		x=xx+fr%STP
		y=yy+(fr//STP)%STP
		i=x+y*W
		--if rnd(100)<40 then 
			p=peek4(i)
	 -- if p~=pr[1] or rnd(100)<5 then
			poke4(i,max(0,p-1))
		--	end
		--end
	end
	end
	
	if ti%32==0 then 
		init_flow()
	end
	for i=1,PARTS do
		pt=prt[i]
		ii=(pt.x//1+(pt.y//1)*W)%#flw+1
		fll=flw[ii]
		xv=fll.x
		yv=fll.y
		pt.x=pt.x+pt.xv
		pt.y=pt.y+pt.yv
		pt.x=pt.x%W
		pt.y=pt.y%H
		fll.x=xv*.2+pt.xv*3.1
		fll.y=yv*.2+pt.yv*3.1
		fll.x=fll.x*.4
		fll.y=fll.y*.4
		v=xv*xv+yv*yv
		a=vqt(abs(pt.x/W-.5)*W//1)*200*3.1415
		pt.s=a*.01
		if v>2 then 
			fll.x=fll.x*.2+cos(a+pt.y/H+ti+tf)
			fll.y=fll.y*.2-sin(a+pt.y/H+ti+tf)
		end
		if v<.1 then 
			fll.x=rnd(-2,2)
			fll.y=rnd(-2,2)
		end
		pt.xv=pt.xv*.8+xv*.2
		pt.yv=pt.yv*.8+yv*.2
		pt.xv=pt.xv*.95
		pt.yv=pt.yv*.95
		pt.s=pt.s*.999+(pt.xv*pt.xv+pt.yv*pt.yv)
		c=pt.s>2 and 12 or pt.c
		if c==12 and frm>10 then 
			vbank(1)
			circ(pt.x,pt.y,pt.s,c)
		end
		vbank(0)
		circ(pt.x,pt.y,pt.s,pt.c)
		flw[ii]=fll
		prt[i]=pt
	end
	
end

function BDR(i)
	poke(0x3FF8,bg%4+1)
end


function dt(f,s)
	local out=f
 local si=s//1
 local lu3={0,4,7,1,5,8,2,6,3}
 if s==3 then 
 	out=lu3[f//1%#lu3+1]
 end
 local lu4={0 ,5 ,2 , 7
           ,8 ,13,10,15
           ,3 ,6 ,11,14
           ,1 ,4 ,9 ,12}
       --[[{0 ,1 ,2 , 3
           ,4 ,5 ,6 , 7
           ,8 ,9 ,10,11
           ,12,13,14,15}--]]
 if s==4 then 
 	out=lu4[f//1%#lu4+1]
 end
	return out
end