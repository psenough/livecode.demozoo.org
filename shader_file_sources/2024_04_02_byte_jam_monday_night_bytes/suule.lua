sin,cos,pi,abs,l=math.sin,math.cos,math.pi,math.abs,line

-- Setup

-- Sprite Data

spr0={
6,11,2,1,
5,11,3,1,
5,11,3,1,
4,11,3,1,1,0,
4,11,3,1,1,0,
3,11,3,1,1,0,1,1,
3,11,2,1,1,0,1,1,1,0,
4,11,2,1,2,0}
spr1={
8,11,
2,1,6,11,
3,1,5,11,
3,1,5,11,
4,1,4,11,
1,1,4,1,3,11,
4,1,1,1,3,11,
4,1,1,1,3,11}
spr16={
4,11,2,1,2,0,
6,11,1,0,1,1,
6,11,2,0,
6,11,1,0,1,1,
7,11,1,1,
8,11,
8,11,
8,11}
spr17={
4,1,1,1,3,11,
3,1,1,1,4,11,
2,1,1,1,5,11,
1,0,2,1,5,11,
3,1,5,11,
3,1,5,11,
2,1,6,11,
8,11}
spr32={
3,5,2,12,3,5,
1,5,1,13,3,12,11,5,
1,5,1,13,1,12,1,10,1,9,3,5,
1,13,2,12,1,9,1,0,27,5}
spr33={
2,12,6,5,
3,12,1,13,12,5,
1,13,2,12,1,10,4,5,
1,13,2,12,1,9,1,0,27,5}

function BOOT()
	rspr(spr0,0)
	rspr(spr1,1)
	rspr(spr16,16)
	rspr(spr17,17)
	rspr(spr32,32)	
	rspr(spr33,33)	
 vbank(1)
 poke(0x3ff8,3)
end

-- Read Sprite 

function rspr(sprarr,id)
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

-- Quad

function q(x1,y1,x2,y2,x3,y3,x4,y4,c)
 tri(x1,y1,x2,y2,x3,y3,c)
 tri(x2,y2,x3,y3,x4,y4,c)
end 

function clmp(x,n1,n2)
 if x < n1 then
  return n1
 else
  if x > n2 then 
   return n2
  else
   return x
  end 
 end   
end

