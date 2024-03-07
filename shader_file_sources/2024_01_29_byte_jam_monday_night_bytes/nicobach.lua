--         ^
-- Nico & ToBach Tag Team!! 
-- :3
sin=math.sin
cos=math.cos

-- we just had an internal discussion
-- over if lovebyte was actually
-- next weekend, it was... we are dim

-- nico on the keyssss
-- "next weekend" to me reads as
-- "the next weekend that happens"
-- not "the weekend of next week"
-- technically not incorrect though
-- I'll let it slide

-- I think we're happy with this
-- thanks to everybody for watching
--         ^
-- and to ToBach for collabbing with
-- me on this entry!!

-- :3


text={"LOVE","BYTE","NEXT","WKND"}

function TIC()
t=time()/512
t2=time()/100
cls()
	-- I give up on pixels
	-- let's do crap with shapes
	for i=0,200 do 
		circ(
			sin(t-i+sin(t-i/2)/2)*120+120,
			sin(t-i/7)*68+68,
			sin(t)*10+10,
			i%2+14)
 end
 
 for j=-8,8 do
  for i=0,20 do
   circ(120+sin(t2/8+i/3)*(80+sin(j/2+t2/4)*32),68+cos(i/3+t2/8+j/3)*4+j*8,2,15-j%4)
  end
 end
 
 print(text[1+t//1%4],28,45+sin(t2)*8,12,true,8)
 
 for i=0,20000 do
  pix(math.random()*240,math.random()*136,0)
 end
 --hello its tobach now :)))
 
 for j=-4,4,2 do
  for i=-4,4,2 do
	  for scale=0,10,2 do
	   circ(
		i*48+j*48/2+sin(t2/11+2)*32+24,
	 j*48+cos(t2/7+1+i)*32+24,
	 10+sin(i+t2/8)*4-scale, 
	 15-(scale+(t*8))/4%3)
   end
   
   -- haha I cleaned up your code
   -- nico
   
   -- >:( -tobach
   
   clock(
	   i*48+j*48/2+sin(t2/11)*32,
	   j*48+cos(t2/7)*32,
	i)
  
	  -- tagging in tobach rn
   -- out of ideas
   
   -- hello tobach again
   -- hmmmmmmm  
  end
 end
 
end
-- I have been instructed to
-- " do something"
-- so I'm gonna try doing
-- something.
-- - nico
-- PS the clocks weren't my idea!
-- despite what some of you might think

function clock(x,y,off)
 circ(120+x,68+y,22,13)
 circ(120+x,68+y,20,12)
 for i=0,11 do
 --good enuff lol
  pix(120+sin(i/2)*16+x,68+cos(i/2)*16+y,15)
 end
 
 line(120+x,68+y,120-sin(t2/4+off)*16+x,68+cos(t2/4+off)*16+y,14)
 line(120+x,68+y,120-sin(t2/8+off)*8+x,68+cos(t2/8+off)*8+y,13)

end