-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

t=0
pts={}

function TIC()

    smb=1
    bass=(fft(0,5)+fft(5,10))*0.5
    smb=smb*0.8+bass*0.2
 cls(0)
 t=t+0.1
 cx=120
 cy=69
 for y=0,135 do
     dy=y-cy
  for x=0,239 do
   dx=x-cx
      dist=math.sqrt(dx*dx+dy*dy)
      de=64/(dist+1)
      ang=math.atan(dy,dx)
         v=math.sin(de*2+t*3)+math.sin(ang*12+t*2)+math.sin(dist*0.8-t*4)
   c=7+v+(smb*7)
   if c<0 then c=0 end
   if c>15 then c=15 end
   pix(x,y,c)
  end
 end
    for i=0,40 do
     a=i*0.15+t*0.7
  r=(i*5+t*60)%120
  px=cx+math.cos(a)*r
  py=cy+math.sin(a)*r
  col=12+i%4
  pix(px,py,col)
 end
 --for y=0,135,2 do
 --    line(0,y,239,y,0)
 --end
    print(
        "Remi is Cute!",
        70+math.sin(t*2)*2,
        10+math.cos(t*3),
        0,true,2)
    print(
        "Silly Bytejam UwU",
        5,128,0)
        
    for i=1,6 do
     a=t+i
     orbit=20+i*10+smb*30
     x=120+math.cos(a*0.7)*orbit
     y=50+math.sin(a*0.9)*orbit
     r=10+i*2+smb*20
     sides=3+(9%5)
     rot=t+i
     col=(8+i+t*4)%16
     poly(x,y,r,sides,rot,col)
        pts[i]={x=x,y=y}
    end
    --for i=1,#pts-1 do
    --    line(
    --        pts[i].x,
    --        pts[i].y,
    --        pts[i+1].x,
    --        pts[i+1].y,12)
--    end
    
    
    
end

function poly(cx,cy,r,sides,rot,col)
    px=nil
    py=nil
    for i=0,sides do
        a=(i/sides)*math.pi*2+rot
        x=cx+math.cos(a)*r
        y=cy+math.sin(a)*r
        if px then
         line(px,py,x,y,col)
        end
        px=x
        py=y
    end
end

function thickline(x1,y1,x2,y2,col,w)
    for ox=w,w do
        for oy=w,w do
            if ox*ox+oy*oy <= w*w then
                line(
                x1+ox,y1+oy,x2+ox,y2+oy,col)
            end
        end
    end
end