function drw_tailfxdnc(ax,ay,deg1,deg2,deg3)
 circ(ax,ay,2,2)
 q(-2*cos(deg1)-0*sin(deg1)+ax,
   -2*sin(deg1)+0*cos(deg1)+ay,
    2*cos(deg1)-0*sin(deg1)+ax,
    2*sin(deg1)+0*cos(deg1)+ay,
   -9*cos(deg1)-12*sin(deg1)+ax,
   -9*sin(deg1)+12*cos(deg1)+ay,
    9*cos(deg1)-12*sin(deg1)+ax,
    9*sin(deg1)+12*cos(deg1)+ay,2)
 q(-9*cos(deg1)-12*sin(deg1)+ax,
   -9*sin(deg1)+12*cos(deg1)+ay,
    9*cos(deg1)-12*sin(deg1)+ax,
    9*sin(deg1)+12*cos(deg1)+ay,
   -12*cos((deg1+deg2)/2)-18*sin((deg1+deg2)/2)+ax,
   -12*sin((deg1+deg2)/2)+18*cos((deg1+deg2)/2)+ay,
    12*cos((deg1+deg2)/2)-18*sin((deg1+deg2)/2)+ax,
    12*sin((deg1+deg2)/2)+18*cos((deg1+deg2)/2)+ay,2)
 q(-12*cos((deg1+deg2)/2)-18*sin((deg1+deg2)/2)+ax,
   -12*sin((deg1+deg2)/2)+18*cos((deg1+deg2)/2)+ay,
    12*cos((deg1+deg2)/2)-18*sin((deg1+deg2)/2)+ax,
    12*sin((deg1+deg2)/2)+18*cos((deg1+deg2)/2)+ay,
   -14*cos(deg2)-31*sin(deg2)+ax,
   -14*sin(deg2)+31*cos(deg2)+ay,
    14*cos(deg2)-31*sin(deg2)+ax,
    14*sin(deg2)+31*cos(deg2)+ay,2)
 q(-14*cos(deg2)-31*sin(deg2)+ax,
   -14*sin(deg2)+31*cos(deg2)+ay,
    14*cos(deg2)-31*sin(deg2)+ax,
    14*sin(deg2)+31*cos(deg2)+ay,
   -10*cos((deg2+deg3)/2)-45*sin((deg2+deg3)/2)+ax,
   -10*sin((deg2+deg3)/2)+45*cos((deg2+deg3)/2)+ay,
    10*cos((deg2+deg3)/2)-45*sin((deg2+deg3)/2)+ax,
    10*sin((deg2+deg3)/2)+45*cos((deg2+deg3)/2)+ay,2)
 q(-10*cos((deg2+deg3)/2)-45*sin((deg2+deg3)/2)+ax,
   -10*sin((deg2+deg3)/2)+45*cos((deg2+deg3)/2)+ay,
    10*cos((deg2+deg3)/2)-45*sin((deg2+deg3)/2)+ax,
    10*sin((deg2+deg3)/2)+45*cos((deg2+deg3)/2)+ay,
    -5*cos(deg3)-51*sin(deg3)+ax,
    -5*sin(deg3)+51*cos(deg3)+ay,
     5*cos(deg3)-51*sin(deg3)+ax,
     5*sin(deg3)+51*cos(deg3)+ay,12)
 q( -5*cos(deg3)-51*sin(deg3)+ax,
    -5*sin(deg3)+51*cos(deg3)+ay,
     5*cos(deg3)-51*sin(deg3)+ax,
     5*sin(deg3)+51*cos(deg3)+ay,
    -1*cos(deg3*1.1)-57*sin(deg3*1.1)+ax,
    -1*sin(deg3*1.1)+57*cos(deg3*1.1)+ay,
     1*cos(deg3*1.1)-57*sin(deg3*1.1)+ax,
     1*sin(deg3*1.1)+57*cos(deg3*1.1)+ay,12)
    
end 

function drawarm(ax,ay,bx,by,cx,cy,dx,dy,inv)
 circ(ax,ay,4,2)
q(ax,ay-5,ax,ay+5,
  bx,by-5,bx,by+5,2)
q(ax-4,ay,ax+4,ay,
  bx-4,by,bx+4,by,2)
circ(bx,by,3,1)
if inv==1 then 
q(cx,cy-3,cx,cy+1,
  bx,by-4,bx,by+4,1)
q(cx-3,cy,cx+1,cy,
  bx-4,by,bx+4,by,1)
else
q(cx,cy-1,cx,cy+3,
  bx,by-4,bx,by+4,1)
q(cx-1,cy,cx+3,cy,
  bx-4,by,bx+4,by,1)

end
spr(0,dx,dy,11,1,inv,0,2,2)
end

function drawtop(ax,ay,bx,by,cx,cy)
-- Neck
q(-5+bx,-8+by,5+cx,-8+cy,
  -3+bx,-5+by,3+cx,-5+cy,13)
q(-4+bx,-11+by,4+cx,-11+cy,
  -4+bx,-8+by,4+cx,-8+cy,13)
q(-3+bx,-5+by,3+cx,-5+cy,
  -2+ax,-1+ay,2+ax,-1+ay,12)
q(-4+bx,-8+by,-3+bx,-5+by,
  -6+bx,-6+by,-2+ax,-1+ay,12)
q(4+cx,-8+cy,3+cx,-5+cy,
  6+cx,-6+cy,2+ax,-1+ay,12)
q(-4+bx,-11+by,-5+bx,-11+by,
  -4+bx,-8+by,-6+bx,-6+by,2)
q(4+cx,-11+cy,5+cx,-11+cy,
  4+cx,-8+cy,6+cx,-6+cy,2)

l(1+ax,-4+ay,6+cx,-6+cy,13)
l(-1+ax,-4+ay,-6+bx,-6+by,13)

q( -9+bx,-5+by,-6+bx,-6+by,
   -12+ax,1+ay,-8+ax,3+ay,6)
q( -6+bx,-6+by,-2+ax,-1+ay,
   -8+ax,3+ay,-2+ax,2+ay,5)
