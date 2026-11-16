t=0s=math.sin
x=120y=68w=50TIC=load"cls()circ(x,y,y-t%4,1)for i=-1,1,2 do v=i*t/9r=w+i*9line(x,y,x+s(v)*r,y+s(v+11)*r,t/i%16)end for i=1,12 do print(i,x+s(i/2)*w,y+s(i/2+11)*w)end t=t+.1"
function SCN(a)for i=0,2 do poke(16323+i,s(a/25+i*2)*x+x)end end