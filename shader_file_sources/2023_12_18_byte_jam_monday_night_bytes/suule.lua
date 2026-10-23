-- HEEEEEEEEEEY
-- I'm having a bit of a cold so nothing
-- Too fancy today!
-- Greetz to Gasman, Aldroid, Jtruk,
-- Nico and Tobach! And to you
-- Our deer.. I mean dear viewers ;)

-- First, let's create some sprites...
-- Because otherwise it won't work!

sin=math.sin
cos=math.cos
pi=math.pi
abs=math.abs
flr=math.floor
cil=math.ceiling
ran=math.random

snowdata1={}
snowdata2={}
homedata={}

sprite0={
8,0,						 
8,0,
8,0,
8,0,
8,0,
8,0,
4,0,1,1,3,0,
3,0,3,1,1,0,1,1}
sprite1={
8,0,						 
8,0,
8,0,
2,2,6,0,
1,0,3,2,1,12,3,0,
1,0,2,2,1,12,2,4,2,0,
2,0,1,2,2,12,1,4,2,0,
3,0,3,12,2,0}
sprite16={
2,0,6,1,
8,1,
8,1,
8,1,
8,1,
8,1,
2,0,2,1,4,0,
8,1 }
sprite17={
1,0,3,2,2,12,2,0,
2,1,4,2,1,12,1,0,
3,1,1,15,2,2,2,0,
6,1,1,2,1,0,
6,1,1,2,1,0,
6,1,1,2,1,15,
1,0,2,1,3,0,1,15,1,1,
7,1,1,0}
sprite2={
8,0,
7,0,1,1,
8,0,
8,0,
8,0,
8,0,
8,0,
3,0,1,1,4,0
}
sprite3={
8,0,
8,0,
1,1,2,0,1,1,4,0,
1,0,2,1,5,0,
2,0,3,1,3,0,
2,0,5,1,1,0,
1,0,5,1,2,0,
4,1,4,0
}
sprite5={
8,0,
8,0,
1,1,2,0,1,1,4,0,
1,0,2,1,5,0,
2,0,3,1,2,0,1,2,
2,0,5,1,1,0,
1,0,5,1,2,0,
4,1,4,0
}
sprite18={
4,0,4,1,
4,0,4,1,
3,0,5,1,
3,0,3,1,2,0,
2,0,4,1,2,0,
1,0,2,1,1,0,1,1,3,0,
2,1,1,0,1,1,4,0,
8,0
}
sprite19={
5,1,3,0,
6,1,2,0,
2,1,1,0,2,1,1,0,1,1,1,0,
4,0,1,1,2,0,1,1,
3,0,1,1,4,0,
8,0,
8,0,
8,0
}
sprite32={
8,0,
8,0,
8,0,
8,0,
2,0,1,5,1,0,1,7,3,0,
1,0,1,3,1,2,1,6,1,2,1,1,2,0,
1,0,1,5,3,6,1,7,2,0,
1,0,1,2,1,1,1,7,2,1,2,0
}

-- There! All sprites gotten by power
-- of precalc :D

function clamp(a1,l1,l2)
 if a1 < l1 then return l1 end
 if a1 > l2 then return l2 else return a1 end
end 

function readsprite(sprarr,id)
 local con=0
 for i=0,#sprarr//2-1 do
  local rep=sprarr[i*2+1]
  local col=sprarr[i*2+2]
  for j=1,rep do
   poke4(0x8000+con+id*64,col)
   con=con+1
  end 
 end
end

