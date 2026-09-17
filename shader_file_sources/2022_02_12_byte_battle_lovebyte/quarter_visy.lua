j=0 c=math.cos f=math.floor o=48 function e() elli(x,y,n,m,t*j)
for i=0,8 do ellib(x+i,y+i,n-i*1,m-i*1,0)end end
function TIC()t=time()*.0007 cls() v=c(t)*48 for i=4,11,.5 do x=v+i*16 y=54+f(c(t+(i*t))*40) n=16 m=12 j=i
e()end rect(v+o,o+9,148,64,4)end