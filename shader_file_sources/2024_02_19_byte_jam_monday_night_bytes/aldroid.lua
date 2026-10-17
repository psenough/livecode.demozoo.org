-- aldroid here
-- greets to vurpo, HeNeArXn and
-- ToBach

-- have a great time!
cls(0)
function TIC()t=time()
	circ(120,68,15,t//1200)
 for i=0,50 do
  x=math.random(0,239)
  y=math.random(0,135)

  a=math.atan2(y-68,x-120)
  r=((x-120)^2+(y-68)^2)^0.5

		r = r -2
  x1=120+math.cos(a)*r
  y1=68-math.sin(a)*r
  pc=pix(x1,y1)
  circ(x,y,3,pc)
 end
end