function BOOT()
 readsprite(sprite0,0)
 readsprite(sprite1,1)
 readsprite(sprite16,16)
 readsprite(sprite17,17)
 readsprite(sprite2,2)
 readsprite(sprite2,4) 
 readsprite(sprite3,3)
 readsprite(sprite5,5)
 readsprite(sprite18,18) 
 readsprite(sprite19,19)  
 readsprite(sprite18,20) 
 readsprite(sprite19,21)  
 readsprite(sprite32,32)
 for i=1,2 do
  snowdata1[i]={}
  snowdata2[i]={}
 end
 for i=0,120 do
  snowdata1[1][i]=i*2
  snowdata1[2][i]=ran(160)-40 
  snowdata2[1][i]=i*2+1
  snowdata2[2][i]=ran(160)-20
 end
 for i=1,5 do
  homedata[i]={}
 end
 homedata[1][1]=ran(30)
 homedata[2][1]=100+0.5+2*sin(homedata[1][1]/20)
 homedata[3][1]=30+ran(10)
 homedata[4][1]=25+ran(10)
 homedata[5][1]=4+ran(5)  
 for i=2,8 do
  homedata[1][i]=homedata[1][i-1]+homedata[3][i-1]+5+ran(10)
  homedata[2][i]=100+0.5+2*sin(homedata[1][i]/20)
  homedata[3][i]=30+ran(10)
  homedata[4][i]=25+ran(10)
  homedata[5][i]=4+ran(5)  
 end 
end

function home(x,y,width,height,chim)
 rect(x+2,y,width-4,height,1)
 rect(x+6,y+3*height/5,4,height/4,0)
 rect(x+width-10,y+3*height/5,4,height/4,0)
 rect(x+width/2-2,y+3*height/5,4,height/4,0)  
 for i=0,width do
  if i==0 or i==width then ypop=1 else ypop=0 end 
  line(x+i,y+ypop,x+i,y+height/2+2*sin(i),13)
  line(x+i,y+ypop,x+i,y+height/3+2*sin(i),12) 
 end
end

function drawhomes(tim)
 for i=0,240 do
  line(i,100+10*sin((tim*3+i)/20),i,136,14)
  line(i,110+10*sin((tim*3+i)/40),i,136,13)  
 end 
 for i=1,8 do
  home(homedata[1][i],homedata[2][i],homedata[3][i],homedata[4][i],homedata[5][i])
  if homedata[1][i]>-100 then
   homedata[1][i]=homedata[1][i]-2
  else
   homedata[1][i]=350
  end    
 end
end 
-- And done again :) Now we can code

function bob(tim,dil,ran,sht)
 return(flr(0.5+ran*sin((tim+sht)*pi/dil)))
end

function snow()
 for i=0,120 do
  pix(snowdata1[1][i],snowdata1[2][i],13)
  if snowdata1[2][i]<150 then
   snowdata1[2][i]=snowdata1[2][i]+2
  else
   snowdata1[2][i]=-5
  end
  if snowdata1[1][i]>-5 then
   snowdata1[1][i]=snowdata1[1][i]-5
  else
   snowdata1[1][i]=245
  end
 end
 for i=0,120 do
  pix(snowdata2[1][i],snowdata2[2][i],12)
  if snowdata2[2][i]<150 then
   snowdata2[2][i]=snowdata2[2][i]+2
  else
   snowdata2[2][i]=-5
  end
  if snowdata2[1][i]>-5 then
   snowdata2[1][i]=snowdata2[1][i]-4
  else
   snowdata2[1][i]=245
  end
 end     
end

function TIC()
 t=time()//30
 vbank(0)
 cls(0)
 spr(0,50,56+bob(t,60,4,0),0,1,0,0,2,2)
 spr(2,68,58+bob(t,60,4,0),0,1,0,0,2,2)
 spr(2,84,57+bob(t,60,4,12),0,1,0,0,2,2)
 spr(2,100,56+bob(t,60,4,3),0,1,0,0,2,2)
 spr(2,116,55+bob(t,60,4,-6),0,1,0,0,2,2)
 spr(4,132,54+bob(t,60,4,3),0,1,0,0,2,2)
 vbank(1)
 cls(0)
 drawhomes(t)
 snow()
 for i=0,240 do
  line(i,130+5*sin((t*3+i)/60),i,136,12)  
 end 
end