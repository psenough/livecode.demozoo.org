W,H=240,136
STP=2
BPM=138

abs=math.abs
min=math.min
max=math.max
sin=math.sin
cos=math.cos


co=.7
ed=1.2
cn=4
krn={
{co,ed,co},
{ed,cn,ed},
{co,ed,co}}

function bc_fft(a)
	local m=a%1024
	return fft(m)
end

frm=0

hi={15,12,3,4}
lw={0,1,2,14}
txt={"a","b","c"}
wind=0
bn={}
function TIC()
	frm=frm+1
	fr=dt(frm,STP)
	t=time()/60000*BPM
	ti=t//1
	tf=1-(t-ti)
	te=tf^4
	for i=1,6 do
		bn[i]=fft(2^(i+2),2^((i+2)+1))
	end
	vbank(0)
	for yy=0,H,STP do 
	for xx=0,W,STP do
		x=xx+fr%STP
		y=yy+(fr//STP)%STP
		Y=y/H-.5
		X=x/W-.5
		fq=abs(X/4)^0.8*W
		f=ffts(fq,fq+2)*(fq/2+1)
		f=f+fft(fq)*16
		c=(f*10-abs(Y)*400)
		c=(c-(te-ti)*64)//(H)
		ind=ti//2+(X+te/2+Y/1.5+.4+ti)*1.7
		ind=ind//1
		wind=ind
		if X>.2 then ind=0 else ind=1+ind end
		col=(c%2)==0 and lw[ind%#lw+1] or hi[ind%#hi+1]
	
		pix(x,y,col)
	end 
	end 
	vbank(1)
	for x=0,W/6 do
			c=bn[x%#bn+1]*4
			rect(x*(W/6),H/2-c/2,W/6,c,max(0,min(c/4,4)))
	end
	blur(fr,STP,3)
	rectb(0,0,W,H,tf*4)
	txt[1]=t
	txt[2]=fft(0)*100//1
	txt[3]=tf*10//1
	x=W/3*2+12
	y=0
	SC=5
	for i=0,#txt-1 do
		print(txt[i+1],x,(y+i*(6*SC)+(-te+ti)*16)%(H+(SC*12))-SC*6,4,1,SC)
	end
	txt[4]=(y+4*(6*SC)+(-te+ti)*16)%(H+SC*12)-SC*6
	txt[5]=lw[wind%#lw+1]
	txt[6]=hi[wind%#lw+1]
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


function blur(frm,stp,fd)
	local x,xx,xxx=0,0,0
	local y,yy,yyy=0,0,0
	for xxx=0,W,stp do
		for yyy=0,H,stp do
			x=xxx+(frm)%stp
			y=yyy+(frm//stp)%stp
			px=peek4(x+y*W)
			local nb=0
			for xx=1,3 do
				for yy=1,3 do
					px2=peek4(x+xx-2+(y+yy-2)*W)
					nb=nb+px2/krn[yy][xx]
				end
			end
			c=px/8
			c=(c+nb/8)/(1.15+fd*.1)
			c=math.max(0,math.min(15,c))
			pix(x,y,c)
		end
	end
end


function rot(xx,yy,r)
    local x,y=xx,yy
    x=math.cos(r)*xx-math.sin(r)*yy
    y=math.cos(r)*yy+math.sin(r)*xx
    return x,y
end
