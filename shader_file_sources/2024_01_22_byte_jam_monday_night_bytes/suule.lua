-- Today it's gonna be pure magic!
-- Greetz to doop, Tobach and dave84
-- Love to the people in chat <3

l=line
c=circ
e=elli
cb=circb
sin=math.sin
cos=math.cos
abs=math.abs
pi=math.pi

-- Ever since I've found a way to do
-- sprites live during a jam, I keep
-- overusing them to patch holes

-- eyes

sprite0={
1,1,1,8,6,1,
2,8,6,1,
1,12,7,1,
8,1,
8,1,
8,1,
8,1,
8,1}
sprite1={
1,1,4,8,3,1,
6,8,2,1,
2,12,1,9,1,0,1,12,1,10,2,1,
1,1, 2,12, 2,9, 3,1,
8,1,
8,1,
8,1,
8,1}

-- l.hand
sprite2={
8,1,
6,1,1,13,1,14,
4,1,1,13,3,14,
3,1,1,13,2,14,1,15,1,13,
2,1,1,13,2,14,1,15,1,13,1,14,
1,1,1,13,2,14,1,15,1,13,2,14,
1,13,2,14,1,15,1,13,2,14,1,15,
1,13,1,15,1,0,2,14,3,15}
sprite3={
4,13,2,14,2,1,
7,14,1,1,
3,15,1,13,4,14,
1,13,7,14,
4,14,3,15,1,14,
8,15,
8,15,
5,1,3,15}
sprite4={
8,1,
8,1,
2,14,5,1,1,13,
2,14,5,13,1,14,
7,14,1,15,
8,15,
8,15,
8,15}

--r.hand
sprite16={
5,1,3,13,
4,1,1,13,3,14,
3,1,1,13,1,0,1,14,2,15,
2,1,1,13,2,14,1,0,2,15,
1,1,1,13,1,0,3,14,1,0,1,15,
1,1,1,14,1,13,1,0,2,15,1,14,1,13,
1,14,1,15,1,14,1,13,1,0,1,15,1,13,1,14,
1,0,2,15,2,14,1,0,1,13,1,14}
sprite17={
8,1,
1,13,7,1,
2,14,6,1,
1,15,2,13,5,1,
1,13,2,14,1,13,4,1,
1,14,2,15,1,14,1,13,3,1,
2,15,2,14,1,15,3,1,
2,15,2,0,1,15,3,1
}
sprite32={
1,14,1,0,3,15,1,14,1,13,1,15,
1,1,1,15,1,0,3,15,1,14,1,15,
1,1,1,14,1,15,3,0,1,15,1,0,
2,1,1,14,1,15,1,0,2,15,1,0,
3,1,5,0,
4,1,4,0,
8,1,
8,1}
sprite33={
1,15,2,0,2,15,1,0,2,1,
1,15,1,0,3,15,1,0,2,1,
1,0,3,15,2,0,2,1,
1,0,3,15,2,0,2,1,
3,15,1,0,4,1,
2,0,6,1,
8,1,
8,1}
sprite48={
1,1,7,0,
1,1,7,0,
1,1,6,0,1,2,
1,1,3,0,3,2,1,12,
1,1,6,12,1,15,
1,1,7,15,
2,1,6,15,
3,1,5,15,
8,1}
sprite49={
2,0,4,15,2,1,
2,0,4,15,2,1,
1,13,1,12,3,15,3,1,
1,12,3,15,4,1,
3,15,5,1,
3,15,5,1,
2,15,6,1,
1,15,7,1,
}
sprite64={
3,1,5,15,
2,1,6,15,
2,1,6,15,
1,1,2,15,1,4,4,15,
2,15,1,4,5,15,
2,0,1,4,3,15,1,2,1,1,
1,1,1,0,1,4,3,0,1,3,1,1,
3,1,1,4,2,3,2,1
}
sprite65={
3,15,5,1,
2,15,6,1,
2,15,6,1,
1,15,7,1,
8,1,
8,1,
8,1,
8,1}
-- Basic function stuff, eh?

function clmp(a1,l1,l2)
 if a1 < l1 then return l1 end
 if a1 > l2 then return l2 else return a1 end
end 

function q(x1,y1,x2,y2,x3,y3,x4,y4,c)
 tri(x1,y1,x2,y2,x3,y3,c)
 tri(x2,y2,x3,y3,x4,y4,c)
end 

function readsprite(sprarr,id)
 local con=0
 for i=0,#sprarr//2-1 do
  local rep=sprarr[i*2+1]
  local col=sprarr[i*2+2]
  for j=1,rep do
   poke4(0x8000+con+id*64,col)
   con=con+1
  end 
 end
end