q( -2+ax,-1+ay,2+ax,-1+ay,
   -2+ax,2+ay,2+ax,2+ay,5)
q( 6+cx,-6+cy,2+ax,-1+ay,
   8+ax,3+ay,2+ax,2+ay,5)
q( 9+cx,-5+cy,6+cx,-6+cy,
   12+ax,1+ay,8+ax,3+ay,6)
q( -13+ax,3+ay,-12+ax,1+ay,
   -12+ax,10+ay,-9+ax,9+ay,6)
q( -12+ax,1+ay,-8+ax,3+ay,
   -9+ax,9+ay,-7+ax,9+ay,6)
q( -8+ax,3+ay,-2+ax,2+ay,
   -7+ax,9+ay,-2+ax,8+ay,5)
q( -2+ax,2+ay,2+ax,2+ay,
   -2+ax,8+ay,2+ax,8+ay,5)
q( 8+ax,3+ay,2+ax,2+ay,
   7+ax,9+ay,2+ax,8+ay,5)
q( 12+ax,1+ay,8+ax,3+ay,
   9+ax,9+ay,7+ax,9+ay,6)
q( 13+ax,3+ay,12+ax,1+ay,
   12+ax,10+ay,9+ax,9+ay,6)

end

function drawbelly(ax,ay,bx,by,cx,cy,dx,dy)
q(-12+dx,-3+dy,-9+dx,-4+dy,
  -10+bx,5+by,-9+bx,4+by,2)
q(-9+dx,-4+dy,-7+dx,-4+dy,
  -9+bx,4+by,-6+bx,3+by,2)
q(-7+dx,-4+dy,-2+dx,-5+dy,
  -6+bx,3+by,-2+bx,2+by,12)
q(-2+dx,-5+dy,2+dx,-5+dy,
  -2+bx,2+by,2+bx,2+by,12)
q(7+dx,-4+dy,2+dx,-5+dy,
  6+bx,3+by,2+bx,2+by,12)
q(9+dx,-4+dy,7+dx,-4+dy,
  9+bx,4+by,6+bx,3+by,2)
q(12+dx,-3+dy,9+dx,-4+dy,
  10+bx,5+by,9+bx,4+by,2)

q(-10+bx,5+by,-9+bx,4+by,
  -11+ax,9+ay,-9+ax,9+ay,2)
q(-9+bx,4+by,-6+bx,3+by,
  -9+ax,9+ay,-6+ax,10+ay,2)
q(-6+bx,3+by,-2+bx,2+by,
  -6+ax,10+ay,-2+ax,10+ay,12)
q(-2+bx,2+by,2+bx,2+by,
  -2+ax,10+ay,2+cx,10+cy,12)
q(6+bx,3+by,2+bx,2+by,
  6+cx,10+cy,2+cx,10+cy,12)
q(9+bx,4+by,6+bx,3+by,
  9+cx,9+cy,6+cx,10+cy,2)
q(10+bx,5+by,9+bx,4+by,
  11+cx,9+cy,9+cx,9+cy,2)
end

function drawunder(ax,ay,bx,by)
 q(-6+ax,-4+ay,-2+ax,-4+ay,
   -7+ax,1+ay,-2+ax,5+ay,5)
 q(6+bx,-4+by,2+bx,-4+by,
   7+bx,1+by,2+ax,5+by,5)
 q(-2+ax,-4+ay,2+bx,-4+by,
   -2+ax,5+ay,2+bx,5+by,5)
 q(-9+ax,-5+ay,-6+ax,-4+ay,
   -9+ax,1+ay,-7+ax,1+ay,6)
 q(9+bx,-5+by,6+bx,-4+by,
   9+bx,1+by,7+bx,1+by,6)
 q(-11+ax,-5+ay,-8+ax,-5+ay,
   -14+ax,0+ay,-9+ax,1+ay,6)
 q(11+bx,-5+by,8+bx,-5+by,
   14+bx,0+by,9+bx,1+by,6)
 q(-9+ax,1+ay,-6+ax,1+ay,
   -2+ax,5+ay,-2+ax,9+ay,6)

 q(9+bx,1+by,6+bx,1+by,
   2+bx,5+by,2+bx,9+by,6)
 q(-2+ax,5+ay,2+bx,5+by,
   -2+ax,9+ay,2+bx,9+by,6)
