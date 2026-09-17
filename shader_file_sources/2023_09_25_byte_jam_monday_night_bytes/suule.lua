local rand=math.random
local pi=math.pi
local cos=math.cos
local sin=math.sin
local sqrt=math.sqrt
local abs=math.abs
local flr=math.floor
local add=table.insert
local rem=table.remove

pal={0x07,0x08,0x0c,
     0x3d,0x14,0x14,
     0x58,0x32,0x20,
     0xff,0xe3,0xb2,     

     0x43,0xc0,0x48,
     0x1a,0xa1,0x1f,
     0x1b,0x78,0x1f,
     0x0b,0x3f,0x0d,

     0x0d,0x16,0x3f,
     0x29,0x36,0x6f,
     0x3b,0x5d,0xc9,
     0x41,0xa6,0xf6,

     0xf4,0xf4,0xf4,   
     0x94,0xb0,0xc2,   
     0x55,0x6c,0x86,
     0x33,0x3c,0x57 }

clouds1={}
clouds2={}
clouds3={}
clouds4={}
clouds5={}
clouds6={}
clouds7={}
clouds8={}
clouds9={}
cloudspos={}

local spd=30
local dst=1200

--Are you ready to fly tonight?
function BOOT()
 for i=0,300 do
  clouds1[i]=0
  clouds2[i]=0
  clouds3[i]=0
  clouds4[i]=0
  clouds5[i]=0
  clouds6[i]=0
  clouds7[i]=0
  clouds8[i]=0
  clouds9[i]=0
  cloudspos[i]=i*spd
 end
 for i=1,#pal do
  poke(0x03FC0+i-1,pal[i])
 end 
end  

function cycleclouds()
 for i=0,300 do
  cloudspos[i]=cloudspos[i]+spd
 end
 if cloudspos[300]>1600 then
  rem(cloudspos,300)
  add(cloudspos,1,0)
  rem(clouds1,300)
  add(clouds1,1,30*fft(0))
  rem(clouds2,300)
  add(clouds2,1,30*fft(2))
  rem(clouds3,300)
  add(clouds3,1,30*fft(4))
  rem(clouds4,300)
  add(clouds4,1,30*fft(6))
  rem(clouds5,300)
  add(clouds5,1,30*fft(8))
  rem(clouds6,300)
  add(clouds6,1,30*fft(10))
  rem(clouds7,300)
  add(clouds7,1,30*fft(12))
  rem(clouds8,300)
  add(clouds8,1,30*fft(14))
  rem(clouds9,300)
  add(clouds9,1,30*fft(16))
 end
end 

function drawclouds()
 for i=0,300 do
  if cloudspos[i]<dst then 
   local prs=dst/(dst-cloudspos[i])
   local xshft=120+0*prs
   local yshft=68+20*prs
   local rad=clouds1[i]*prs
   if rad>1 then 
   elli(xshft-2*prs,yshft+2*prs,5*rad,2*rad,13)
   elli(xshft,yshft,5*rad,2*rad,12) end  
   xshft=120+10*prs
   yshft=68+20*prs
   rad=clouds2[i]*prs
   if rad>1 then 
   elli(xshft-2*prs,yshft+2*prs,5*rad,2*rad,13)
   elli(xshft,yshft,5*rad,2*rad,12) end  
   xshft=120-10*prs
   yshft=68+20*prs
   rad=clouds3[i]*prs
   if rad>1 then 
   elli(xshft-2*prs,yshft+2*prs,5*rad,2*rad,13)
   elli(xshft,yshft,5*rad,2*rad,12) end  
   xshft=120+20*prs
   yshft=68+20*prs
   rad=clouds4[i]*prs
   if rad>1 then 
   elli(xshft-2*prs,yshft+2*prs,5*rad,2*rad,13)
   elli(xshft,yshft,5*rad,2*rad,12) end  
   xshft=120-20*prs
   yshft=68+20*prs
   rad=clouds5[i]*prs
   if rad>1 then 
   elli(xshft-2*prs,yshft+2*prs,5*rad,2*rad,13)
   elli(xshft,yshft,5*rad,2*rad,12) end  
   xshft=120+30*prs
   yshft=68+20*prs
   rad=clouds6[i]*prs
   if rad>1 then 
   elli(xshft-2*prs,yshft+2*prs,5*rad,2*rad,13)
   elli(xshft,yshft,5*rad,2*rad,12) end  
   xshft=120-30*prs
   yshft=68+20*prs
   rad=clouds7[i]*prs
   if rad>1 then 
   elli(xshft-2*prs,yshft+2*prs,5*rad,2*rad,13)
   elli(xshft,yshft,5*rad,2*rad,12) end  
   xshft=120+40*prs
   yshft=68+20*prs
   rad=clouds8[i]*prs
   if rad>1 then 
   elli(xshft-2*prs,yshft+2*prs,5*rad,2*rad,13)
   elli(xshft,yshft,5*rad,2*rad,12) end  
   xshft=120-40*prs
   yshft=68+20*prs
   rad=clouds9[i]*prs
   if rad>1 then 
   elli(xshft-2*prs,yshft+2*prs,5*rad,2*rad,13)
   elli(xshft,yshft,5*rad,2*rad,12) end  
  end
 end