-- Unpack the goddamn sprites!
function BOOT()
 readsprite(sprite0,0)
 readsprite(sprite1,1)
 readsprite(sprite2,2) 
 readsprite(sprite3,3) 
 readsprite(sprite4,4)
 readsprite(sprite16,16)
 readsprite(sprite17,17) 
 readsprite(sprite32,32)
 readsprite(sprite33,33)
 readsprite(sprite48,48)
 readsprite(sprite49,49)    
 readsprite(sprite64,64) 
 readsprite(sprite65,65) 
 vbank(1)
 poke(0x03FF8,1)
 vbank(0)
end

function suit(ax,ay,bx,by)
for i=0,1 do 
 c( 127+ax, 87+ay-i, 3, 13-i)
 c( 124+ax, 84+ay-i, 3, 13-i)
end
for i=0,1 do 
 c( 129+ax+i, 82+ay-i, 3, 13-i)
 c( 124+ax, 79+ay-i, 3, 13-i)
end
 q( 82+bx, 81+by,  83+bx, 80+by,  81+bx, 88+by,  84+bx, 88+by, 8)
 q( 83+bx, 80+by,  88+bx, 76+by,  84+bx, 88+by,  91+bx, 88+by, 9)
 q( 88+bx, 76+by,  94+bx, 76+by,  91+bx, 88+by,  94+bx, 88+by, 9)
 q( 94+bx, 76+by,  97+bx, 77+by,  94+bx, 88+by,  95+bx, 88+by, 9)
 q( 97+bx, 77+by, 104+bx, 83+by,  95+bx, 88+by, 104+bx, 88+by,10)
 q(104+bx, 83+by, 111+ax, 88+ay, 104+bx, 88+by, 111+ax, 89+ay,10)
 q(111+ax, 88+ay, 117+ax, 89+ay, 111+ax, 89+ay, 117+ax, 91+ay,10)
 q(117+ax, 89+ay, 122+ax, 88+ay, 117+ax, 91+ay, 123+ax, 92+ay,10)
 q(122+ax, 88+ay, 127+ax, 87+ay, 123+ax, 92+ay, 126+ax, 92+ay,10) 

 q( 82+bx, 88+by,  84+bx, 88+by,  83+bx, 94+by,  86+bx, 94+by, 8)
 q( 84+bx, 88+by,  91+bx, 88+by,  86+bx, 94+by,  91+bx, 94+by, 9)
 q( 91+bx, 88+by,  94+bx, 88+by,  91+bx, 94+by,  96+bx, 94+by, 9)
 q( 94+bx, 88+by,  95+bx, 88+by,  96+bx, 94+by,  98+bx, 94+by, 8)
 q( 95+bx, 88+by, 104+bx, 88+by,  98+bx, 94+by, 102+bx, 94+by, 9)
 q(104+bx, 88+by, 111+ax, 89+ay, 102+bx, 94+by, 108+ax, 95+ay,10)
 q(111+ax, 89+ay, 117+ax, 91+ay, 108+ax, 95+ay, 114+ax, 98+ay,10)
 q(117+ax, 91+ay, 123+ax, 92+ay, 114+ax, 98+ay, 119+ax, 98+ay,10)
 q(123+ax, 92+ay, 126+ax, 92+ay, 119+ax, 98+ay, 125+ax, 99+ay,10) 
 q(123+ax, 92+ay, 126+ax, 92+ay, 119+ax, 98+ay, 125+ax, 99+ay,10)  
 q(126+ax, 92+ay, 126+ax, 92+ay, 125+ax, 99+ay, 127+ax, 97+ay, 9)  

 q( 83+bx, 94+by,  86+bx, 94+by,  84+bx, 98+by,  89+bx, 98+by, 8)
 q( 86+bx, 94+by,  91+bx, 94+by,  89+bx, 98+by,  91+bx, 99+by, 9)
 q( 91+bx, 94+by,  96+bx, 94+by,  91+bx, 99+by,  95+bx, 98+by, 9)
 q( 96+bx, 94+by,  98+bx, 94+by,  95+bx, 98+by,  98+bx, 98+by, 8)
 q( 98+bx, 94+by, 102+bx, 94+by,  98+bx, 98+by, 102+bx,100+by, 9)
 q(102+bx, 94+by, 108+ax, 95+ay, 102+bx,100+by, 108+ax,101+ay, 9)
 q(108+ax, 95+ay, 114+ax, 98+ay, 108+ax,101+ay, 115+ax,105+ay, 9)
 q(114+ax, 98+ay, 119+ax, 98+ay, 115+ax,105+ay, 122+ax,107+ay, 9)
 q(119+ax, 98+ay, 125+ax, 99+ay, 122+ax,107+ay, 129+ax,107+ay, 9)  
 q(125+ax, 99+ay, 127+ax, 97+ay, 129+ax,107+ay, 130+ax,104+ay, 9)  

 q( 84+bx, 98+by,  89+bx, 98+by,  86+bx,100+by,  88+bx,101+by, 8)
 q( 89+bx, 98+by,  91+bx, 99+by,  88+bx,101+by,  91+bx,102+by, 8)
 q( 91+bx, 99+by,  95+bx, 98+by,  91+bx,102+by,  95+bx,102+by, 8)
 q( 95+bx, 98+by,  98+bx, 98+by,  95+bx,102+by,  98+bx,101+by, 8)
 q( 98+bx, 98+by, 102+bx,100+by,  98+bx,101+by, 102+bx,102+by, 8)
 q(102+bx,100+by, 108+ax,101+ay, 102+bx,102+by, 108+ax,104+ay, 8)
 q(108+ax,101+ay, 115+ax,105+ay, 108+ax,104+ay, 115+ax,107+ay, 8)
 q(115+ax,105+ay, 122+ax,107+ay, 115+ax,107+ay, 122+ax,108+ay, 8)
 q(122+ax,107+ay, 129+ax,107+ay, 122+ax,108+ay, 131+ax,108+ay, 8)  
 q(129+ax,107+ay, 130+ax,104+ay, 131+ax,108+ay, 136+ax,108+ay, 8)  