end

function drawleg(ax,ay,bx,by,cx,cy,inv)
 q(-8*inv+ax,4+ay,-6*inv+ax,-1+ay,
   -8*inv+bx,21+by,-7*inv+bx,26+by,2)
 q(-6*inv+ax,-1+ay,0*inv+ax,0+ay,
   -7*inv+bx,26+by,-3*inv+bx,28+by,2)
 q(0*inv+ax,0+ay,7*inv+ax,8+ay,
   -3*inv+bx,28+by,1*inv+bx,27+by,2)
 q(7*inv+ax,8+ay,6*inv+ax,17+ay,
   1*inv+bx,27+by,5*inv+bx,23+by,1)
 q(-7*inv+bx,26+by,-3*inv+bx,28+by,
   -9*inv+cx,54+cy,-6*inv+cx,56+cy,1)
 q(-3*inv+bx,28+by,1*inv+bx,27+by,
   -6*inv+cx,56+cy,-4*inv+cx,57+cy,1)
 q(1*inv+bx,27+by,2*inv+bx,36+by,
   -4*inv+cx,57+cy,-1*inv+cx,49+cy,1)
 q(-9*inv+cx,54+cy,-6*inv+cx,56+cy,
   -13*inv+cx,56+cy,-9*inv+cx,60.5+cy,1)
 q(-6*inv+cx,56+cy,-4*inv+cx,57+cy,
   -9*inv+cx,60.5+cy,-4*inv+cx,60.5+cy,1)
 q(-21*inv+cx,59+cy,-13*inv+cx,56+cy,
   -21*inv+cx,60.5+cy,-9*inv+cx,60.5+cy,1)
  end 
  
function drawhead(ax,ay)
 q(-3+ax,2.5+ay,3+ax,2.5+ay,
   -7+ax,6.5+ay,7+ax,6.5+ay,12)
 q(-7+ax,6.5+ay,7+ax,6.5+ay,
   -2+ax,12.5+ay,2+ax,12.5+ay,12)
 q(-8+ax,0.5+ay,-3+ax,0.5+ay,
   -7+ax,6.5+ay,-3+ax,2.5+ay,12)
 q(-11+ax,2+ay,-8+ax,0.5+ay,
   -9+ax,5+ay,-6+ax,6.5+ay,12)
 q(-9+ax,5+ay,-6+ax,6.5+ay,
   -12+ax,8+ay,-8+ax,7+ay,12)
 q(-12+ax,4+ay,-11+ax,2+ay,
   -14+ax,6+ay,-9+ax,5+ay,12)
 q(8+ax,0.5+ay,3+ax,0.5+ay,
   7+ax,6.5+ay,3+ax,2.5+ay,12)
 q(11+ax,2+ay,8+ax,0.5+ay,
   9+ax,5+ay,6+ax,6.5+ay,12)
 q(9+ax,5+ay,6+ax,6.5+ay,
   12+ax,8+ay,8+ax,7+ay,12)
 q(12+ax,4+ay,11+ax,2+ay,
   14+ax,6+ay,9+ax,5+ay,12)
 q(-11+ax,-10+ay,-10+ax,-13+ay,
   -8+ax,-4+ay,-4+ax,-8+ay,12)
 q(11+ax,-10+ay,10+ax,-13+ay,
   8+ax,-4+ay,4+ax,-8+ay,12)
 l(-11+ax,-10+ay,-8+ax,-4+ay,1)
 l(-11+ax,-10+ay,-10+ax,-13+ay,1)
 l(-10+ax,-13+ay,-4+ax,-8+ay,1)
 l(11+ax,-10+ay,8+ax,-4+ay,1)
 l(11+ax,-10+ay,10+ax,-13+ay,1)
 l(10+ax,-13+ay,4+ax,-8+ay,1)
 
 q(-7+ax,-9+ay,-4+ax,-10+ay,
   -4+ax,-8+ay,-2+ax,-9.5+ay,2)
 q(-5+ax,-13+ay,0+ax,-12+ay,
   -2+ax,-9.5+ay,2+ax,-9.5+ay,2)
 q( 0+ax,-14+ay,3+ax,-12+ay, 
    2+ax,-9.5+ay,4+ax,-8+ay,2)
 q(-2+ax,-9.5+ay,2+ax,-9.5+ay,
   -4+ax,-8+ay,4+ax,-8+ay,2)
 q(-3+ax,0.5+ay,3+ax,0.5+ay,
   -3+ax,2.5+ay,3+ax,2.5+ay,2)
 q(-4+ax,-8+ay,4+ax,-8+ay,
   -3+ax,0.5+ay,3+ax,0.5+ay,2)
 q(-8+ax,-4+ay,-4+ax,-8+ay,
   -8+ax,0.5+ay,-3+ax,0.5+ay,2)
 q(-10+ax,-2+ay,-8+ax,-4+ay,
   -11+ax,2+ay,-8+ax,0.5+ay,2)
 q(8+ax,-4+ay,4+ax,-8+ay,
   8+ax,0.5+ay,3+ax,0.5+ay,2)
 q(10+ax,-2+ay,8+ax,-4+ay,
   11+ax,2+ay,8+ax,0.5+ay,2)
 l(-3+ax,2+ay,-5+ax,4+ay,0)
 l(3+ax,2+ay,5+ax,4+ay,0) 
 l(0+ax,5+ay,0+ax,7+ay,13)
 l(-3+ax,8+ay,3+ax,8+ay,13)
 l(-1.5+ax,10+ay,1.5+ax,10+ay,13)
 l(-4+ax,7+ay,-1.5+ax,10+ay,13)
 l(4+ax,7+ay,1.5+ax,10+ay,13) 
 q(-2.5+ax,2.+ay,2.5+ax,2.5+ay,
   -2.5+ax,3.5+ay,2.5+ax,3.5+ay,0)
 q(-2.5+ax,3.5+ay,2.5+ax,3.5+ay,
   -0.5+ax,5.5+ay,0.5+ax,5.5+ay,0)
 spr(32,-6+ax,-5+ay,5,1,0,0,2,1)
