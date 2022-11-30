-- hello, gasman here!
-- greets to my fellow bytejammer
-- tobach (with a hat on the o)

--someone shout out a theme!

--I think someone said space...

stars={}
for i=0,100 do
stars[i]={math.random()*256,math.random()*163}
end

function SCN(y)
poke(16323,y*20)
poke(16324,y*20+time())
end

function TIC()t=time()
cls()
for i=0,100 do
circ((stars[i][1]-(t*i/5)/50)%256,stars[i][2],i/40,14-i/50)
end
y=math.sin(t/300)*20
circ(40,40+y,30,12)
circ(50,30+y,10,13)

tx=math.sin(t/350)*40
ty=math.sin(t/240)*40

if ((time()/10)%50)<25 then
tri(50,25+y,50,35+y,150+tx,100+ty,1)
end

circ(150+tx,100+ty,10,12)
tri(138+tx,90+ty,138+tx,110+ty,120+tx,100+ty,12)
tri(162+tx,90+ty,162+tx,110+ty,180+tx,100+ty,12)


end