-- Highlights
 l(127+ax, 97+ay, 130+ax,104+ay, 8)  
 l( 82+bx, 81+by,  83+bx, 80+by, 9)
 l( 83+bx, 80+by,  88+bx, 76+by, 10)
 l( 88+bx, 76+by,  94+bx, 76+by, 10)
 l( 94+bx, 76+by,  97+bx, 77+by, 10)
 l( 97+bx, 77+by, 104+bx, 83+by, 11)
 l(104+bx, 83+by, 111+ax, 88+ay, 11)
 l(111+ax, 88+ay, 117+ax, 89+ay, 11)
 l(117+ax, 89+ay, 122+ax, 88+ay, 11)
 l(122+ax, 88+ay, 127+ax, 87+ay, 11) 
end 

function thigh(ax,ay,bx,by)
-- Butt
 q(126+ax, 92+ay, 134+ax, 90+ay, 127+ax, 97+ay, 134+ax, 98+ay, 15)
 q(134+ax, 89+ay, 139+ax, 92+ay, 134+ax, 98+ay, 139+ax, 96+ay, 15)
 q(139+ax, 92+ay, 142+ax, 93+ay, 139+ax, 96+ay, 143+ax, 99+ay, 15)
 q(127+ax, 97+ay, 134+ax, 98+ay, 130+ax,104+ay, 135+ax,104+ay, 15)
 q(134+ax, 98+ay, 139+ax, 96+ay, 135+ax,104+ay, 139+ax,101+ay, 15)
 q(139+ax, 96+ay, 143+ax, 99+ay, 139+ax,101+ay, 142+ax,101+ay, 15)
 q(130+ax,104+ay, 135+ax,104+ay, 136+ax,108+ay, 139+ax,108+ay, 15)
 q(135+ax,104+ay, 139+ax,101+ay, 139+ax,108+ay, 142+ax,108+ay, 15)
 q(139+ax,101+ay, 142+ax,101+ay, 142+ax,108+ay, 147+ax,108+ay, 15)
-- Leg
 q(144+ax, 94+ay, 155+ax, 95+ay, 143+ax, 99+ay, 155+ax, 99+ay, 15)
 q(143+ax, 99+ay, 155+ax, 99+ay, 142+ax,101+ay, 155+ax,105+ay, 15)
 q(142+ax,101+ay, 155+ax,105+ay, 147+ax,108+ay, 155+ax,108+ay, 15)
 q(155+ax, 95+ay, 168+bx, 96+by, 155+ax, 99+ay, 170+bx, 98+by, 15)
 q(155+ax, 99+ay, 170+bx, 98+by, 155+ax,105+ay, 173+bx,101+by, 15)
 q(155+ax,105+ay, 173+bx,101+by, 155+ax,108+ay, 172+bx,106+by, 15) 
-- Buttshine
 q(127+ax, 87+ay, 134+ax, 87+ay, 126+ax, 92+ay, 134+ax, 90+ay, 14)
 q(134+ax, 87+ay, 140+ax, 89+ay, 134+ax, 89+ay, 139+ax, 92+ay, 14)
 q(140+ax, 89+ay, 144+ax, 92+ay, 139+ax, 92+ay, 142+ax, 93+ay, 14)
 q(142+ax, 93+ay, 144+ax, 92+ay, 143+ax, 99+ay, 144+ax, 94+ay, 14)
 q(144+ax, 92+ay, 155+ax, 93+ay, 144+ax, 94+ay, 155+ax, 95+ay, 14)
 q(155+ax, 93+ay, 166+bx, 94+by, 155+ax, 95+ay, 168+bx, 96+by, 14)
