-- ok, so the literate programming
-- thing seemed to work last time,
-- so let's try that again shall we


-- ok, 10 minutes for... something?
-- stars I guess

m=math
s=m.sin
 cls()

-- what if we make them twinkle
starx={}
stary={}
for i=0,32 do
 starx[i]=m.random(240)
 stary[i]=m.random(68)
end

function SCN(y)
 if y<68 then
  -- yeah, let's go with that
  poke(16321+15*3,y*3)
  poke(16322+15*3,y*3)
 else
for i=0,48 do
 v=i/48
 if i%3==0 then
  poke(16320+i,(v*v)*255)
 elseif i%3==1 then
  poke(16320+i,(v*v)*255)
 else
  poke(16320+i,v*192+(y-68))
 end
  poke(16321+15*3,68*3)
  poke(16322+15*3,68*3)
end
 end
end

function TIC()
 t=time()

-- ok, midnight blue-y gradient palette
for i=0,48 do
 -- I guess I want a gradient from
 -- black to white, but with the blue
 -- increasing on a steeper gradient?
 v=i/48
 -- FINALLY
 if i%3==0 then
  poke(16320+i,(v*v)*255)
 elseif i%3==1 then
  poke(16320+i,(v*v)*255)
 else
  poke(16320+i,v*255)
 end
end


for i=0,32 do
 pix(starx[i],stary[i],8+((t*0.01+i)%8))
end
 circ(120,68,30,15)
 -- right, I want a sort of water wave
 -- effect, so let's try a sine plasma
 -- as a first pass
 for y=68,136 do
  for x=0,240 do
  -- let's try and do a perspective
  -- projection on this
  -- sort of there...? let's move on
   pz=(y-68)
   py=-y*20/(2+pz*0.1)
   px=(x-120)/(pz*0.01)
   -- right, I want the water to be
   -- a reflection of the moon, and
   -- the wave to serve as an offset
   -- to which pixel we pick for the
   -- reflection
   dx=(1.5*s(px*0.09+t*0.0075)
    -1.5*s(px*0.095-t*0.007)
   )
   dy=(1.5*s(py*0.2-t*0.01)
    -1.5*s(py*0.22-t*0.012)
   )
   -- let's add a bit of the greyscale
   -- as a sort of ambient element
   amb=dy+dx
   refl=pix(x+dx*2,68-(y-68)*1.5+dy*2)
   if refl>14 then
    refl=14
   end
   pix(x,y,3+amb/12+refl)
  end
 end
end
