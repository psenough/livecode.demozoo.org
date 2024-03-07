-- Hello everybody! Hope you're having a
-- wonderful day! It's a day certainly
-- worth celebrating!
flr=math.floor
sin=math.sin
cos=math.cos
rand=math.random
sqrt=math.sqrt
pi=math.pi
add=table.insert
rem=table.remove

max=20
dst=600
spd=2
fact=0.01
txx={}
tyy={}
tzz={}
cxx1={}
cyy1={}
czz1={}
crr1={}
cxx2={}
cyy2={}
czz2={}
crr2={}
cxx3={}
cyy3={}
czz3={}
crr3={}
cxx4={}
cyy4={}
czz4={}
crr4={}




function BOOT()
 for i=0,max do
  txx[i]=0
  tyy[i]=0
  tzz[i]=i*i*2
  cxx1[i]=0
  cyy1[i]=0
  czz1[i]=i*i*2
  crr1[i]=0
  cxx2[i]=0
  cyy2[i]=0
  czz2[i]=i*i*2
  crr2[i]=0
  cxx3[i]=0
  cyy3[i]=0
  czz3[i]=i*i*2
  crr3[i]=0
  cxx4[i]=0
  cyy4[i]=0
  czz4[i]=i*i*2
  crr4[i]=0

 end 
end

-- PREPARE FOR THE WURST TUNNEL EVER!

function cycleit()
 for i=0,max do
  tzz[i]=tzz[i]+i*i*fact
  czz1[i]=czz1[i]+i*i*fact
  czz2[i]=czz2[i]+i*i*fact
  czz3[i]=czz3[i]+i*i*fact 
  czz4[i]=czz4[i]+i*i*fact     
 end
 if tzz[max] > 900 then 
  rem(tzz,max+1)
  add(tzz,1,0)  
  rem(txx,max+1)
  add(txx,1,2*sin(t/100*pi/2))
  rem(tyy,max+1)  
  add(tyy,1,2*cos(t/100*pi/2))
  rem(czz1,max+1)
  add(czz1,1,0)  
  rem(cxx1,max+1)
  add(cxx1,1,2*sin(t/100*pi/2)+4-2*fft(20))
  rem(cyy1,max+1)  
  add(cyy1,1,2*cos(t/100*pi/2)+4-2*fft(1))
  rem(crr1,max+1)
  add(crr1,1,flr(6*fft(0)))
  rem(czz2,max+1)
  add(czz2,1,0)  
  rem(cxx2,max+1)
  add(cxx2,1,2*sin(t/100*pi/2)-4-2*fft(10))
  rem(cyy2,max+1)  
  add(cyy2,1,2*cos(t/100*pi/2)-4-2*fft(6))
  rem(crr2,max+1)
  add(crr2,1,flr(6*fft(1)))   
  rem(czz3,max+1)
  add(czz3,1,0)  
  rem(cxx3,max+1)
  add(cxx3,1,2*sin(t/100*pi/2)+4-2*fft(5))
  rem(cyy3,max+1)  
  add(cyy3,1,2*cos(t/100*pi/2)-4-2*fft(12))
  rem(crr3,max+1)
  add(crr3,1,flr(10*fft(2)))
  rem(czz4,max+1)
  add(czz4,1,0)  
  rem(cxx4,max+1)
  add(cxx4,1,2*sin(t/100*pi/2)-4-2*fft(8))
  rem(cyy4,max+1)  
  add(cyy4,1,2*cos(t/100*pi/2)+4-2*fft(6))
  rem(crr4,max+1)
  add(crr4,1,flr(10*fft(4)))   
  
 end
end

function calccol(dis)
 if dis < 40 then return 15 end
 if dis < 80 then return 14 end
 if dis < 120 then return 13 end
 if dis < 160 then return 12 end
 if dis < 200 then return 11 end
 if dis < 240 then return 10 end
 if dis < 280 then return  9 end
 if dis < 320 then return  8 end
 if dis < 360 then return  7 end
 if dis < 420 then return  6 end
 if dis < 460 then return  5 end
 if dis < 500 then return  4 end
 if dis < 540 then return  3 end
 if dis < 580 then return  2 end
 if dis < 620 then return  1 else return 0 end                
end

function drawcell(t)

end

function drawtunnel()
 for i=0,max-1 do
  if tzz[i]<600 then
   local prs=dst/(dst-tzz[i])
   local prsn=dst/(dst-tzz[i+1])
   local x=120+(txx[i]*prs)
   local y=68+(tyy[i]*prs)
   local cx1=120+(cxx1[i]*prs)
   local cy1=68+(cyy1[i]*prs)
   local cx2=120+(cxx2[i]*prs)
   local cy2=68+(cyy2[i]*prs)
   local cx3=120+(cxx3[i]*prs)
   local cy3=68+(cyy3[i]*prs)
   local cx4=120+(cxx4[i]*prs)
   local cy4=68+(cyy4[i]*prs)
   
   local xn=120+(txx[i+1]*prsn)
   local yn=68+(tyy[i+1]*prsn)
   local radius=10*prs
   local radiusn=10*prsn
   circb(x,y,radius,calccol(tzz[i]))
   if tzz[i+1]<600 then
    line(x+radius,y,xn+radiusn,yn,calccol(tzz[i+1]))
    line(x-radius,y,xn-radiusn,yn,calccol(tzz[i+1]))
    line(x,y+radius,xn,yn+radiusn,calccol(tzz[i+1]))   
    line(x,y-radius,xn,yn-radiusn,calccol(tzz[i+1]))
    line(x+radius/sqrt(2),y+radius/sqrt(2),xn+radiusn/sqrt(2),yn+radiusn/sqrt(2),calccol(tzz[i+1]))
    line(x-radius/sqrt(2),y+radius/sqrt(2),xn-radiusn/sqrt(2),yn+radiusn/sqrt(2),calccol(tzz[i+1]))
    line(x+radius/sqrt(2),y-radius/sqrt(2),xn+radiusn/sqrt(2),yn-radiusn/sqrt(2),calccol(tzz[i+1]))
    line(x-radius/sqrt(2),y-radius/sqrt(2),xn-radiusn/sqrt(2),yn-radiusn/sqrt(2),calccol(tzz[i+1]))                
   end
   circ(cx1,cy1,crr1[i]*prs,calccol(czz1[i]))
   circ(cx2,cy2,crr2[i]*prs,calccol(czz2[i]))
   circ(cx3,cy3,crr3[i]*prs,calccol(czz3[i]))
   circ(cx4,cy4,crr4[i]*prs,calccol(czz4[i]))         
  end
 end
end 
     
function TIC()
 t=time()//32
 cls(0)
 cycleit()
 drawtunnel()
 print('GET SOME DEMOSCENE INTO YOUR BLOODSTREAM')
end 