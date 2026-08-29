--rho here

--i learned length of tables

s=math.sin
c=math.cos

l={"slackfest", "slackers", "Hello there", "whoa", "another word"}

nrCircles=25

function TIC()
 t=time()/199
 it=t//1
 cls()
 
 vis=s(t)
 
 tword=it % #l

 beat=fft(1)*300

 for i=0,nrCircles do
  rx=s(t/0.9+i/2)*5+10+beat
  px=s(i+t)*60+120
  py=c(i+t)*30+60
  pc=s(i/3)*16//1

  circb(px//1, py//1, rx, pc)
 end

 print(l[tword+1], 80+(beat/2) ,60+s(t*0.76)*10, (1+t)//1, true , 2, false)
  
end
