p={}
TIC=load[[
v=0
for x=0,239 do
h=(p[x+1] or 0)*0.9+(fft(x)*(x+1)^.5)
p[x+1]=h
v=v*0.9+h
h=136-v*1.5
line(x,136,x,h,(v^.5)*2+3)
if math.random()>v/16 then 
circ(x,h,4,x%3+5)
end
end]]
SCN=load'y=... for x=0,239 do pix(x,y,pix(x+1,y+1))end'