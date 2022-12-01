m=math
-- my god it's full of stars
stars={}
starcount=400
armcount=2 -- ok, let's stick to 2
-- naming things is hard
swirliness=0.1
galaxysize=100

for i=1,starcount do
  -- y variation that's greater
  -- in the centre?
  -- I think I want it to be more
  -- flying saucer shaped
  -- another gaussian distribution
  -- trick?
  -- I think that's doing it
  radius=m.random(galaxysize)
  -- how close it is to the middle
  centrality=1-(radius/galaxysize)
  thicness=40*centrality
  dy=(
    m.random()*thicness-thicness/2
    + m.random()*thicness-thicness/2
    + m.random()*thicness-thicness/2
  )/2
  arm=m.random(armcount)
  armangle=arm*m.pi*2/armcount
  -- ok, I think the distance from the
  -- arm centre should be a sort of
  -- gaussian normal distribution
  -- and i don't know the formula for
  -- that
  -- but i do know that's what you get
  -- if you add several random
  -- numbers together, like throwing
  -- N dice
  armdeviation=(
    m.random()+m.random()+m.random()
    * centrality
  )
  -- ship it!
  stars[i]={
    radius, -- radius
    armangle+armdeviation+swirliness*radius, -- angle
    (galaxysize*1.5-radius)/50, -- dot size
    dy, -- vertical variation
    -- middle ones should be brighter
    centrality*8+m.random(8) -- colour
  }
end

bgstars={}
bgstarcount=400
for i=1,bgstarcount do
 bgstars[i]={
  m.random(240),m.random(136),
  -- they shouldn't go all the way
  -- to pink
  m.random(8)
 }
end


-- set palette
-- blue - cyan - white
-- so blue reaches 1 first
-- then green, then red
for i=1,15 do
 t=i/15
 -- masta_luke777 thinks it should
 -- have a tinge of pink
 -- so how about I make the green
 -- and blue elements top out at
 -- like 220 or something
 -- yes, that's a nice amount of pink
 poke(16320+i*3,t^4*191+64) --r
 poke(16320+i*3+1,t*150+32) --g
 poke(16320+i*3+2,t^0.25*150+32) --b
end

function TIC()
spin=time()/2400
twirl=time()/10000
cx=120
cy=68
cls()
-- i think i want to do a sort of
-- slow camera descent into the
-- galactic plane
camy=cy+35*m.cos(time()/10000)
 -- maybe some background stars
 -- for ambience...
for i=1,bgstarcount do
 star=bgstars[i]
 pix(
  (star[1]-time()/70)%240,
  (star[2]+camy)%136,
  star[3])
end
for i=1,starcount do
 star=stars[i]
 x=m.sin(star[2]+spin)*star[1]
 y=m.cos(star[2]+spin)*star[1]
 z=y*2
 x=x*m.sin(twirl)+z*m.cos(twirl)
 -- time for some palette variation
 circ(
  x+cx,
  y+camy+star[4],
  -- I think some sort of perspective
  -- scaling might be good
  -- yeah, kinda subtle
  -- but i think that's as far as
  -- it should go...
  star[3]+(z+100)/400,
  star[5])
end

 craft=time()/2000
 x=m.sin(109+spin+craft)*80
 y=m.cos(109+spin+craft)*50
circb(
  x+cx,
  y+camy,
 2,15
)
end
