-- hello from gasman!

--someone shout out a theme please!!!
--llamas and unicorns I guess

m=math
s=m.sin
c=m.cos

function SCN(y)
 t=time()
 poke(16320+27,(y*10+t)%128)
 poke(16320+28,(y*12+t)%128)
 poke(16320+29,(y*14+t)%128)
 poke(16320+15,0)
 poke(16320+16,y*1.5)
 poke(16320+17,0)
end

function star(x,y,clr)
r=t/1000
for j=0,10 do
k=10+s(t/234)*j
for i=0,10 do
 circ(x+k*s(r+i*m.pi/5),y+k*c(r+i*m.pi/5),3,clr)
end
end
end

function TIC()t=time()
cls(9)
rect(0,63,240,136,5)
-- this might be a very cubist llama

sx=t/23
star((30+sx-30)%300,40+40*s(t/345+30),3)
star((190+sx-30)%300,40+40*s(t/345+40),4)
star((100+sx-30)%300,40+40*s(t/345+20),10)


-- ok, I guess I need a neck_length
-- variable...

n=10*m.abs(s(t/120))
j=10*m.abs(s(t/180))

x=(t/10)%480-240

-- feet
rect(50+x,100-j,20,5,4)
rect(100+x,100-j,20,5,4)
-- legs
rect(50+x,70-j,15,30,4)
rect(100+x,70-j,15,30,4)
-- body
rect(50+x,50-j,100,30,4)
-- neck
rect(120+x,10+n-j,30,50-n,4)
circ(128+x,18+n-j,2,0)
circ(138+x,18+n-j,2,0)

for i=0,30,5 do
-- that was meant to be a necklace,
-- but ok
circ(120+x+i,10+n-j,3,0)
end

for i=0,30,5 do
circ(120+x+i,45+n-j+5*c(i/20),3,i/8)
end

tri(132+x,24+n-j,136+x,24+n-j,134+x,26+n-j,0)
end