end
    
function quad(x1,y1,x2,y2,x3,y3,x4,y4,col)
 tri(x1,y1,x2,y2,x3,y3,col)
 tri(x3,y3,x4,y4,x2,y2,col)
end 

function drawrotor(tx1,ty1,tim_r)
 switch=tim_r%4
 sigx=1 sigy=1
 if switch==0 then sigx=1 sigy=1 end
 if switch==1 then sigx=1 sigy=-1 end
 if switch==2 then sigx=-1 sigy=-1 end
 if switch==3 then sigx=-1 sigy=1 end
 for i=1,19 do
  line(120+tx1+i*sigx,77+ty1-sqrt(20*20-i*i)*sigy,120+tx1+i*sigx,77+ty1-sqrt(20*20-(i+1)*(i+1))*sigy,12)
  line(120+tx1-i*sigx,77+ty1+sqrt(20*20-i*i)*sigy,120+tx1-i*sigx,77+ty1+sqrt(20*20-(i+1)*(i+1))*sigy,12)
 end 
 for i=1,17 do
  line(120+tx1+i*sigx,77+ty1-sqrt(18*18-i*i)*sigy,120+tx1+i*sigx,77+ty1-sqrt(18*18-(i+1)*(i+1))*sigy,13) 
  line(120+tx1-i*sigx,77+ty1+sqrt(18*18-i*i)*sigy,120+tx1-i*sigx,77+ty1+sqrt(18*18-(i+1)*(i+1))*sigy,13)
 end 
 for i=1,14 do
  line(120+tx1+i*sigx,77+ty1-sqrt(15*15-i*i)*sigy,120+tx1+i*sigx,77+ty1-sqrt(15*15-(i+1)*(i+1))*sigy,13)  
  line(120+tx1-i*sigx,77+ty1+sqrt(15*15-i*i)*sigy,120+tx1-i*sigx,77+ty1+sqrt(15*15-(i+1)*(i+1))*sigy,13)
 end 
 for i=1,11 do
  line(120+tx1+i*sigx,77+ty1-sqrt(12*12-i*i)*sigy,120+tx1+i*sigx,77+ty1-sqrt(12*12-(i+1)*(i+1))*sigy,14)   
  line(120+tx1-i*sigx,77+ty1+sqrt(12*12-i*i)*sigy,120+tx1-i*sigx,77+ty1+sqrt(12*12-(i+1)*(i+1))*sigy,14)
 end 
 for i=1,8 do
  line(120+tx1+i*sigx,77+ty1-sqrt(9*9-i*i)*sigy,120+tx1+i*sigx,77+ty1-sqrt(9*9-(i+1)*(i+1))*sigy,14)    
  line(120+tx1-i*sigx,77+ty1+sqrt(9*9-i*i)*sigy,120+tx1-i*sigx,77+ty1+sqrt(9*9-(i+1)*(i+1))*sigy,14)
 end 
end 

