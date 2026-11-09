-- Hello hello
-- We gonna write some waves today

t=0

function triw(x,a,p,t)
  return ((4*a)/p)*math.abs(((x-(p/4)+t)%p)-(p/2))-a
end

function sin(x,a,p,t)
  return a*math.sin((x/p)+t)
end

function drawFill(x,y,o,c)
 for i=0,200 do
   pix(x,y+o+i,c)
 end
end

function TIC()
  cls(10)
  
  circ(120,136-t/60,100,3)
  
  for x=0,240 do
   y1=triw(x,40,180,t*0.6)
   drawFill(x,y1,60,15)
   y2=triw(x,30,210,10+t)
   drawFill(x,y2,70,14)
   y3=sin(x,32,1330,50+t/18)
   drawFill(x,y3,120,6)
   y4=sin(x,22,100,90+t/7)
   drawFill(x,y4,120,5)
  end
  
  t=t+1
end

function OVR()
  poke(0x3fc0+3*3+1,0x7d)

  -- can we move them a bit with
  -- a triangle wave?
  
  o=triw(0,1.2,30,t)
 
  -- wall
  rect(0,0,240,10,13)
  rect(0,0,40,136,13)
  rect(200,0,40,136,13)
  rect(0,116,240,20,13)
  
  -- window
  for i=0,4 do
    rectb(37+i,7+i+o,166-i*2,112-i*2,15)
  end
  rect(37,32+o,166,2,15)

  -- seats
  elli(0,60+o,10,25,2)
  elli(0,125+o,15,45,2)
  elli(0,140+o,55,15,2)
  
  elli(240,60+o,10,25,2)
  elli(240,125+o,15,45,2)
  elli(240,140+o,55,15,2)

  -- tray
  rect(80,123+o,80,6,15)
  rect(100,129+o,7,14,15)
  rect(130,129+o,7,14,15)
  
  -- luggage space
  rect(0,10+o,30,5,15)
  line(25,15+o,0,25+o,15)
  
  rect(210,10+o,30,5,15)
  line(215,15+o,240,25+o,15)

  -- water bottle
  rect(105,103+o,9,20,11)
  circ(109,103+o,4,11)
  rect(108,96+o,3,3,8)
  
end

function SCN(n)
  -- sun
  poke(0x3fc0+3*3+1,n+80)

  -- sky gradient
  poke(0x3fc0+10*3+1,n+120)
  -- mountains gradient
  for i=0,2 do
    poke(0x3fc0+15*3+i,n+10)
    poke(0x3fc0+14*3+i,n+40)
  end
  -- hills gradient
  poke(0x3fc0+6*3+2,n+10)
  poke(0x3fc0+5*3+2,n+40)
end
