-- hellllllllllo
r,t,t2,s,ta=math.random,0,0,math.sin,{}
function SCN(w)
for k=0,47 do
	poke(0x3fc0+k,k//3*16*(s(k%3+math.abs(w-68)/30+(k>24 and k/8 or 0)+t*.01+(fft(k%7)*pu>0.1 and 4 or 0))*.5+.5))
end
end

function TIC()
pu=0.5
t=t+0.01+fft(1)*pu+fft(4)*pu
t2=t2+0.007+fft(3)*pu+fft(7)*pu
po=(s(t/20)>0.7) and 3 or 1
for i=0,299 do
x,y=r(240)-1,r(136)-1
circb(x,y,2,pix(x,y)*.7)
end
for i=1,100 do
	h=i*0.15+t*0.05
	x,y=s(h)*60*po+120,s(h*.7)*30*po+68
	x,y=x+s(h*0.6)*40,y+s(h*0.4)*20
	x,y=x+s(h*1.2+t2*.07)*15,y+s(h*1.4+t2*.1)*10
	if i>1 then
		o=s(t2*.2+i*.07)+s(t2*.1+i*.04)
		u,v=(x-a),(y-b)
		m=math.sqrt(u*u+v*v)
		for j=-5,5 do
			sq=j/10
			line(x+v*sq,y-u*sq,a+v*sq,b-u*sq,i%8+8)
			circ(x+v*(sq+o*2),y-u*(sq+o*2),m*.5,(i+j/3)%8)
		end
		if i%20==0 then
			circ(x,y,fft(i//20)*50*po*pu,15)
		end
	end
	ju=math.floor(r(100))+1
	ju=(i+50)%100+1
	cu=ta[ju]
	if cu and fft(i%7)*pu>0.2 then
		line(x,y,cu[1],cu[2],14)
		for l=0,1,.1 do
		circb(x*l+cu[1]*(1-l),y*l+cu[2]*(1-l),4,14)
		end
	end
	a,b=x,y
	ta[i]={x,y}
end
end