end

function TIC()t=time()//40
local dt1=t/8
local t1=t/4
local ht1=t/2
vbank(0)
 cls(4)
vbank(1)
 cls(3)
 drw_tailfxdnc(103,74,pi/2*sin(t1/4),0.8*pi/2*sin(t1/4),0.9*pi/2*sin(t1/4))
 drawarm(93-2*sin(t1),46+1*cos(ht1),
        80-2*sin(t1)+3*cos(ht1),
        46-clmp(14*cos(t1),-10,10),
        80-2*sin(t1)+3*cos(ht1)-clmp(4*cos(ht1),0,2),
        31-clmp(14*cos(t1),-10,10),
        72-2*sin(t1)+3*cos(ht1)-clmp(4*cos(ht1),0,2),
        19-clmp(15*cos(t1),-10,10),1)

 drawarm(113-2*sin(t1),46-1*cos(ht1),
        126-2*sin(t1)-3*cos(ht1),
        46+clmp(15*cos(t1),-10,10),
        126-2*sin(t1)-3*cos(ht1)+clmp(4*cos(ht1),-2,0),
        31+clmp(15*cos(t1),-10,10),
        119-2*sin(t1)-3*cos(ht1)+clmp(4*cos(ht1),-2,0),
        19+clmp(15*cos(t1),-10,10),0)

 drawtop(103-sin(t1),47,
        103-2*sin(t1),47+1*cos(ht1),
        103-2*sin(t1),47-1*cos(ht1),1)
 drawbelly(103+2*sin(t1),60+1*cos(t1),103+sin(t1),60,103+2*sin(t1),60-1*cos(t1),103-sin(t1),60)
 drawunder(103+2*sin(t1),74+1*cos(t1),103+2*sin(t1),74-1*cos(t1))
 drawleg(95+2*sin(t1),75+1*cos(t1),91+2*sin(t1),76+1*cos(t1),89,75,1)
 drawleg(111+2*sin(t1),75-1*cos(t1),115+2*sin(t1),76-1*cos(t1),117,75,-1)
 drawhead(103-2*sin(t1),28-cos(t1))
end

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
