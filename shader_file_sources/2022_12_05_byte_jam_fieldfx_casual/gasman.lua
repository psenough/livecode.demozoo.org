-- hello from gasman!
-- shoutouts to the bytejam massive :-D

-- ok kids, today we're going to try to
-- code some voxels

-- so first we need to draw an
-- isometric cube I suppose

size=4
function cubie(x,y,c)
 -- c = colour. we have 5 of them
 -- (to fit into 5*3 shades in the
 -- 16 colour palette)

 p1=(3+c*3)//1
 if p1==0 then p1=1 end
 p2=(1+c*3)//1
 if p2==0 then p2=1 end
 p3=(2+c*3)//1
 if p3==0 then p3=1 end
 tri(x,y,x+size,y-size/2,x+size,y+size/2,p1)
 tri(x,y,x+size,y+size/2,x,y+size,p1)
 tri(x,y,x-size,y-size/2,x-size,y+size/2,p2)
 tri(x,y,x-size,y+size/2,x,y+size,p2)
 tri(x,y,x,y-size,x-size,y-size/2,p3)
 tri(x,y,x,y-size,x+size,y-size/2,p3)
end
-- so far so good...

function shadow(x,y,c)
 p=1
 tri(x,y,x,y-size,x-size,y-size/2,p)
 tri(x,y,x,y-size,x+size,y-size/2,p)
end

-- I'd really like to add more colours
-- here, but
-- a) that's going to be hard within
-- the 16-colour palette
-- b) I need a good way to allocate
-- those colours
-- something like: give one metaball
-- a negative colour and another one
-- a positive one

-- time for a nicer palette
-- a fade from blue to yellow,
-- with three shades of each
for hue=0,4 do
 for bri=0,2 do
  poke(16323+hue*9+bri*3,32+16*hue*(bri+0.2))
  poke(16324+hue*9+bri*3,32+16*hue*(bri+0.2))
  poke(16325+hue*9+bri*3,32+16*(4-hue)*(bri+0.2))
 end
end

-- a good old fashioned gradient
-- background
-- that's pretty nice as it is...
function SCN(y)
 poke(16320,y)
 poke(16321,y)
 poke(16322,y)
end

v1={}
v2={}
for z=-8,8 do
 v1[z]={}
 v2[z]={}
 for y=-8,8 do
  v1[z][y]={}
  v2[z][y]={}
  for x=-8,8 do
   v1[z][y][x]=0
   v2[z][y][x]=0
  end
 end
end

function TIC()
 -- sorry, we really need a cls now...
 cls()

 t=time()
 -- calculate some metaballs
 -- one more and we're done I think
 
 -- I think these would look more
 -- blobby if I had a central point
 -- that they gravitated around
 -- at a smaller amplitude

 -- and that central point should
 -- probably move slower

 cx=6*math.sin(t/1000)
 cy=6*math.sin(t/1020)
 cz=6*math.sin(t/1040)
 
 mx1=cx+6*math.sin(t/200)
 my1=cy+6*math.sin(t/220)
 mz1=cz+6*math.sin(t/240)
 mx2=cx+6*math.sin(1+t/360)
 my2=cy+6*math.sin(2+t/380)
 mz2=cz+6*math.sin(3+t/300)
 mx3=cx+6*math.sin(4+t/400)
 my3=cy+6*math.sin(5+t/420)
 mz3=cz+6*math.sin(6+t/440)
 
 -- now we want to draw a load of them.
 -- from back to front
 for z=8,-8,-1 do
  for x=8,-8,-1 do
   for y=-8,8 do
    -- TODO: make this into a function
    -- ...meh, who cares
    dx=mx1-x
    dy=my1-y
    dz=mz1-z
    d1=math.sqrt(dx*dx+dy*dy+dz*dz)

    dx=mx2-x
    dy=my2-y
    dz=mz2-z
    d2=math.sqrt(dx*dx+dy*dy+dz*dz)

    dx=mx3-x
    dy=my3-y
    dz=mz3-z
    d3=math.sqrt(dx*dx+dy*dy+dz*dz)

    -- I don't think I should be
    -- adding these... hmm
    -- yeah, I think I want a sum
    -- of inverses, or something
    -- like that
    d=1/(1/(d1+0.0001)+1/(d2+0.0001)+1/(d3+0.0001))
    v1[z][y][x]=d
    if d<3 then
     shade=d1-d3
     v2[z][y][x]=shade
     shadow(
      120+x*size-z*size,
      68+9*size-x*size/2-z*size/2
     )
    end
   end
  end
 end

 for z=8,-8,-1 do
  for x=8,-8,-1 do
   for y=-8,8 do
    if v1[z][y][x]<3 then
     shade=v2[z][y][x]
     cubie(
      120+x*size-z*size,
      68-y*size-x*size/2-z*size/2,
      shade//8)
    end
   end
  end
 end
end