-- Highlights
 l(127+ax, 87+ay, 134+ax, 87+ay,13)
 l(134+ax, 87+ay, 140+ax, 89+ay,13)
 l(140+ax, 89+ay, 144+ax, 92+ay,13)
 l(142+ax, 93+ay, 144+ax, 92+ay,13)
 l(144+ax, 92+ay, 155+ax, 93+ay,13)
 l(155+ax, 93+ay, 166+bx, 94+by,13)
-- Tail
end

function leg(ox,oy,rot,rl)
-- joint 
 e( ox, oy,6,6,15+rl)

-- shoe
 q( ox+( -1*cos(rot))-(-50*sin(rot)),oy+(  0*sin(rot))+(-50*cos(rot)),
    ox+(  0*cos(rot))-(-50*sin(rot)),oy+(  0*sin(rot))+(-50*cos(rot)),
    ox+( -1*cos(rot))-(-42*sin(rot)),oy+( -1*sin(rot))+(-42*cos(rot)),
    ox+(  2*cos(rot))-(-43*sin(rot)),oy+(  2*sin(rot))+(-43*cos(rot)), 9-rl)
 q( ox+( -1*cos(rot))-(-42*sin(rot)),oy+( -1*sin(rot))+(-42*cos(rot)),
    ox+(  2*cos(rot))-(-43*sin(rot)),oy+(  2*sin(rot))+(-43*cos(rot)),
    ox+(  0*cos(rot))-(-36*sin(rot)),oy+(  0*sin(rot))+(-36*cos(rot)),
    ox+(  2*cos(rot))-(-38*sin(rot)),oy+(  2*sin(rot))+(-38*cos(rot)), 9-rl)
 q( ox+(  2*cos(rot))-(-43*sin(rot)),oy+(  2*sin(rot))+(-43*cos(rot)),
    ox+(  6*cos(rot))-(-44*sin(rot)),oy+(  6*sin(rot))+(-44*cos(rot)),
    ox+(  2*cos(rot))-(-38*sin(rot)),oy+(  2*sin(rot))+(-38*cos(rot)),
    ox+(  5*cos(rot))-(-39*sin(rot)),oy+(  5*sin(rot))+(-39*cos(rot)), 9-rl)
 q( ox+(  6*cos(rot))-(-44*sin(rot)),oy+(  6*sin(rot))+(-44*cos(rot)),
    ox+(  7*cos(rot))-(-46*sin(rot)),oy+(  7*sin(rot))+(-46*cos(rot)),
    ox+(  5*cos(rot))-(-39*sin(rot)),oy+(  5*sin(rot))+(-39*cos(rot)),
    ox+(  7*cos(rot))-(-40*sin(rot)),oy+(  7*sin(rot))+(-40*cos(rot)), 9-rl)
 q( ox+(  7*cos(rot))-(-46*sin(rot)),oy+(  7*sin(rot))+(-46*cos(rot)),
    ox+( 10*cos(rot))-(-50*sin(rot)),oy+( 10*sin(rot))+(-50*cos(rot)),
    ox+(  7*cos(rot))-(-40*sin(rot)),oy+(  7*sin(rot))+(-40*cos(rot)),
    ox+( 10*cos(rot))-(-42*sin(rot)),oy+( 10*sin(rot))+(-42*cos(rot)), 9-rl)
 q( ox+( 10*cos(rot))-(-50*sin(rot)),oy+( 10*sin(rot))+(-50*cos(rot)),
    ox+( 15*cos(rot))-(-51*sin(rot)),oy+( 15*sin(rot))+(-51*cos(rot)),
    ox+( 10*cos(rot))-(-42*sin(rot)),oy+( 10*sin(rot))+(-42*cos(rot)),
    ox+( 15*cos(rot))-(-47*sin(rot)),oy+( 15*sin(rot))+(-47*cos(rot)), 9-rl)
 q( ox+( 15*cos(rot))-(-51*sin(rot)),oy+( 15*sin(rot))+(-51*cos(rot)),
    ox+( 17*cos(rot))-(-50*sin(rot)),oy+( 17*sin(rot))+(-50*cos(rot)),
    ox+( 15*cos(rot))-(-47*sin(rot)),oy+( 15*sin(rot))+(-47*cos(rot)),
    ox+( 19*cos(rot))-(-48*sin(rot)),oy+( 19*sin(rot))+(-48*cos(rot)), 9-rl)
