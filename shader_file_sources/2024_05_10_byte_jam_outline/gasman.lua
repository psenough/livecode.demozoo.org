-- hello from gasman!!!
-- WE HAVE THE POWER (for now)
-- greetings to all outline party peeps

function flower(cx,cy,R,petals,rota,clr)
 for y=-R,R do
  for x=-R,R do
   local a=math.atan2(x,y)+rota
   local r=R*math.abs(math.sin(a*petals/2))
   local pr=math.sqrt(x*x+y*y)
   if pr<r then
    pix(cx+x,cy+y,clr)
   end
  end
 end
end

function leaves(cx,cy,R,petals,rota,clr)
 for y=-R,R do
  for x=-R,R do
   local a=math.atan2(x,y)+rota
   local r=R*(1-math.abs(math.sin(a*petals/2)))
   local pr=math.sqrt(x*x+y*y)
   if pr<r then
    pix(cx+x,cy+y,clr)
   end
  end
 end
end

function flower2(cx,cy,R,petals,rota,clr1,clr2)
 leaves(cx,cy,R*.75,petals,rota,7)
 flower(cx,cy,R,petals,rota,clr1)
 flower(cx,cy,R/2,petals,rota,clr2)
end

function BDR(y)
 poke(16320,y*0.4)
 poke(16321,y)
 poke(16322,y*0.1)
end

function ring(gr,rota,majr,fscale,c1,c2,c3,c4)
 for i=0,2 do
  local fa=i*2*math.pi/3+gr
  local rd=fscale*(24+16*math.sin(fa))
  local cx=120+majr*math.sin(fa)
  local cy=67+majr*math.cos(fa)
  flower2(cx,cy,rd,7,rota,c1,c2)
  local cx2=120-majr*math.sin(fa)
  local cy2=67-majr*math.cos(fa)
  flower2(cx2,cy2,rd,5,rota,c3,c4)
 end
end

-- dammit, I overwrote the black in
-- the palette
poke(16320+45,0)
poke(16321+45,0)
poke(16322+45,0)

function bee(x,y,t)
	wingy=math.sin(t/12)*3
	elli(12+bx,by,3,3+wingy,13)
 circ(10+bx,5+by,5,4)
 circ(15+bx,5+by,5,4)
 rect(9+bx,0+by,3,11,15)
 rect(15+bx,0+by,3,11,15)
end

function windmill(wmx,wmy,t)
 tri(wmx+10,wmy+0,wmx+0,wmy+30,wmx+20,wmy+30,2)
 tri(wmx+20,wmy+0,wmx+10,wmy+30,wmx+30,wmy+30,2)
 rect(wmx+10,wmy+0,10,30,2)
 rect(wmx+13,wmy+22,4,7,15)
 wcx=wmx+15
 wcy=wmy+5
 for i=0,3 do
  wa=i*math.pi/2+t/545
  vx1=15*math.sin(wa-0.25)
  vx2=15*math.sin(wa+0.25)
  vy1=15*math.cos(wa-0.25)
  vy2=15*math.cos(wa+0.25)
  tri(wcx,wcy,wcx+vx1,wcy+vy1,wcx+vx2,wcy+vy2,12)
 end
end

function nottobachgrass(x,y)
 line(x,y,x-3,y-3,6)
 line(x,y,x,y-3,6)
 line(x,y,x+3,y-3,6)
end

function TIC()
 cls()
 local t=time()
 local rota=t/1234

 windmill(20,30,t)
 windmill(200,40,t)

 nottobachgrass(50,115)
 nottobachgrass(150,120)
 nottobachgrass(190,105)

 --function ring(gr,rota,majr,fscale,c1,c2,c3,c4)

 local sz=1+math.sin(t/1456)
 ring(t/456,rota,24*sz,sz/2+0.2,3,1,2,4)
 local sz2=1+math.sin(math.pi+t/1456)
 ring(t/456+math.pi,rota,24*sz2,sz2/2+0.2,1,8,9,4)

 for i=0,3 do
 	bx=120+100*math.sin((t+i*800)/1434)
 	by=67+67*math.cos((t+i*800)/1545)
 	bee(bx,by,t)
 end
end
