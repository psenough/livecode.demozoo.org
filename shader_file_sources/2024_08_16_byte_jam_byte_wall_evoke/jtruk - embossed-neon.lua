T=0
M=math
S=M.sin
function TIC()
 poke(0x3ffb,0)
 cls()
 style={
 	{c=2,s=.3,m=1},
 	{c=3,s=.2,m=1},
  {c=4,s=.1,m=1},
  {c=11,s=0,m=.9},
  {c=0,s=-.2,m=.7}
 }
 
 local moveM=1+S(T*.004)*.1
 for i,s in ipairs(style) do
  local dx,dy=i*s.m,i*s.s
	 for i=0,100 do
 	 local x=120+S(i*moveM+T*0.016)*100
 	 local y=68+S(i+T*0.01)*50
   local sz=10*(1+s.s)
 		circ(x+dx,y+dy,sz,s.c)
  end
 end
 
 T=T+1
end