-- foot
 q( ox+( -1*cos(rot))-(-36*sin(rot)),oy+( -1*sin(rot))+(-36*cos(rot)),
    ox+(  2*cos(rot))-(-38*sin(rot)),oy+(  2*sin(rot))+(-38*cos(rot)),
    ox+( -1*cos(rot))-(-31*sin(rot)),oy+( -1*sin(rot))+(-31*cos(rot)),
    ox+(  1*cos(rot))-(-30*sin(rot)),oy+(  1*sin(rot))+(-30*cos(rot)), 14+rl)
 q( ox+(  2*cos(rot))-(-38*sin(rot)),oy+(  2*sin(rot))+(-38*cos(rot)), 
    ox+(  5*cos(rot))-(-39*sin(rot)),oy+(  5*sin(rot))+(-39*cos(rot)),
    ox+(  1*cos(rot))-(-30*sin(rot)),oy+(  1*sin(rot))+(-30*cos(rot)),
    ox+(  3*cos(rot))-(-29*sin(rot)),oy+(  3*sin(rot))+(-29*cos(rot)), 15+rl)
 q( ox+(  5*cos(rot))-(-39*sin(rot)),oy+(  5*sin(rot))+(-39*cos(rot)),
    ox+(  7*cos(rot))-(-40*sin(rot)),oy+(  7*sin(rot))+(-40*cos(rot)),
    ox+(  3*cos(rot))-(-29*sin(rot)),oy+(  3*sin(rot))+(-29*cos(rot)),
    ox+(  7*cos(rot))-(-29*sin(rot)),oy+(  7*sin(rot))+(-29*cos(rot)), 15+rl)
 q( ox+(  7*cos(rot))-(-40*sin(rot)),oy+(  7*sin(rot))+(-40*cos(rot)),
    ox+( 10*cos(rot))-(-42*sin(rot)),oy+( 10*sin(rot))+(-42*cos(rot)),
    ox+(  7*cos(rot))-(-29*sin(rot)),oy+(  7*sin(rot))+(-29*cos(rot)),  
    ox+( 12*cos(rot))-(-35*sin(rot)),oy+( 12*sin(rot))+(-35*cos(rot)), 15+rl)
 q( ox+( 10*cos(rot))-(-42*sin(rot)),oy+( 10*sin(rot))+(-42*cos(rot)),
    ox+( 15*cos(rot))-(-47*sin(rot)),oy+( 15*sin(rot))+(-47*cos(rot)),
    ox+( 12*cos(rot))-(-35*sin(rot)),oy+( 12*sin(rot))+(-35*cos(rot)),
    ox+( 16*cos(rot))-(-42*sin(rot)),oy+( 16*sin(rot))+(-42*cos(rot)), 15+rl)
 q( ox+( 15*cos(rot))-(-47*sin(rot)),oy+( 15*sin(rot))+(-47*cos(rot)),
    ox+( 19*cos(rot))-(-48*sin(rot)),oy+( 19*sin(rot))+(-48*cos(rot)), 
    ox+( 16*cos(rot))-(-42*sin(rot)),oy+( 16*sin(rot))+(-42*cos(rot)),  
    ox+( 18*cos(rot))-(-43*sin(rot)),oy+( 18*sin(rot))+(-43*cos(rot)), 14+rl)
 l( ox+(  2*cos(rot))-(-38*sin(rot)),oy+(  2*sin(rot))+(-38*cos(rot)), 
    ox+(  5*cos(rot))-(-39*sin(rot)),oy+(  5*sin(rot))+(-39*cos(rot)), 14+rl)
 l( ox+(  5*cos(rot))-(-39*sin(rot)),oy+(  5*sin(rot))+(-39*cos(rot)),
    ox+(  7*cos(rot))-(-40*sin(rot)),oy+(  7*sin(rot))+(-40*cos(rot)), 14+rl)    
 l( ox+(  7*cos(rot))-(-40*sin(rot)),oy+(  7*sin(rot))+(-40*cos(rot)),
    ox+( 10*cos(rot))-(-42*sin(rot)),oy+( 10*sin(rot))+(-42*cos(rot)), 14+rl)
 l( ox+( 10*cos(rot))-(-42*sin(rot)),oy+( 10*sin(rot))+(-42*cos(rot)),
    ox+( 15*cos(rot))-(-47*sin(rot)),oy+( 15*sin(rot))+(-47*cos(rot)), 14+rl)
 l( ox+( 15*cos(rot))-(-47*sin(rot)),oy+( 15*sin(rot))+(-47*cos(rot)),
    ox+( 18*cos(rot))-(-48*sin(rot)),oy+( 18*sin(rot))+(-48*cos(rot)), 13+rl)  
