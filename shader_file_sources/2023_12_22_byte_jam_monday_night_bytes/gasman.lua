-- merry solstice everyone! gasman here
-- Greetings to mantratronic, aldroid,
-- the tic-80 massive and livecoders
-- everywhere!

w=0.3
function rv()
 return math.random()*.1-.05
end

function BDR(y)
 poke(16320,32+64+y/2)
 poke(16321,y)
 poke(16322,0)
end

stone1={
  {-1,-w+rv()-1,-w+rv()},
  {-1,-w+rv()-1,w+rv()},
  {-1,w+rv()-1,w+rv()},
  {-1,w+rv()-1,-w+rv()},
  {0,-w+rv()-1,-w+rv()},
  {0,-w+rv()-1,w+rv()},
  {0,w+rv()-1,w+rv()},
  {0,w+rv()-1,-w+rv()},
  {1,-w+rv()-1,-w+rv()},
  {1,-w+rv()-1,w+rv()},
  {1,w+rv()-1,w+rv()},
  {1,w+rv()-1,-w+rv()}
}

-- TIL lua doesn't support unary plus.
-- wtf?!?!?
stone2={
 {-1-w,-1,-w},
 {-1-w,-1,w},
 {-1+w,-1,w},
 {-1+w,-1,-w},
 {-1-w,0,-w},
 {-1-w,0,w},
 {-1+w,0,w},
 {-1+w,0,-w},
 {-1-w,1.5,-w},
 {-1-w,1.5,w},
 {-1+w,1.5,w},
 {-1+w,1.5,-w}
}

stone3={
 {1-w,-1,-w},
 {1-w,-1,w},
 {1+w,-1,w},
 {1+w,-1,-w},
 {1-w,0,-w},
 {1-w,0,w},
 {1+w,0,w},
 {1+w,0,-w},
 {1-w,1.5,-w},
 {1-w,1.5,w},
 {1+w,1.5,w},
 {1+w,1.5,-w}
}

function drawstone(v0,vlen,rx,ry,c)
 v1={}
 for i=1,vlen do
  v=v0[i]
  v1a={
   v[1]*math.cos(ry)+v[3]*math.sin(ry),
   v[2],
   v[3]*math.cos(ry)-v[1]*math.sin(ry)
  }
  v1[i]={
   v1a[1],
   v1a[2]*math.cos(rx)+v1a[3]*math.sin(rx),
   v1a[3]*math.cos(rx)-v1a[2]*math.sin(rx)
  }
 end
 for i=1,vlen-1 do
  for j=i,vlen do
   a=v1[i]
   b=v1[j]
   line(
    120+40*a[1],68+40*a[2],
    120+40*b[1],68+40*b[2],
    c
   )
  end
 end
end

function TIC()
 t=time()
 cls()
 circ(120,68,60,4)
 rect(0,80,240,100,5)
 ry=math.sin(t/1234)
 rx=math.sin(t/1345)/4+0.5
 drawstone(stone1,12,rx,ry,8)
 drawstone(stone2,12,rx,ry,9)
 drawstone(stone3,12,rx,ry,10)
end