function drawplane(xs,ys)
 quad(107+xs,90+ys,109+xs,90+ys,105+xs,107+ys,107+xs,107+ys,1)
 quad(132+xs,90+ys,134+xs,90+ys,134+xs,107+ys,136+xs,107+ys,1)
 quad(105+xs,107+ys,136+xs,107+ys,105+xs,109+ys,136+xs,109+ys,1)
 quad(101+xs,101+ys,105+xs,101+ys,101+xs,111+ys,105+xs,111+ys,15) 
 quad(136+xs,101+ys,140+xs,101+ys,136+xs,111+ys,140+xs,111+ys,15)  
-- Lower wing
 quad(64+xs,91+ys,176+xs,91+ys,45+xs,97+ys,195+xs,97+ys,6)
 line(45+xs,97+ys,195+xs,97+ys,4)
-- Struts 
 line(65+xs,68+ys,102+xs,91+ys,15)
 line(65+xs,91+ys,102+xs,68+ys,15) 
 quad(65+xs,66+ys,67+xs,66+ys,65+xs,92+ys,67+xs,92+ys,1)
 quad(100+xs,66+ys,102+xs,66+ys,100+xs,92+ys,102+xs,92+ys,1) 
 line(54+xs,68+ys,98+xs,95+ys,14)
 line(54+xs,95+ys,98+xs,68+ys,14) 
 quad(54+xs,66+ys,57+xs,66+ys,54+xs,96+ys,57+xs,96+ys,1)
 quad(96+xs,66+ys,99+xs,66+ys,96+xs,96+ys,99+xs,96+ys,1)
 line(139+xs,68+ys,174+xs,91+ys,15)
 line(139+xs,91+ys,174+xs,68+ys,15) 
 quad(173+xs,66+ys,175+xs,66+ys,173+xs,92+ys,175+xs,92+ys,1)
 quad(139+xs,66+ys,141+xs,66+ys,139+xs,92+ys,141+xs,92+ys,1) 
 line(142+xs,68+ys,185+xs,95+ys,14)
 line(142+xs,95+ys,185+xs,68+ys,14) 
 quad(183+xs,66+ys,186+xs,66+ys,183+xs,96+ys,186+xs,96+ys,1)
 quad(142+xs,66+ys,145+xs,66+ys,142+xs,96+ys,145+xs,96+ys,1)  
-- Now the upper wing
 quad(64+xs,64+ys,176+xs,64+ys,45+xs,68+ys,195+xs,68+ys,5)
 line(45+xs,68+ys,195+xs,68+ys,4) 
--Can't fly without an engine
 circ(120+xs,82+ys,11,15) 
 circ(120+xs,83+ys,11,14)
 elli(120+xs,84+ys,11,9,13) 
 circ(120+xs,88+ys,12,7)
 circ(120+xs,90+ys,12,6)   
 elli(120+xs,92+ys,12,9,5) 
 quad(120+xs,72+ys,123+xs,72+ys,117+xs,75+ys,122+xs,75+ys,12)
-- Rest of the plane :)
 quad(74+xs,110+ys,166+xs,110+ys,65+xs,118+ys,175+xs,118+ys,5)  
 line(65+xs,118+ys,175+xs,118+ys,4)  
 quad(108+xs,92+ys,133+xs,92+ys,114+xs,110+ys,127+xs,110+ys,5) 
 elli(120+xs,82+ys,9,3,1)
 elli(120+xs,83+ys,9,2,0)
-- Oh right this guy...
 elli(120+xs,83+ys,6,2,2) 
 circ(120+xs,78+ys,4,3)
 circ(120+xs,76+ys,4,2)
-- And the tail...     
 circ(120+xs,112+ys,7,6)
 elli(120+xs,110+ys,6,4,5)
 elli(120+xs,93+ys,3,24,4)
end

function calcwoba(t_wob)
 return sin(t_wob/pi)
end
function calcwobb(t_wob)
 return 3*cos(t_wob/pi)
end


function TIC()
 cls(10)
 rect(0,90,240,90,7)
 rect(0,105,240,90,6)
 rect(0,120,240,90,5)  
 cycleclouds()
 drawclouds()
 asft=calcwoba(time()/30)
 bsft=calcwobb(time()/60)
 drawrotor(asft,bsft,time()//80) 
 drawplane(asft,bsft)
end  