-- leg
 q( ox+(  3*cos(rot))-(-29*sin(rot)),oy+(  3*sin(rot))+(-29*cos(rot)),
    ox+(  7*cos(rot))-(-29*sin(rot)),oy+(  7*sin(rot))+(-29*cos(rot)),
    ox+(  0*cos(rot))-(-20*sin(rot)),oy+(  0*sin(rot))+(-20*cos(rot)),
    ox+(  7*cos(rot))-(-20*sin(rot)),oy+(  7*sin(rot))+(-20*cos(rot)), 15+rl)
 q( ox+(  0*cos(rot))-(-20*sin(rot)),oy+(  0*sin(rot))+(-20*cos(rot)),
    ox+(  7*cos(rot))-(-20*sin(rot)),oy+(  7*sin(rot))+(-20*cos(rot)),
    ox+( -1*cos(rot))-(-13*sin(rot)),oy+( -1*sin(rot))+(-13*cos(rot)),
    ox+(  7*cos(rot))-(-13*sin(rot)),oy+(  7*sin(rot))+(-13*cos(rot)), 15+rl)
 q( ox+( -1*cos(rot))-(-13*sin(rot)),oy+( -1*sin(rot))+(-13*cos(rot)),
    ox+(  7*cos(rot))-(-13*sin(rot)),oy+(  7*sin(rot))+(-13*cos(rot)),
    ox+( -1*cos(rot))-(  2*sin(rot)),oy+( -1*sin(rot))+( -4*cos(rot)),
    ox+(  7*cos(rot))-(  1*sin(rot)),oy+(  7*sin(rot))+(  1*cos(rot)), 15+rl)
 q( ox+(  1*cos(rot))-(-30*sin(rot)),oy+(  1*sin(rot))+(-30*cos(rot)),
    ox+(  3*cos(rot))-(-29*sin(rot)),oy+(  3*sin(rot))+(-29*cos(rot)),
    ox+( -2*cos(rot))-(-20*sin(rot)),oy+( -2*sin(rot))+(-20*cos(rot)),
    ox+(  0*cos(rot))-(-20*sin(rot)),oy+(  0*sin(rot))+(-20*cos(rot)), 14+rl)
 q( ox+( -2*cos(rot))-(-20*sin(rot)),oy+( -2*sin(rot))+(-20*cos(rot)),
    ox+(  0*cos(rot))-(-20*sin(rot)),oy+(  0*sin(rot))+(-20*cos(rot)),
    ox+( -4*cos(rot))-(-13*sin(rot)),oy+( -4*sin(rot))+(-13*cos(rot)),
    ox+( -1*cos(rot))-(-13*sin(rot)),oy+( -1*sin(rot))+(-13*cos(rot)), 14+rl)
 q( ox+( -4*cos(rot))-(-13*sin(rot)),oy+( -4*sin(rot))+(-13*cos(rot)),
    ox+( -1*cos(rot))-(-13*sin(rot)),oy+( -1*sin(rot))+(-13*cos(rot)),
    ox+( -5*cos(rot))-(  2*sin(rot)),oy+( -5*sin(rot))+(  2*cos(rot)),
    ox+( -1*cos(rot))-(  2*sin(rot)),oy+( -1*sin(rot))+( -4*cos(rot)), 14+rl)
 l( ox+( -1*cos(rot))-(-35*sin(rot)),oy+( -1*sin(rot))+(-35*cos(rot)),
    ox+( -1*cos(rot))-(-32*sin(rot)),oy+( -1*sin(rot))+(-32*cos(rot)), 13+rl)
 l( ox+(  1*cos(rot))-(-30*sin(rot)),oy+(  1*sin(rot))+(-30*cos(rot)),
    ox+( -2*cos(rot))-(-20*sin(rot)),oy+( -2*sin(rot))+(-20*cos(rot)), 13+rl)
 l( ox+( -2*cos(rot))-(-20*sin(rot)),oy+( -2*sin(rot))+(-20*cos(rot)), 
    ox+( -4*cos(rot))-(-13*sin(rot)),oy+( -4*sin(rot))+(-13*cos(rot)), 13+rl)
 l( ox+( -4*cos(rot))-(-13*sin(rot)),oy+( -4*sin(rot))+(-13*cos(rot)),
    ox+( -5*cos(rot))-(  2*sin(rot)),oy+( -5*sin(rot))+(  2*cos(rot)), 13+rl)

 l( ox+(  1*cos(rot))-(-30*sin(rot)),oy+(  1*sin(rot))+(-30*cos(rot)), 
    ox+(  7*cos(rot))-(-29*sin(rot)),oy+(  7*sin(rot))+(-29*cos(rot)), 9-rl)
 l( ox+(  1*cos(rot))-(-30*sin(rot)),oy+(  1*sin(rot))+(-30*cos(rot)), 
    ox+(  7*cos(rot))-(-29*sin(rot)),oy+(  7*sin(rot))+(-29*cos(rot)), 9-rl)
 l( ox+(  7*cos(rot))-(-40*sin(rot)),oy+(  7*sin(rot))+(-40*cos(rot)),
    ox+( 12*cos(rot))-(-35*sin(rot)),oy+( 12*sin(rot))+(-35*cos(rot)), 9-rl)
 l( ox+( 10*cos(rot))-(-42*sin(rot)),oy+( 10*sin(rot))+(-42*cos(rot)),
    ox+( 16*cos(rot))-(-42*sin(rot)),oy+( 16*sin(rot))+(-42*cos(rot)), 9-rl)
 l( ox+( 15*cos(rot))-(-47*sin(rot)),oy+( 15*sin(rot))+(-47*cos(rot)),
    ox+( 16*cos(rot))-(-42*sin(rot)),oy+( 16*sin(rot))+(-42*cos(rot)), 9-rl)
