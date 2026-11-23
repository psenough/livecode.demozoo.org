-- title: hivedrive
-- author: Gasman
-- desc:   live-coding with hexagons for the Field-FX Monday Night Bytes stream, 2023-01-09
-- script: lua

-- hello from gasman! it's been a while

-- Greetings to ^ Mantratronic, Alia
--         and ToBach!

-- are we live? WE'RE LIVE!

-- OK, so I'm going to try the hexagon
-- thing I totally failed at a month
-- or two back

-- and hopefully I'll either succeed
-- this time, or fail in a different
-- interesting way from last time

-- how about some last-minute
-- palette jiggerypokery

pal={}
for i=0,48 do
 pal[i+1]=peek(i+16320)
end

function BDR(y)
 -- subtle. subtle is good.
 k=0.4+0.6*y/136
 for i=0,48 do
  poke(i+16320,k*pal[i+1])
 end
end

function TIC()
 t=time()
 a=t/2000
 cx=120+60*math.sin(t/1234)
 cy=68+60*math.sin(t/1345)

 for sy=0,135 do
  for sx=0,239 do
   -- let's get some rotozoomy action
   -- going on
   x=((sx-cx)*math.cos(a)+(sy-cy)*math.sin(a))*(1+(146-sy)/80)
   y=((sy-cy)*math.cos(a)-(sx-cx)*math.sin(a))*(1+(146-sy)/80)

   sc=32+20*math.sin(t/1634)
   
   -- now let's push these back over
   -- so they're regular hexagons
   -- again
   tx=x/sc+(y/sc)/2 ty=y/sc
   -- I'm not sure the aspect ratio
   -- is right, but it looks OK so
   -- let's run with it

-- if you draw a tesselating hexagon
-- pattern, but push it over so that
-- it's aligned to a square grid,
-- you get three different 'modes'
-- of square
-- I'd do an ASCII art diagram, but
-- that would get fiddly. Just trust me

-- YAY HEXAGONS!!!!!!

   mode=(tx//1+ty//1)%3
   if mode==0 then
    v=1-math.min(tx%1,ty%1)
   elseif mode==1 then
    v=1-math.abs(tx%1-ty%1)
    if ty%1>tx%1 then hx=hx+1 end
   else
    v=math.max(tx%1,ty%1)
   end
   
-- okay, so now I want to have
-- different phases for different
-- hexagons. The only problem is it's
-- going to be hard to translate x/y
-- to "which hexagon am I", isn't it

   hx=tx//2
   if ty//2%2==0 then
    hx=2
   end
   core=math.max(0.3+0.35*math.sin(t/1456+hx))
   
   -- still can't get things aligned,
   -- but at least the colour scheme's
   -- nice now...

   if v>0.8 then
    pix(sx,sy,hx)
   elseif v<core then
    pix(sx,sy,4)
   else
    pix(sx,sy,0)
   end
  end
 end
end
