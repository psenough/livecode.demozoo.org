m=math c,s=m.cos,m.sin
function TIC()t=time()*.001
for y=136,0,-1 do for x=0,240 do
v=m.asin(s(y-x+t)*.5)*5pix(x,y,y*.1+v%4+t*9)end
for i=0,11 do q=60x,y=c(i+t)*q+120,s(i+t)*q+68
circ(x,y,10+s(t),t*10+10+i%6)end line(120,68,c(t)*q+120,s(-t)*q+68,t)end end