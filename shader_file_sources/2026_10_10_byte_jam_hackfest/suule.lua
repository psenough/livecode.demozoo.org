sin=math.sin
cos=math.cos
flr=math.floor
rand=math.random
sqrt=math.sqrt
add=table.insert
rem=table.remove
pi=math.pi
steppy=0
max=20
dst=600
spd=2
xx={}
yy={}
zz={}
maxaurora=700
auroray={}

function q(x1,y1,x2,y2,x3,y3,x4,y4,c)
 tri(x1,y1,x2,y2,x3,y3,c)
 tri(x2,y2,x3,y3,x4,y4,c)
end

function BOOT()
 for i=0,max do
  xx[i]=2*sin(steppy/10*(pi/2))
  yy[i]=1*cos(steppy/50*(pi/2))
  zz[i]=i*i*2
  steppy=steppy+1
 end
 for i=0,maxaurora do
  auroray[i]=20*rand()
 end 
end

function calcdist(dist)
 if dist <10 then return 15 end
 if dist <50 then return 14 end 
 if dist <100 then return 13 end 
 if dist <150 then return 12 end
 if dist <200 then return 11 end 
 if dist <250 then return 10 end
 if dist <300 then return 9 end
 if dist <350 then return 8 end
 if dist <400 then return 7 end
 if dist <450 then return 6 end
 if dist <500 then return 5 end
 if dist <550 then return 4 end
 if dist <600 then return 3 else return 2 end 
end 

function cycleit()
 for i=0,max do
  zz[i]=zz[i]+i*i*0.01
 end
 if zz[max]>600 then
  rem(zz,max+1)
  add(zz,1,0)
  rem(xx,max+1)
  add(xx,1,2*sin(steppy/10*(pi/2)))
  rem(yy,max+1)
  add(yy,1,3*cos(steppy/50*(pi/2)))
  steppy=steppy+1
 end
end

function drawroad()
 for i=0,max-1 do 
  if zz[i]<600 then
   local prs=dst/(dst-zz[i])
   local prsn=dst/(dst-(zz[i+1]))
   local x=120+(xx[i])*prs
   local y=68+(yy[i])*prs
   local xn=120+(xx[i+1])*prsn
   local yn=68+(yy[i+1])*prsn
   local height1=5*prs
   local height2=5*prsn
   if zz[i+1]<600 then
    q(x-height1,y+height1,xn-height2,yn+height2,
      x+height1,y+height1,xn+height2,yn+height2,0)
    line(x,y+height1,xn,yn+height2,calcdist(zz[i]))      
    line(x-height1,y+height1,xn-height2,yn+height2,calcdist(zz[i]))
    line(x+height1,y+height1,xn+height2,yn+height2,calcdist(zz[i]))
    line(x-height1,y+height1,0,y+height1,calcdist(zz[i]))    
    line(x+height1,y+height1,240,y+height1,calcdist(zz[i]))
   else
   end
  end
 end
end

-- AURORA BOREALIS? IN THIS TIME OF THE YEAR
-- LOCATED ENTIRELY IN THIS BYTEJAM?

-- YES! 

-- MAY I SEE IT?


function auroraborealis(tim)

 for ix=0,60 do
  i=(t//1+280)%400-120+ix
  iadj=(t+i)//1%maxaurora
  bottomy=2*sin(i/9+tim)+2*sin(i/15+tim)+2*sin(i/11+tim)
  line(i,40+(bottomy)*sin(ix/60*pi),
       i,40+(bottomy-auroray[iadj]-(i)%20)*sin(ix/60*pi)/4,
       5)
  line(i,40+(bottomy-auroray[iadj]-(i)%20)*sin(ix/60*pi)/4,
       i,40+(bottomy-auroray[iadj]-(i)%20)*sin(ix/60*pi)/2,
       6)
  line(i,40+(bottomy-auroray[iadj]-(i)%20)*sin(ix/60*pi)/2,
       i,40+(bottomy-auroray[iadj]-(i)%20)*sin(ix/60*pi)/4*3,
       7)
  line(i,40+(bottomy-auroray[iadj]-(i)%20)*sin(ix/60*pi)/4*3,
       i,40+(bottomy-auroray[iadj]-(i)%20)*sin(ix/60*pi),
       8)       
 end


 for ix=0,90 do
  i=(t//1+160)%400-120+ix
  iadj=(t+i)//1%maxaurora
  bottomy=2*sin(i/8+tim)+2*sin(i/9+tim)+2*sin(i/14+tim)
  line(i,60+(bottomy)*sin(ix/90*pi),
       i,60+(bottomy-auroray[iadj]-(i)%20)*sin(ix/90*pi)/4,
       5)
  line(i,60+(bottomy-auroray[iadj]-(i)%20)*sin(ix/90*pi)/4,
       i,60+(bottomy-auroray[iadj]-(i)%20)*sin(ix/90*pi)/2,
       6)
  line(i,60+(bottomy-auroray[iadj]-(i)%20)*sin(ix/90*pi)/2,
       i,60+(bottomy-auroray[iadj]-(i)%20)*sin(ix/90*pi)/4*3,
       7)
  line(i,60+(bottomy-auroray[iadj]-(i)%20)*sin(ix/90*pi)/4*3,
       i,60+(bottomy-auroray[iadj]-(i)%20)*sin(ix/90*pi),
       8)       
 end

 for ix=0,120 do
  i=(t//1)%400-120+ix
  iadj=(t+i)//1%maxaurora
  bottomy=2*sin(i/6+tim)+2*sin(i/17+tim)+2*sin(i/14+tim)
  line(i,50+(bottomy)*sin(ix/120*pi),
       i,50+(bottomy-auroray[iadj]-(i)%20)*sin(ix/120*pi)/4,
       5)
  line(i,50+(bottomy-auroray[iadj]-(i)%20)*sin(ix/120*pi)/4,
       i,50+(bottomy-auroray[iadj]-(i)%20)*sin(ix/120*pi)/2,
       6)
  line(i,50+(bottomy-auroray[iadj]-(i)%20)*sin(ix/120*pi)/2,
       i,50+(bottomy-auroray[iadj]-(i)%20)*sin(ix/120*pi)/4*3,
       7)
  line(i,50+(bottomy-auroray[iadj]-(i)%20)*sin(ix/120*pi)/4*3,
       i,50+(bottomy-auroray[iadj]-(i)%20)*sin(ix/120*pi),
       8)       
 end

end

function round(arg)
 return (flr(arg+0.5)) 
end


function TIC()
 cls(0)
 t=time()/60
 cycleit()
 drawroad() 
 auroraborealis(t/5)
end
