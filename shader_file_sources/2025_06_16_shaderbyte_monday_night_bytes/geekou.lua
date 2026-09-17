-- hi everyone, recovered from Nova ? :)

sin=math.sin
cos=math.cos

function rot(x,y,a)
	local xr=x*sin(a)-y*cos(a)
	local yr=x*cos(a)+y*sin(a)
	return xr,yr
end

function rec(c,ox,oy,a,col,p)
	local x1,y1,x2,y2
	local t={}
	c=c/2
	x1,y1=rot(-c,-c,a)
	x2,y2=rot(c,-c,a)
	t[1]={x1,y1,x2,y2}
	x1,y1=rot(c,-c,a)
	x2,y2=rot(c,c,a)
	t[2]={x1,y1,x2,y2}
	x1,y1=rot(c,c,a)
	x2,y2=rot(-c,c,a)
	t[3]={x1,y1,x2,y2}
	x1,y1=rot(-c,c,a)
	x2,y2=rot(-c,-c,a)
	t[4]={x1,y1,x2,y2}
	for i=1,4 do
		line(t[i][1]+ox,t[i][2]+oy,t[i][3]+ox,t[i][4]+oy,col)
		line(t[i][1]+ox,t[i][2]+oy,p[i][1]+ox,p[i][2]+oy,col)
		line(t[i][3]+ox,t[i][4]+oy,p[i][3]+ox,p[i][4]+oy,col)
	end
	return t
end

T=0
p={{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}
function TIC()
	T=T+1
	cls()
	for i=0,6 do
		p=rec(i*20, 240/2+sin(T/20)*10, 136/2+cos(T/20)*10,	T/200*(i+1), i+2, p)
	end
end