end 


function rarm(ax,ay,bx,by)
 q(59+ax,81+ay,63+ax,85+ay,54+ax,86+ay,58+ax,90+ay,0)
 c(61+ax,83+ay,4,15)
 c(60+ax,82+ay,3,14) 
 c(59+ax,81+ay,1,13)  
 q( 61+ax, 94+ay,  74+ax, 95+ay,  55+ax, 98+ay,  76+ax, 96+ay, 15)
 q( 85+bx, 78+by,  87+bx, 80+by,  74+ax, 95+ay,  76+ax, 96+ay, 15)
 q( 55+ax, 98+ay,  76+ax, 96+ay,  55+ax, 99+ay,  80+ax,106+ay,  0)
 q( 87+bx, 80+by,  90+ax, 88+ay,  76+ax, 96+ay,  80+ax,106+ay,15) 
 spr(16, 48+ax, 84+ay, 1,1, 0,0, 2,2) 
end

function larm(ax,ay,bx,by)
 cb(89+bx, 82+by, 5, 14)
 c(90+bx, 82+by, 5, 15) 
 c(79+ax, 102+ay, 5, 15)  
 q( 84+bx, 81+by,  96+bx, 84+by,  75+ax, 99+ay,  84+ax,106+ay, 15)
 q( 56+ax,107+ay,  77+ax,103+ay,  56+ax,108+ay,  81+ax,108+ay, 15)
 q( 84+bx, 81+by,  86+bx, 84+by,  75+ax, 99+ay,  77+ax,103+ay, 14) 
 q( 56+ax, 105+ay, 74+ax,100+ay,  56+ax,107+ay,  77+ax,103+ay, 14)  
 l( 84+bx, 81+by,  75+ax, 99+ay, 13)
 l( 56+ax,105+ay,  74+ax,100+ay, 13)
 l( 75+ax,100+ay,  76+ax,103+ay, 13)
 spr(2, 42+ax, 100+ay, 1,1, 0,0, 3,1) 
end

function head(ax,ay,bx,by,mth)
 for i=0,1 do 
  c( 66+ax, 62+ay-i, 3, 15-i) 
  c( 68+ax, 66+ay-i, 3, 15-i)
  c( 76+ax, 81+ay-i, 3, 15-i) 
  c( 73+ax, 85+ay-i, 3, 15-i)
  c( 76+ax, 83+ay-i, 3, 15-i)  
 end 
 q( 74+ax, 78+ay, 81+ax, 74+ay, 82+bx, 81+by, 85+bx, 78+ay, 0)
 q( 81+ax, 74+ay, 88+ax, 68+ay, 85+bx, 78+by, 93+bx, 76+by, 15) 
 spr(48, 64+ax, 74+ay+mth, 1,1, 0,0, 2,1)
-- c( 76+ax, 75+ay, 3, 15)
 c( 77+ax, 64+ay, 11, 15)
 c( 77+ax, 65+ay, 11, 15) 
 q( 68+ax, 64+ay, 72+ax, 64+ay, 62+ax, 70+ay, 72+ax, 70+ay, 15)
 q( 62+ax, 70+ay, 72+ax, 70+ay, 61+ax, 72+ay, 72+ax, 72+ay, 15)
 q( 61+ax, 72+ay, 72+ax, 72+ay, 61+ax, 74+ay, 72+ax, 74+ay, 15)
 q( 61+ax, 74+ay, 72+ax, 74+ay, 63+ax, 78+ay, 71+ax, 78+ay, 15) 
 q( 72+ax, 74+ay, 76+ax, 74+ay, 71+ax, 78+ay, 76+ax, 76+ay, 15)  
 l( 62+ax, 72+ay, 64+ax, 74+ay, 13)
 l( 65+ax, 74+ay, 67+ax, 72+ay, 13) 
 l( 65+ax, 74+ay, 67+ax, 78+ay, 13) 
 l( 64+ax, 78+ay, 70+ax, 78+ay, 13)

for i=0,1 do 
 c( 72+ax, 52+ay-i, 3, 13-i) 
 c( 64+ax, 58+ay-i, 3, 13-i)
 c( 67+ax, 55+ay-i, 3, 13-i)
 c( 82+ax, 54+ay-i, 3, 13-i)  
 c( 69+ax, 56+ay-i, 3, 13-i)
 c( 71+ax, 58+ay-i, 3, 13-i)
 c( 76+ax, 56+ay-i, 3, 13-i)
 c( 80+ax, 60+ay-i, 3, 13-i)
 c( 83+ax, 64+ay-i, 3, 13-i)
 c( 87+ax, 68+ay-i, 4, 13-i)
 c( 90+ax, 72+ay-i, 4, 13-i)
 c( 90+ax, 72+ay-i, 4, 13-i) 
 c( 77+ax, 54+ay-i, 3, 13-i)   
end
for i=0,1 do 
 c( 67+ax, 55+ay-i, 3, 13-i)
 c( 82+ax, 57+ay-i, 3, 13-i)  
 c( 87+ax, 56+ay-i, 3, 13-i)
 c( 92+ax, 67+ay-i, 3, 13-i) 
 c( 89+ax, 60+ay-i, 4, 13-i)
end 
for i=0,1 do 
 c( 84+ax, 71+ay-i, 3, 13-i)
 c( 82+ax, 54+ay-i, 3, 13-i)
 c( 83+ax, 64+ay-i, 3, 13-i)
 c( 84+ax, 71+ay-i, 3, 13-i)
 c( 82+ax, 80+ay-i, 3, 13-i)   
end
for i=0,1 do 
 c( 87+ax+i, 79+ay-i, 3, 13-i)
 c( 92+ax+i, 75+ay-i, 4, 13-i)
 c( 95+ax, 77+ay-i, 3, 13-i) 
 c( 85+ax, 73+ay-i, 3, 13-i)  
end 
 spr(0, 66+ax, 63+ay, 1,1, 0,0, 1,1)
 spr(1, 73+ax, 63+ay, 1,1, 0,0, 1,1) 
 spr(64, 83+ax, 59+ay, 1,1, 0,0, 2,1)  
end

function skirt(ax,ay)
 q(120,108, 149,108, 124+ax,125+ay, 147+ax, 125+ay, 10)
 q(124+ax,125+ay, 147+ax,125+ay, 126+2*ax,136,  140+2*ax, 136, 10)
 l(120,107, 149,107, 11)
end
-- Now for the impressive stuff

function SCN(ln)
 vbank(0)
 poke(0x03fc3,ln//4+clmp(20*sin(t/20),0,20))
 poke(0x03fc4,ln//2+clmp(60*sin(t/20),10,60))
 poke(0x03fc5,ln+clmp(120*sin(t/20),20,120))  
 vbank(1)
end

function TIC()
t=time()/60
vbank(0)
cls(1)
e(120,136,280,130,0)
e(120,136,275,125,1)
e(120,136,210,80,0)
e(120,136,215,75,1)
q(-1,-1,10,-1,50,137,70,137)
q(70,-1,80,-1,90,137,110,137)
q(230,-1,241,-1,170,137,190,137)
q(170,-1,160,-1,150,137,130,137)
e(120,136,160,30,0)
vbank(1)
cls(1)
local brth=sin(t/10)
local sng=sin(t/15)
local osc1=pi/6+sin((t+30)/10)*pi/6
local osc2=pi/6+sin(t/10)*pi/6
rectb(20,108,200,30,11)
rect(21,109,199,30,0)
l(50,108,80,108,10)
l(169,108,140,108,10)
l(20,108,50,108,9)
l(219,108,169,108,9)
l(20,108,20,136,8)
l(219,108,219,136,8)
rarm(-sng,2*sng,0,brth)
suit(0,0,0,brth)
leg(173,99+2*sin((t+30)/10),osc1,1)
leg(173,99+2*sin(t/10),osc2,0)
thigh(0,0,0,1.25*brth)
head(0,-abs(2*sng),0,brth,
-- Human speech range
clmp(
 fft(17)*3
+fft(18)*3
+fft(19)*5
+fft(20)*6
+fft(21)*6
+fft(22)*3
+fft(23)*6
+fft(24)*6
,1,3))
larm(-2*brth,0,0,brth)
skirt(sng,0,0)
end 
